-- this model is an example of the 'from_gcs_csv' materialization

{{
    config(
        materialized='from_gcs_csv',
        schema='raw_reference',
        uris='gs://df_orig/depositor_report/64/depositor_report_*.csv',
        unexpected_col_count = 5,
        options='skip_leading_rows = 1,
          max_bad_records = 0,
          allow_quoted_newlines = true,
          allow_jagged_rows = true',
        enabled = false
    )
}}



--select
  id STRING,
  cid STRING,
  alias STRING,
  email STRING,
  site1 STRING,
  firstname STRING,
  lastname STRING,
  personalid STRING,
  address1 STRING,
  address2 STRING,
  city STRING,
  state STRING,
  country STRING,
  post_code STRING,
  telephone STRING,
  mobile_phone STRING,
  playerclass STRING,
  currency STRING,
  affiliateid STRING,
  trackerid STRING,
  ep_tag STRING,
  player_status STRING,
  subscribed_email STRING,
  subscribed_sms STRING,
  subscribed_post STRING,
  subscribed_phone_call STRING,
  subscribed_3rd_parties STRING,
  exclusion STRING,
  real_balance STRING,
  bonus_balance STRING,
  points STRING,
  wagered_bingo STRING,
  bingo_wager_for_the_date_period STRING,
  wagered_ig STRING,
  ig_wager_for_the_date_period STRING,
  bingo_total_win STRING,
  ig_total_win STRING,
  deposited STRING,
  ftd_amount STRING,
  deposits_for_the_date_period STRING,
  number_of_deposits_for_the_date_period STRING,
  netcash STRING,
  net_cash_for_the_date_per_iod STRING,
  promo_code STRING,
  dob STRING,
  age STRING,
  gender STRING,
  regdate STRING,
  registration_device_type STRING,
  last_play_date_bingo STRING,
  last_play_date_ig STRING,
  first_fund_date STRING,
  last_fund_date STRING,
  affiliate_platform STRING,
  last_login_date STRING,
  last_login_device_type STRING,
  number_of_deposits STRING,
  biggest_bingo_win STRING,
  biggest_ig_win STRING,
  bingo_free_games_played STRING,
  bingo_paid_games_played STRING,
  siteurl STRING,
  totalvoiddeposits STRING,
  totalchargebacks STRING
--from uris
