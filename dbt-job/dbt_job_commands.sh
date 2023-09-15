#!/bin/sh
dbt deps
dbt seed
dbt run --profiles-dir .

