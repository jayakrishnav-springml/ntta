CREATE TABLE IF NOT EXISTS EDW_TER.Violator_Summary
(
  violator_id NUMERIC(29),
  violator_fname STRING NOT NULL,
  violator_lname STRING NOT NULL,
  phone_nbr STRING NOT NULL,
  email_addr STRING NOT NULL,
  admin_fee INT64 NOT NULL,
  admin_fee2 INT64 NOT NULL,
  violation_tolls BIGNUMERIC(40, 2) NOT NULL,
  tolls_due BIGNUMERIC(40, 2) NOT NULL,
  lic_plate_nbr STRING NOT NULL,
  lic_plate_state STRING NOT NULL,
  vehicle_make STRING NOT NULL,
  vehicle_model STRING NOT NULL,
  vehicle_body STRING NOT NULL,
  vehicle_year STRING NOT NULL,
  vehicle_color STRING NOT NULL,
  docno STRING NOT NULL,
  vin STRING NOT NULL,
  last_invoice_id NUMERIC(29),
  tolltag_acct_id NUMERIC(29),
  insert_date DATETIME NOT NULL,
  load_datetime DATETIME NOT NULL
)
;