dbt run --vars '{scenario: A}'

dbt run --vars '{scenario: A, replay_process_time: 2020-01-01 00:00:00 UTC}'

dbt run --models cycle_hire_cycle_stations_raw

dbt run --vars '{scenario: A}' --full-refresh

dbt test --models dim_date

dbt run --vars '{replay_process_time: 2015-01-01 00:00:00 UTC}'

dbt run --exclude tag:ml_model

dbt run --model tag:weather --full-refresh

-- to simulate running a few days of changes
dbt seed
dbt run --vars '{replay_process_time: 2015-01-04 00:00:00 UTC}'  --exclude tag:ml_model
dbt run --vars '{replay_process_time: 2016-01-01 00:00:00 UTC}'  --exclude tag:ml_model
dbt run  --exclude tag:ml_model
dbt run  --model tag:ml_model
