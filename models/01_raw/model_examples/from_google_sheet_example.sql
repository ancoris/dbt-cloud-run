{{
    config(
        materialized='from_google_sheet',
        schema='raw_reference',
        uris='https://docs.google.com/spreadsheets/d/1q2iiN2dtSQtajkckeEwEAdzXrOureNHh4rWe4E8oYRs/edit#gid=1675742991',
        options='sheet_range = "brand_ref!B2:J",
          skip_leading_rows = 0,
          max_bad_records = 0',
        enabled = false
    )
}}
--FYI, Sheet materlisations will need to give the dbt service account access to the sheet. GJ
--select
  casino STRING,
  abbreviation STRING,
  df_skin_id STRING,
  network STRING,
  type STRING,
  network_category STRING,
  alt_abbreviation STRING,
  gre_list_name STRING,
  network_id STRING
--from uris
