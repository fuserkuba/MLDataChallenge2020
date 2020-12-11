CREATE OR REPLACE TABLE
  mldatachallenge2020.augmented_data.train_items AS
SELECT
  *
FROM (
  SELECT
    item_bought AS item_id,
    COUNT(DISTINCT example_number)AS item_purchases,
    SUM(viewed_bought) AS item_bought_views
  FROM
    `mldatachallenge2020.augmented_data.train_examples_augmented_items`
  GROUP BY
    item_bought
  ORDER BY
    item_purchases DESC ) boughts
FULL OUTER JOIN (
  SELECT
    full_item.item_id AS item_id,
    COUNT(DISTINCT example_number) AS examples_with_item_view,
    COUNT(*) AS total_views
  FROM
    `mldatachallenge2020.augmented_data.train_examples_augmented_items`,
    UNNEST(items) full_item
  GROUP BY
    full_item.item_id ) views
USING
  (item_id)
LEFT JOIN
  `mldatachallenge2020.input_data.items_dataset`
USING
  (item_id)