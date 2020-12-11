CREATE OR REPLACE TABLE
  `mldatachallenge2020.augmented_data.train_examples_augmented_items`
PARTITION BY
  RANGE_BUCKET(example_number,
    GENERATE_ARRAY(1,450000,500)) AS
SELECT
example_number, example_id, item_bought, item_bought_full, events_qty, start_date, end_date, duration_hours, views, views_qty
, (select count(all_items.item_id) from unnest(items) all_items where all_items.item_id=item_bought) as viewed_bought
, (select item from unnest(items) item order by count(item.item_id) over(PARTITION BY item_id) desc limit 1) as frequent_item
, (select item from unnest(items) item order by item.view_timestamp desc limit 1) as recent_item
, (select item from unnest(items) item order by item.view_timestamp asc limit 1) as old_item
, (select item from unnest(items) item order by item.price asc limit 1) as cheaper_item
, (select item from unnest(items) item order by item.price desc limit 1) as expensive_item
, (select item.domain_id from unnest(items) item order by count(item.item_id) over(PARTITION BY domain_id) desc limit 1) as frequent_domain
, (select item.domain_id from unnest(items) item order by count(distinct item.item_id) over(PARTITION BY domain_id) desc limit 1) as frequent_distinct_domain
, items
, searchs
, searchs_qty
FROM `mldatachallenge2020.augmented_data.train_examples`