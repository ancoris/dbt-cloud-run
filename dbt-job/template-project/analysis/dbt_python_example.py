def model(dbt, session):
    dbt.config(
        materialized="table",
        schema="python_model",
        submission_method="serverless"
    )

    # DataFrame
    cycle_stations = dbt.ref("cycle_stations_clean")

    return cycle_stations
