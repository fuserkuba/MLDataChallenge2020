CREATE OR REPLACE TABLE
  `mldatachallenge2020.augmented_data.train_examples`
PARTITION BY
  RANGE_BUCKET(example_number,
    GENERATE_ARRAY(1,450000,500)) AS
SELECT
  examples.example_number,
  examples.example_id,
  examples.item_bought,
  STRUCT(item_bought AS item_id,
    items_dt.category_id,
    items_dt.domain_id,
    items_dt.price,
    items_dt.title,
    items_dt.condition,
    items_dt.product_id) AS item_bought_full,
  user_history,
  events_qty,
  start_date,
  end_date,
  duration_hours,
  examples.views,
  examples.views_qty,
  example_items.items,
  examples.searchs,
  examples.searchs_qty
FROM
  `mldatachallenge2020.processed_data.train_examples` AS examples
LEFT JOIN
  `mldatachallenge2020.input_data.items_dataset` AS items_dt
ON
  examples.item_bought=items_dt.item_id
LEFT JOIN (
  SELECT
    example_number,
    ARRAY_AGG( STRUCT(CAST(items.item_id AS INT64) AS item_id,
        items.event_timestamp AS view_timestamp,
        items_dt.category_id,
        items_dt.domain_id,
        items_dt.price,
        items_dt.title,
        items_dt.condition,
        items_dt.product_id)
    ORDER BY
      items.event_timestamp DESC) AS items
  FROM
    `mldatachallenge2020.processed_data.train_examples`,
    UNNEST(views) AS items
  LEFT JOIN
    `mldatachallenge2020.input_data.items_dataset` AS items_dt
  ON
    CAST(items.item_id AS INT64)=items_dt.item_id
  GROUP BY
    example_number ) example_items
USING
  (example_number)