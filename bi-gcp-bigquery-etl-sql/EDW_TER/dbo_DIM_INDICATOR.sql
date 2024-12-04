CREATE TABLE IF NOT EXISTS EDW_TER.Dim_Indicator
(
  indicator_id INT64 NOT NULL,
  yes_no_abbrev STRING NOT NULL,
  indicator STRING NOT NULL
)
CLUSTER BY indicator_id
;
