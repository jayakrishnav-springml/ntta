CREATE TABLE IF NOT EXISTS EDW_TRIPS_SUPPORT.Citation
(
  violator_id INT64,
  partition_date DATE,
  daydate DATETIME,
  first_citation_nbr STRING,
  last_citation_nbr STRING,
  county STRING,
  partition_date0 DATE,
  data_as_of_date DATE NOT NULL,
  address1 STRING,
  county_group STRING NOT NULL,
  citation_nbr_list STRING,
  vbi_invoice_id INT64,
  feesdue NUMERIC(33, 4),
  feespaid NUMERIC(33, 4),
  tollsdue NUMERIC(33, 4),
  tollspaidadjtxn BIGNUMERIC(46, 8),
  tollsonpaid NUMERIC(33, 4)
)
;