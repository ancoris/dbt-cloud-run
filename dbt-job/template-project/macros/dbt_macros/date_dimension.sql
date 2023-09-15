{% macro date_dimension(start_date, end_date) %}

-- if this is an incremental run then there is no need to rebuild the data dimension
{% set target_relation = this %}
{% set existing_relation = load_relation(this) %}
{% if existing_relation is none or flags.FULL_REFRESH %}

  -- 1. Build dim_date_stage
  {% set build_dim_date_stage %}

  create or replace table {{this.database}}.{{this.schema}}.dim_date_stage
  as
  with date_range_spine as (

    {{ dbt_utils.date_spine(
          datepart="day",
          start_date="cast('" ~ start_date ~ "' as datetime)",
          end_date="cast('" ~ end_date ~ "' as datetime)"
        )
    }}
  ),

  date_range as(
    select  cast(date_day as date) as date_day
    from    date_range_spine
  ),

  lunar as
  (
    select  full_moon_date,
            is_total_eclipse,
            is_partial_eclipse,
            region,
            is_first_full_moon_on_or_after_march_21
    from    {{ref('dim_lunar_cycle')}}
  )

  select  
        date_day                              as date_surrogate_key,
        date_day                              as date_actual,
        format_date('%e',date_day)            as day_of_month_no,
        format_date('%A',date_day)            as day_name_full,
        format_date('%a',date_day)            as day_name_short,
        format_date('%W',date_day)            as week_no,
        format_date('%m',date_day)            as month_no,
        format_date('%B',date_day)            as month_name_full,
        format_date('%b',date_day)            as month_name_short,
        format_date('%Q',date_day)            as quarter_no,
        format_date('%Y',date_day)            as year_no,
        format_date('%C',date_day)            as century_no,

        date_trunc(date_day, week(monday))    as first_day_of_week,
        date_trunc(date_day, month)           as first_day_of_month,
        date_trunc(date_day, quarter)         as first_day_of_quarter,
        date_trunc(date_day, quarter)         as first_day_of_year,

        date_sub(date_trunc(date_add(date_day, interval 1 week), week(monday)), interval 1 day)
                                              as last_day_of_week,
        date_sub(date_trunc(date_add(date_day, interval 1 month), month), interval 1 day)
                                              as last_day_of_month,
        date_sub(date_trunc(date_add(date_day, interval 1 quarter), quarter), interval 1 day)
                                              as last_day_of_quarter,
        date_sub(date_trunc(date_add(date_day, interval 1 year), year), interval 1 day)
                                              as last_day_of_year,
        
        extract(day from last_day(date_day))  as days_in_month,

        format_date('%u',date_day)            as day_of_week_no,
        row_number() over (partition by extract(year from date_day),
                                        extract(quarter from date_day) order by date_day)
                                              as day_of_quarter_no,
        row_number() over (partition by extract(year from date_day) order by date_day)
                                              as day_of_year_no,

        date_diff(date_day, '{{start_date}}', year)
                                              as year_no_cumulative,
        date_diff(date_day, '{{start_date}}', quarter)
                                              as quarter_no_cumulative,
        date_diff(date_day, '{{start_date}}', month)
                                              as month_no_cumulative,
        date_diff(date_day, '{{start_date}}', week(monday))
                                              as week_no_cumulative,
        date_diff(date_day, '{{start_date}}', day)
                                              as day_no_cumulative,

        -- lunar information
        if(lunar_uk.full_moon_date is not null, 1, 0)     as lunar_uk_is_full_moon,
        ifnull(lunar_uk.is_total_eclipse,0)               as lunar_uk_is_total_eclipse,
        ifnull(lunar_uk.is_partial_eclipse,0)             as lunar_uk_is_partial_eclipse,
        lunar_uk.is_first_full_moon_on_or_after_march_21  as lunar_uk_is_first_full_moon_on_or_after_march_21
    from date_range c

      left outer join lunar lunar_uk
      on lunar_uk.full_moon_date = c.date_day
      and lunar_uk.region = 'UK'
  {% endset %}
  {% set results = run_query(build_dim_date_stage) %}


  -- public holidays
  {% set build_dim_date_public_holiday_stage %}

  create or replace table {{this.database}}.{{this.schema}}.dim_date_public_holiday_stage
  as
  -- Easter Sunday is the first Sunday after the full moon that occurs on or after the vernal equinox (21 March)
  with easter_sundays as
  (
    select  min(s.date_surrogate_key) as date_day,
            'Easter Sunday'           as uk_holiday_name
    from    {{this.database}}.{{this.schema}}.dim_date_stage s
    where   s.date_surrogate_key >
    (
      select  l.date_surrogate_key
      from    {{this.database}}.{{this.schema}}.dim_date_stage l
      where l.year_no = s.year_no
      and   l.lunar_uk_is_first_full_moon_on_or_after_march_21 = 1
    )
    and s.day_name_full = 'Sunday'
    group by s.year_no
  )

  select  date_surrogate_key            as date_day,
          'New Years Day'               as uk_holiday_name
  from    {{this.database}}.{{this.schema}}.dim_date_stage
  where   day_of_year_no = 1

  -- Easter
  union all
  select  date_day                      as date_day,
          'Easter Sunday'               as uk_holiday_name
  from    easter_sundays
  union all
  select  date_add(date_day, interval 1 day),
          'Easter Monday'               as uk_holiday_name
  from    easter_sundays s
  union all
  select  date_sub(date_day, interval 1 day),
          'Easter Saturday'             as uk_holiday_name
  from    easter_sundays s
  union all
  select  date_sub(date_day, interval 2 day),
          'Easter Friday'               as uk_holiday_name
  from    easter_sundays s

  union all
  select  min(date_surrogate_key)       as date_day,
          'Early May bank holiday'      as uk_holiday_name
  from    {{this.database}}.{{this.schema}}.dim_date_stage
  where   month_name_full = 'May'
  and     day_name_full = 'Monday'
  group by year_no

  union all
  select  max(date_surrogate_key)       as date_day,
          'Late May bank holiday'       as uk_holiday_name
  from    {{this.database}}.{{this.schema}}.dim_date_stage
  where   month_name_full = 'May'
  and     day_name_full = 'Monday'
  group by year_no

  union all
  select  max(date_surrogate_key)       as date_day,
          'August bank holiday'         as uk_holiday_name
  from    {{this.database}}.{{this.schema}}.dim_date_stage
  where   month_name_full = 'August'
  and     day_name_full = 'Monday'
  group by year_no

  union all
  select  date_surrogate_key            as date_day,
          'Christmas Day'               as uk_holiday_name
  from    {{this.database}}.{{this.schema}}.dim_date_stage
  where   month_name_full = 'December'
  and
  (
    day_of_month_no = '25' and day_name_short not in ('Sat','Sun')  -- christmas day on a weekday
    or
    day_of_month_no = '27' and day_name_short = 'Mon'               -- christmas day on a saturday
    or
    day_of_month_no = '26' and day_name_short = 'Mon'               -- christmas day on a sunday
  )

  union all
  select  date_surrogate_key            as date_day,
          'Boxing Day'                  as uk_holiday_name
  from    {{this.database}}.{{this.schema}}.dim_date_stage
  where   month_name_full = 'December'
  and
  (
    day_of_month_no = '26' and day_name_short in ('Tue','Wed','Thu','Fri')  -- christmas day monday - thursday
    or
    day_of_month_no = '28' and day_name_short in ('Mon')                    -- christmas day on friday
    or
    day_of_month_no = '28' and day_name_short in ('Tue')                    -- christmas day on saturday
    or
    day_of_month_no = '27' and day_name_short in ('Tue')                    -- christmas day on sunday
  )
  {% endset %}
  {% set results = run_query(build_dim_date_public_holiday_stage) %}

  with temp as
  (
    select  date_surrogate_key,
            date_actual,

            concat(year_no, 'D', day_of_year_no)  as year_day,
            concat(year_no, 'W', week_no)         as year_week,
            concat(year_no, 'M', month_no)        as year_month,
            concat(year_no, 'Q', quarter_no)      as year_quarter,

            cast(day_of_month_no as int64)  as day_of_month_no,
            if(day_name_short in ('Sat','Sun'),0 ,1)  as is_week_day,
            day_name_full,
            day_name_short,
            month_name_full,
            month_name_short,

            cast(month_no as int64)     as month_no,
            cast(week_no as int64)      as week_no,
            cast(quarter_no as int64)   as quarter_no,
            cast(year_no as int64)      as year_no,
            cast(century_no as int64)   as century_no,

            first_day_of_week,
            first_day_of_month,
            first_day_of_quarter,
            first_day_of_year,

            last_day_of_week,
            last_day_of_month,
            last_day_of_quarter,
            last_day_of_year,

            days_in_month,

            cast(day_of_week_no as int64)       as day_of_week_no,
            cast(day_of_quarter_no as int64)    as day_of_quarter_no,
            cast(day_of_year_no as int64)       as day_of_year_no,

            year_no_cumulative,
            quarter_no_cumulative,
            month_no_cumulative,
            week_no_cumulative,
            day_no_cumulative,

            -- lunar information
            lunar_uk_is_full_moon,
            lunar_uk_is_total_eclipse,
            lunar_uk_is_partial_eclipse,

            -- bank holidays
            if(uk_holidays.uk_holiday_name is not null, 1, 0) is_uk_holiday,
            uk_holidays.uk_holiday_name,


            {{meta_process_time() }} as meta_process_time
      from {{this.database}}.{{this.schema}}.dim_date_stage p

        left outer join {{this.database}}.{{this.schema}}.dim_date_public_holiday_stage uk_holidays
        on uk_holidays.date_day = p.date_surrogate_key
    )

    select                  
      {{ dbt_utils.generate_surrogate_key(['date_surrogate_key']) }}                      as date_surrogate_key,   
      date_actual,

      year_day,
      year_week,
      year_month,
      year_quarter,

      day_of_month_no,
      is_week_day,
      day_name_full,
      day_name_short,
      month_name_full,
      month_name_short,

      month_no,
      week_no,
      quarter_no,
      year_no,
      century_no,

      first_day_of_week,
      first_day_of_month,
      first_day_of_quarter,
      first_day_of_year,

      last_day_of_week,
      last_day_of_month,
      last_day_of_quarter,
      last_day_of_year,

      days_in_month,

      (
        select max(d2.date_actual)
        from temp d2
        where d2.year_no = d.year_no
        and d2.month_no = d.month_no
        and d2.is_uk_holiday = 0
        and d2.is_week_day = 1
      )                                   as last_working_day_of_month,

      (
        select max(d2.date_actual)
        from temp d2
        where d2.year_no = d.year_no
        and d2.quarter_no = d.quarter_no
        and d2.is_uk_holiday = 0
        and d2.is_week_day = 1
      )                                   as last_working_day_of_quarter,

      (
        select max(d2.date_actual)
        from temp d2
        where d2.year_no = d.year_no
        and d2.is_uk_holiday = 0
        and d2.is_week_day = 1
      )                                   as last_working_day_of_year,

      (
        select max(d2.date_actual)
        from temp d2
        where d2.day_no_cumulative between d.day_no_cumulative-10 and d.day_no_cumulative
        and d2.is_uk_holiday = 0
        and d2.is_week_day = 1
      )                                   as most_recent_working_day,

      cast(day_of_week_no as int64)       as day_of_week_no,
      cast(day_of_quarter_no as int64)    as day_of_quarter_no,
      cast(day_of_year_no as int64)       as day_of_year_no,

      year_no_cumulative,
      quarter_no_cumulative,
      month_no_cumulative,
      week_no_cumulative,
      day_no_cumulative,

      -- lunar information
      lunar_uk_is_full_moon,
      lunar_uk_is_total_eclipse,
      lunar_uk_is_partial_eclipse,

      -- bank holidays
      is_uk_holiday,
      uk_holiday_name,

      meta_process_time
    from temp d

  {% endif %}
{% endmacro %}
