#!/bin/sh
dbt seed
dbt run --profiles-dir .

