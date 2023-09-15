-- this model is an example of the 'from_gcs_csv' materialization

{{
    config(
        materialized='from_gcs_json',
        schema='raw_reference',
        uris='gs://data-sandbox-266217-misc-data/from_gcs_json_example.jsonl',
        options='max_bad_records = 0,
          ignore_unknown_values = true',
        enabled = false

    )
}}

--select
instance 	struct<
  content string,
  mimeType string
  >,
prediction 	struct<
  ids array<string>,
  displayNames array<string>,
  confidences array<string>
  >
--from uris

/* TIPS:
1. if the data has [square brackets] around it then it is an array. Even if there is only [one] piece of data in there!
2. JSON is very sensitive to quotes. If the data is means to be string it must be quoted properly
  right: "key":"string_value"
  wrong: "key":string_value
  numbers can be excluded from this.
  this works: "key": 0.1234
*/
