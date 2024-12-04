CREATE TABLE IF NOT EXISTS EDW_TER.Dim_Zipcode_Save_20160927
(
  zipcode STRING NOT NULL,
  zipcode_latitude BIGNUMERIC(50, 12) NOT NULL,
  zipcode_longitude BIGNUMERIC(50, 12) NOT NULL,
  county STRING,
  county_group STRING NOT NULL
)
;