------------------------------------------------------------------------------------------------------------------------
-- Author: TL
-- Simple adjustment to native is_incremental() macro so that it works with our custom archive materialisation
------------------------------------------------------------------------------------------------------------------------

{% macro is_incremental_archive() %}
    {#-- do not run introspective queries in parsing #}
    {% if not execute %}
        {{ return(False) }}
    {% else %}
        {% set relation = adapter.get_relation(this.database, this.schema, this.table) %}
        {{ return(relation is not none
                  and relation.type == 'table'
                  and model.config.materialized == 'archive_incremental') }}
    {% endif %}
{% endmacro %}
