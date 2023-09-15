-- below is uself to drop all datasets. Note change suffix depending on your profiles.yml
bq rm -r -d -f dw_raw_general
bq rm -r -d -f dw_raw_cycle_hire
bq rm -r -d -f dw_pl_reference
bq rm -r -d -f dw_pl_reference_stage
bq rm -r -d -f dw_pl_journeys
