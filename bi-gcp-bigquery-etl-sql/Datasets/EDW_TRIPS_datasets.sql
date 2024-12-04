CREATE SCHEMA IF NOT EXISTS EDW_TRIPS
DEFAULT COLLATE 'und:ci'
OPTIONS(
  location="us-south1",
  is_case_insensitive=TRUE,
  storage_billing_model="PHYSICAL"
  );
  
CREATE SCHEMA IF NOT EXISTS EDW_TRIPS_STAGE
DEFAULT COLLATE 'und:ci'
OPTIONS(
  location="us-south1",
  is_case_insensitive=TRUE,
  storage_billing_model="PHYSICAL"
  );

CREATE SCHEMA IF NOT EXISTS EDW_TRIPS_SUPPORT
DEFAULT COLLATE 'und:ci'
OPTIONS(
  location="us-south1",
  is_case_insensitive=TRUE,
  storage_billing_model="PHYSICAL"
  );


