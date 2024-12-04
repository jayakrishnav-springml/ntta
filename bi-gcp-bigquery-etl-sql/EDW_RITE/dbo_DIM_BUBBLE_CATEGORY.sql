## Translation time: 2024-03-21T20:56:06.764423Z
## Translation job ID: e212c5d3-a7fa-4886-93b1-cb3be341e70a
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_RITE/Tables/dbo_DIM_BUBBLE_CATEGORY.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_RITE.Dim_Bubble_Category
(
  bubl_cat_id INT64 NOT NULL,
  bubl_cat_code STRING NOT NULL,
  bubl_cat_desc STRING NOT NULL,
  bubl_cat_source_id INT64 NOT NULL,
  bubl_cat_source_desc STRING NOT NULL,
  bubl_cat_ix INT64,
  bubl_cat_level INT64,
  bubl_disp_order STRING,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
