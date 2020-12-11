CREATE OR REPLACE TABLE
  mldatachallenge2020.processed_data.train_examples 
  partition by RANGE_BUCKET(example_number,GENERATE_ARRAY(1,450000,500))
  AS
SELECT
  ROW_NUMBER() OVER() AS example_number,
  GENERATE_UUID() as example_id,
  item_bought,
  user_history,
  ARRAY_LENGTH(user_history) as events_qty,
    (
  SELECT
    MIN(TIMESTAMP(event_timestamp))
  FROM
    UNNEST(user_history)) as start_date,
  (
  SELECT
    MAX(TIMESTAMP(event_timestamp))
  FROM
    UNNEST(user_history)) as end_date,
     (
  SELECT
   TIMESTAMP_DIFF(MAX(TIMESTAMP(event_timestamp)), MIN(TIMESTAMP(event_timestamp)),MINUTE)/60
  FROM
    UNNEST(user_history)) as duration_hours,
  ARRAY(
  SELECT
    AS STRUCT event_info AS item_id,
    event_timestamp
  FROM
    UNNEST(user_history)
  WHERE
    event_type='view'
  ORDER BY
    event_timestamp DESC) AS views,
  array_length(ARRAY(
  SELECT
    AS STRUCT event_info AS item_id,
    event_timestamp
  FROM
    UNNEST(user_history)
  WHERE
    event_type='view')) as views_qty,
  ARRAY(
  SELECT
    AS STRUCT event_info AS info,
    event_timestamp
  FROM
    UNNEST(user_history)
  WHERE
    event_type='search'
  ORDER BY
    event_timestamp DESC) AS searchs,
  ARRAY_LENGTH(ARRAY(
  SELECT
    AS STRUCT event_info AS info,
    event_timestamp
  FROM
    UNNEST(user_history)
  WHERE
    event_type='search'
 )) as searchs_qty
FROM
  `mldatachallenge2020.input_data.train_dataset`