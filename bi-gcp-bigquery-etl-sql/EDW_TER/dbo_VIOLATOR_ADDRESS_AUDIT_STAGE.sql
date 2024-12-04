CREATE TABLE IF NOT EXISTS EDW_TER.Violator_Address_Audit_Stage
(
  violator_id NUMERIC(29),
  violator_addr_seq INT64,
  address1 STRING,
  address2 STRING,
  city STRING,
  state STRING,
  zip_code STRING,
  plus4 STRING,
  created_by STRING,
  date_created DATETIME,
  modified_by STRING,
  date_modified DATETIME
)
cluster by violator_id
;