# dbt-project-template
 Starter project template for all new projects


# Installation prerequisites
- Within a conda env, use the package manager [pip](https://pip.pypa.io/en/stable/) to install the dev requirements outlined in requirements.txt
- To create a new conda env `conda create -n ENV_NAME python=3.9` then run `conda activate ENV_NAME` and finally `pip install -r requirements.txt`
- Run `pre-commit install` to set up your git hook scripts. This will set your hooks so that the next time you commit, pre-commit will be invoked (note: on its first invocation, pre-commit will need to install its own dependencies which may take a minute; these dependencies will be installed outside of your project and will be available from that moment onwards).

```bash
pip install -r requirements.txt
pre-commit install
```

## dbt configuration
### Profile

In order to use the template, add the following to your ~/.dbt/profiles.yml file, taking care to replace the value of the `project` and `dataset` and `location` parameter wtih appropriate values. Note the profile provided is called `sandbox` - rename this and update `dbt_project.yml` ln 8 to match.
If you don't already have a profiles file, create a new one.

```
sandbox:
  target: dev
  outputs:
    dev:
      type: bigquery
      method: oauth
      project: data-sandbox-266217
      dataset: dbt_tl
      threads: 8
      location: EU
```
### Using the project:

Once everything has been setup, try running the following commands:

- dbt debug (if you're having issues)
- dbt deps
- dbt seed
- dbt run
- dbt test

## Working with Pre-Commit
- Pre-commit is configured to run various checks automatically when you attempt to commit your code.
- Pre-commit will only run against changed files to keep its execution as quick as possible.
- On its first execution, pre-commit will install any dependencies it needs into a virtual environment (located outside of this repo); this may take a few minutes on its first run, but every following run will reuse that env and as a result will be much quicker.

### Notes around versioning
- Take note to appropriately update versions in .pre-commit-config.yaml and requirements.txt

## Working with SQLFluff
- SQLFluff is used to enforce formatting guidelines.
- SQLFluff lint is configured as a pre-commit hook that runs on commit, so in most cases no explicit commands are needed. This will only list errors and will not fix any errors if found.
- If you would like to run SQLFluff lint manually, you can do so with the following commands which will run them through pre-commit. 
```bash
pre-commit run --hook-stage commit sqlfluff-lint --all-files
```

### SQLFluff active rules

| **SQLFluff Rule** | **Description** | **Configuration** |
| ----- | ----- | ----- |
|[L002](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L002)       |Mixed Tabs and Spaces in single whitespace. This rule will fail if a single section of whitespace contains both tabs and spaces.       |None       |
|[L005](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L005)       | Commas should not have whitespace directly before them. Unless it’s an indent. Trailing/leading commas are dealt with in a different rule.       |None      |
|[L006](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L006)       |Operators should be surrounded by a single whitespace.       |None       |
|[L010](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L010)       |Inconsistent capitalisation of keywords.       |capitalisation_policy = lower       |
|[L011](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L011)       |Implicit/explicit aliasing of table. Aliasing of table to follow preference, e.g explict AS.        |aliasing = explicit       |
|[L012](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L012)       |Implicit/explicit aliasing of columns. Aliasing of columns to follow preference, e.g explict AS.       |aliasing = explicit       |
|[L013](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L013)       |Column expression without alias. Use explicit AS clause.       |None       |
|[L014](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L014)       |Inconsistent capitalisation of unquoted identifiers.       |extended_capitalisation_policy = lower       |
|[L015](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L015)       |DISTINCT used with parentheses.       |None       |
|[L017](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L017)       |Function name not immediately followed by parenthesis.       |None       |
|[L018](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L018)       |WITH clause closing bracket should be on a new line.       |None       |
|[L019](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L019)       |Leading/Trailing comma enforcement.       |trailing       |
|[L020](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L020)       |Table aliases should be unique within each clause.       |None       |
|[L021](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L021)       |Ambiguous use of DISTINCT in a SELECT statement with GROUP BY. When using GROUP BY a DISTINCT` clause should not be necessary as every non-distinct SELECT clause must be included in the GROUP BY clause.       |None       |
|[L022](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L022)       |Blank line expected but not found after CTE closing bracket.       |None       |
|[L023](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L023)       |Single whitespace expected after AS in WITH clause.       |None       |
|[L024](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L024)       |Single whitespace expected after USING in JOIN clause.       |None       |
|[L025](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L025)       |Tables should not be aliased if that alias is not used.       |None       |
|[L027](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L027)       |References should be qualified if select has more than one referenced table/view. |None       |
|[L030](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L030)       |Inconsistent capitalisation of function names. |extended_capitalisation_policy = lower      |
|[L035](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L035)       |Do not specify else null in a case when statement (redundant). |None      |
|[L036](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L036)       |Select targets should be on a new line unless there is only one select target. |None |
|[L037](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L037)       |Ambiguous ordering directions for columns in order by clause. |None |
|[L038](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L038)       |Trailing commas within select clause. |select_clause_trailing_comma = forbid |
|[L040](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L040)       |Inconsistent capitalisation of boolean/null literal. |capitalisation_policy = lower |
|[L041](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L041)       |SELECT modifiers (e.g. DISTINCT) must be on the same line as SELECT. |None |
|[L042](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L042)       |Join/From clauses should not contain subqueries. Use CTEs instead. |None |
|[L044](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L044)       |Query produces an unknown number of result columns. |None |
|[L045](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L045)       |Query defines a CTE (common-table expression) but does not use it. |None |
|[L046](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L046)       |Jinja tags should have a single whitespace on either side. |None |
|[L047](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L047)       |Use consistent syntax to express “count number of rows”. |None |
|[L049](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L049)       |Comparisons with NULL should use “IS” or “IS NOT”. |None |
|[L050](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L050)       |Files must not begin with newlines or whitespace. |None |
|[L051](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L051)       |Join clauses should be fully qualified. |fully_qualify_join_types = both |
|[L054](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L054)       |Inconsistent column references in GROUP BY/ORDER BY clauses. |group_by_and_order_by_style = consistent |
|[L055](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L055)       |Use LEFT JOIN instead of RIGHT JOIN. |None |
|[L058](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L058)       |Nested CASE statement in ELSE clause could be flattened. |None |
|[L060](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L060)       |Use COALESCE instead of IFNULL or NVL. |None |
|[L065](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L065)       |Set operators should be surrounded by newlines. |None |
|[L066](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L066)       |Enforce table alias lengths in from clauses and join conditions. |min_alias_length = 3, max_alias_length = 25 |
|[L071](https://docs.sqlfluff.com/en/stable/rules.html#sqlfluff.rules.Rule_L071)       |Parenthesis blocks should be surrounded by whitespaces. |None |

## Working with dbt-gloss
- dbt-gloss is used to enforce dbt project structure.
- dbt-gloss is configured as a pre-commit hook that runs on commit, so in most cases no explicit commands are needed. This will only list errors and will not fix any errors if found.
- If you would like to run dbt-gloss manually, you can do so with the following commands which will run them through pre-commit. 
```bash
pre-commit run {{dbt-gloss hook_id}} --hook-stage commit --all-files
```

### dbt-gloss active hooks

| **dbt-gloss hook** | **Description** | **Configuration** |
| ----- | ----- | ----- |
|[dbt-run](https://github.com/Montreal-Analytics/dbt-gloss/blob/main/HOOKS.md#dbt-run)       |Ensures that changed files pass dbt run.    |None       |
|[check-source-has-loader](https://github.com/Montreal-Analytics/dbt-gloss/blob/main/HOOKS.md#check-source-has-loader)       |Ensures that the source has a loader option in the properties file (usually sources.yml).    |None       |
|[check-source-has-all-columns](https://github.com/Montreal-Analytics/dbt-gloss/blob/main/HOOKS.md#check-source-has-all-columns)       |Ensures that all columns in the database are also specified in the properties file. (usually sources.yml).       |None       |
|[check-source-table-has-description](https://github.com/Montreal-Analytics/dbt-gloss/blob/main/HOOKS.md#check-source-table-has-description)       |Ensures that the source table has a description in the properties file (usually sources.yml).       |None       |
|[check-model-has-properties-file](https://github.com/Montreal-Analytics/dbt-gloss/blob/main/HOOKS.md#check-model-has-properties-file)       |Ensures that the model has a properties file (models.yml).       |None       |
|[check-model-has-all-columns](https://github.com/Montreal-Analytics/dbt-gloss/blob/main/HOOKS.md#check-model-has-all-columns)       |Ensures that all columns in the database are also specified in the properties file. (usually models.yml).       |None       |
|[check-model-has-description](https://github.com/Montreal-Analytics/dbt-gloss/blob/main/HOOKS.md#check-model-has-description)       |Ensures that the model has a description in the properties file (usually models.yml).       |None       |
# SQL style guide

## General

- **All** sql reserved keywords should be in lowercase. e.g **select** and not **SELECT**
- Do not use **select * from**, an exception to this is if you are selecting all columns from a CTE that is already selecting specific columns. e.g. the CTE is acting as a pass through.
    
    ```sql
    -- bad
    select * from product;
    
    -- OK
    with product_dependency as (
    	select
    		product_id,
    		product_name
    	from product
    	where 1 = 1
    	and product_id is not null
    )
    
    select
    	*
    from product_dependency;
    
    -- preferred
    with product_dependency as (
    	select
    		product_id,
    		product_name
    	from product
    	where 1 = 1
    	and product_id is not null
    )
    
    select
    	product_id,
    	product_name
    from product_dependency
    ```
    
- Within a select statement place commas at the end of the line.
    
    ```sql
    select
    	1 as col1,
    	2 as col2,
    from test
    ```
    
    - Each column in a select statement should be on a newline. Moreover do not include any columns on the same line as the ************select************ and **********from.**********
- When aliasing columns be consistent at which column val
- The **************select,************** **********from,********** ************where, qualify, group by, having************ and **********limit********** clauses should be at the same indentation.
    - ************where:************ the first clause should be on the same line as the where statement itself. If you using multiple clauses the first clause should be where 1 = 1.
        
        ```sql
        select
        	product
        from test
        where 1 = 1
        and product not like '%xbox%'
        ```
        
    - ******************group by:****************** if grouping by positions keep it all on the same line as the group by clause otherwise do not and also indent by 1.
        
        ```sql
        group by 1,2,3
        
        vs
        
        group by
        	product_type,
        	sales_id,
        	product_id
        ```
        
- When using case statements, each component of the case statement should be on a new line and when/then should be a single indentation from the outer components.
    
    ```sql
    select
    	case
    		when 1=1
    		then true
    		else false
    	end as col1
    from x
    	
    ```
    
    ## Common table expressions (CTE)
    
- Try to name CTEs with their purpose in mind, try not to use names like ‘cte1’, ‘cte2’. A good example would be ************************product_dependency.************************
- Use CTEs to breakup complex code.
- Use CTEs to capture model dependencies and apply necessary filtering within the CTE (select needed columns and filter early - this is the way!)
    
    ```sql
    with orders_dependency as (
    	select
    		order_id,
    		order_name,
    		...
    	from orders
    	where 1 = 1
    	and meta_is_valid = 1
    	and order_id is not null
    )
    
    products_dependency as (
    	select
    		product_id,
    		product_name,
    		...
    	from product
    	where 1 = 1
    	and meta_is_valid = 1
    	and product_id is not null
    )
    ```
    
- When formatting CTEs
    - Do not indent CTE name.
    - Keep the open bracket on the same line as the CTE name. Put the closing bracket on its own line at the end with the indentation the same as the CTE name.
    - The select statement should be indented by 1 tab from the CTE name, all other formatting/indentation rules then apply.
    - Keep a 1 line gap between end of CTE and start of next CTE/final select.

## SQL tips

- New lines are cheap, brain power is expensive.
- Use **exists** and **not exists** rather than ******in****** and **not in**

# dbt standards

We have these standards in place to ensure we maintain consistency across our projects, so if for example, you have to switch to help on a different project you will be familiar with the overall structure, naming etc to quickly become productive!

## Language

English should be used for all table/view names, dbt schema column descriptions and comments in dbt models. This also applies to variable names in Jinja where applicable.

## dbt project naming standards

We use the convention **<client>**_data for naming dbt projects e.g. s24_data. Project names are lowercase and contain underscores.

## GitHub repo naming standards

Every dbt project should be linked to a designated Github repo. These should be named **<dbt_project_name>**-dbt → e.g. s24-data-dbt

Note “-” are used instead of underscores.

## Logical dwh layers in BigQuery

In BigQuery, we separate the dwh into 5 logical layers. Each layer is optimised for data ingestion, storage, transformation or consumption. The 5 layers are:

- raw (ingestion)
- archive (storage)
- clean (storage)
- staging (transformation)
- presentation (consumption)

Our approach closely follows the factory model, where raw materials (source data) is delivered, checked (cleaned), stored (archived), and finally manufactured (transformed) into high-value products (data assets).

### BigQuery dataset naming

| Layer | Template | Example |
| --- | --- | --- |
| Raw | dw_raw_<source> | dw_raw_fs24_creditscout |
| Archive | dw_archive_<source> | N/A |
| Clean | dw_clean_<source> | dw_clean_fs24_creditscout |
| Stage | dw_pl_<biz process or product>_stage | dw_pl_financescout24_stage |
| Presentation | dw_pl_<biz process or product> | dw_pl_financescout24 |

Notes

- pl 	= Presentation Layer
- dw	= Data Warehouse

## Presentation layer “zones”

The presentation layer is split into logical zones. Each zone represents a business process or product. In addition, we have a designated zone called dw_pl_reference that contains assets that are shared across zones (for example, dim_date is in dw_pl_reference).

## Model folder structure in dbt

To ensure the horizontal scalability, we pay careful attention to how we organise the model folders in the dbt project. We have standards for both the structure and folder names. The key folders are:

| Folder | Overview |
| --- | --- |
| analysis | Supporting ad-hoc files, relating to Apex24, for example useful dbt commands and shell scripts. |
| analysis/cloud functions | Sometimes we need Cloud Functions to support more advanced dbt use cases.. |
| analysis/sql queries | Any helpful ad-hoc SQL. |
| analysis/utilities | Mostly Python utilities we have written to support various use cases. Note the magnificent_model_maker and the magnificent_schema_maker are in this folder. |
| data | This folder contains dbt seeds. These are csvs that dbt will convert to a physical table. Useful for static data that changes very little. |
| dbt_packages | Installed packages reside here. |
| macros | Standard dbt macros together with custom macros we have developed e.g. clean_numeric, scd2_history. |
| models/00_dw_utils | Any functionality specific to running the dwh itself resides here. For example, we have an example table called cloud_function_error (note this is disabled) that we use on projects to trigger a cloud function when a row is inserted. |
| models/01_dw_raw_backfill | Raw layer containing tables used to backfill legacy data. e.g. backfill_autoscout24_vehicleidperday - BQ datasets: dw_raw_backfill & dw_clean_backfill |
| models/02_dw_raw/ | Raw and clean layers. Note we have a sub folder for each source. Raw contains tables landed into BQ.  e.g. raw_mssql_crm, raw_reference. Clean contains tables that have the following transformations applied from raw: 1) Data type conversion/cleaning. 2) Column renaming to follow standards. 3)We include a meta_is_valid and meta_is_valid_reason so we can mark records as invalid, for example if they are missing a key. e.g. table dw_clean_crm.contactbase_clean - BQ datasets: dw_raw_<source> & dw_clean_<source> |
| models/03_dw_raw_stage | Staging layer to help complex transformations from raw to clean. e.g. crm_account_clean - BQ dataset: dw_raw_<source>_stage |
| models/04_pl_<zone>_stage | Staging layer to help complex transformations from clean to the pl. For pl objects where the transformation from clean is simple, a staging object is not needed. e.g. 04_pl_crm_stage.salesorders_detail_stage -BQ dataset: dw_pl_<zone>_stage |
| models/05_pl_<zone> | Presentation Layer, serving high-value facts and dimensions for consumption. Look consumes data from the PL. e.g. 05_pl_fs24 |
| scratch | Any ad-hoc files relating to the project go here. For example, we sometimes put legacy code if migrating a data warehouse. |

## Model naming and field standards

### Tables

- Schema, table and column names should be in [snake_case](https://en.wikipedia.org/wiki/Snake_case)
- Dimensions should be prefixed dim_ e.g. **dim**_customer
- Facts (transactional) should be prefixed fact_ e.g. **fact**_order
- Facts (snapshots) should be suffixed _<period> e.g. **fact**_stock_level_**daily**
- Facts (accumulating) should be suffixed summary e.g. **fact**_order_**summary**
- Table names should be singular e.g. dim_account, fact_order

### Columns

- Date columns should be suffixed _date e.g. birth_**date,** month_**date**
- Time columns should be suffixed _time e.g. order_**time**
- Timestamp data type should be used for UTC only. Therefore, it is assumed a column of timestamp type in clean and beyond is displaying UTC. To encode a local time use a datetime type with the naming order_time_**<timezone>**
- Booleans should be prefixed with is_ e.g. **is**_cancelled
- Monetary fields should be suffixed _amount e.g. order_**amount**
- Where a non-local currency is needed, these should be provided as a column and suffixed e.g. order_amount_<**************************currency_code**************************>.
- Consistency is key! Use the same field names across models where possible.

### Meta columns

Meta columns describe the data warehouse itself and aid in lineage, auditing and troubleshooting.

All tables should have the following meta columns:

| Meta field | Description |
| --- | --- |
| meta_process_time | The start time the etl process that loaded this record. This can be in the past where we are replaying a previous run. In dbt this is the {{dbt_macros.meta_process_time()}} - this is UTC. |
| meta_delivery_time | When data arrived in the raw layer. |
| meta_source | Which source system the record was sourced from e.g. salesforce. This helps with data lineage and aids troubleshooting. |

Tables in the **clean** layer should include:

| Meta field | Description |
| --- | --- |
| meta_is_valid | Denotes if the record is usable. For example, set to 0 if the primary key is missing. |
| meta_is_valid_reason | This is used to describe why a record is not valid e.g. missing id |

**SCD2 events tables** in the PL should include:

| Meta field | Description |
| --- | --- |
| meta_scd_action | Denotes what prompted this record to be triggered. Options are: (insert, update, delete, reactivate) |
| meta_start_time | Represents when this change is effective from. |

**SCD2 dimension tables** in the PL should include:

| Meta field | Description |
| --- | --- |
| meta_scd_action | Denotes what prompted this record to be triggered.  Options are: (insert, update, delete, reactivate) |
| meta_start_time | Represents when this version of the dimension is effective from. |
| meta_end_time | Represents when this version of the dimension is effective to. Note if the record is active, this is set to a large timestamp value. |
| meta_is_latest | Represents if this is the most recent version of the record. Note a record can be deleted (meta_end_time in the past) and still have meta_is_latest = 1. |
