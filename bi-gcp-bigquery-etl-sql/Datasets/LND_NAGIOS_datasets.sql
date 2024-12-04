CREATE SCHEMA IF NOT EXISTS LND_NAGIOS
DEFAULT COLLATE 'und:ci'
OPTIONS(
  location="us-south1",
  is_case_insensitive=TRUE,
  storage_billing_model="PHYSICAL"
  );
  
  
CREATE SCHEMA IF NOT EXISTS LND_NAGIOS_SUPPORT
DEFAULT COLLATE 'und:ci'
OPTIONS(
  location="us-south1",
  is_case_insensitive=TRUE,
  storage_billing_model="PHYSICAL"
  );


CREATE SCHEMA IF NOT EXISTS LND_NAGIOS_STAGE_CDC
DEFAULT COLLATE 'und:ci'
OPTIONS(
  location="us-south1",
  is_case_insensitive=TRUE,
  storage_billing_model="PHYSICAL"
  );


CREATE SCHEMA IF NOT EXISTS LND_NAGIOS_STAGE_FULL
DEFAULT COLLATE 'und:ci'
OPTIONS(
  location="us-south1",
  is_case_insensitive=TRUE,
  storage_billing_model="PHYSICAL"
  );
