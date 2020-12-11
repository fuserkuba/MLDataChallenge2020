CREATE OR REPLACE TABLE
  mldatachallenge2020.augmented_data.train_domains AS
SELECT
  domain_id,
  coalesce(SUM( item_purchases ),
    0) AS purchases,
  coalesce(SUM( item_bought_views ),
    0) AS bought_views,
  coalesce(SUM( examples_with_item_view ),
    0) AS examples_with_views,
  coalesce(SUM( total_views ),
    0) AS total_views,
  COUNT(item_id) AS train_items,
  COUNTIF( coalesce(item_purchases,
      0) > 0) AS items_in_purchases,
  COUNTIF(coalesce(total_views,
      0) > 0) AS items_in_views,
  COUNTIF(coalesce(item_bought_views,
      0) > 0) AS items_in_bought_views,
  ARRAY_AGG(STRUCT (item_id,
      coalesce(item_purchases,
        0) AS purchases,
      coalesce(item_bought_views,
        0) AS bought_views,
      coalesce(examples_with_item_view,
        0) AS examples_with_wiew,
      coalesce(total_views,
        0) AS views,
      price,
      domain_id,
      category_id,
      condition,
      title,
      product_id)
  ORDER BY
    item_purchases DESC, total_views DESC) AS items
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
GROUP BY
  domain_id