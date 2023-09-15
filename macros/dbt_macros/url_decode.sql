{% macro url_decode(url_variable) %}
  (select string_agg(if(regexp_contains(y, r'^%[0-9a-fA-F]{2}'), safe_convert_bytes_to_string(from_hex(replace(y, '%', ''))), y), '' order by i) from unnest(regexp_extract_all({{url_variable}}, r"%[0-9a-fA-F]{2}(?:%[0-9a-fA-F]{2})*|[^%]+")) y with offset as i)
{% endmacro %}
