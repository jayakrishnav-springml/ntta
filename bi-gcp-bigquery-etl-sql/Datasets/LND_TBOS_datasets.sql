CREATE SCHEMA IF NOT EXISTS LND_TBOS
DEFAULT COLLATE 'und:ci'
OPTIONS(
  location="us-south1",
  is_case_insensitive=TRUE,
  storage_billing_model="PHYSICAL"
  );
  
CREATE SCHEMA IF NOT EXISTS LND_TBOS_STAGE_CDC
DEFAULT COLLATE 'und:ci'
OPTIONS(
  location="us-south1",
  is_case_insensitive=TRUE,
  storage_billing_model="PHYSICAL"
  );


CREATE SCHEMA IF NOT EXISTS LND_TBOS_STAGE_FULL
DEFAULT COLLATE 'und:ci'
OPTIONS(
  location="us-south1",
  is_case_insensitive=TRUE,
  storage_billing_model="PHYSICAL"
  );
  
CREATE SCHEMA IF NOT EXISTS LND_TBOS_SUPPORT
DEFAULT COLLATE 'und:ci'
OPTIONS(
  location="us-south1",
  is_case_insensitive=TRUE,
  storage_billing_model="PHYSICAL"
  );

CREATE SCHEMA IF NOT EXISTS LND_TBOS_DELETE
DEFAULT COLLATE 'und:ci'
OPTIONS(
  location="us-south1",
  is_case_insensitive=TRUE,
  storage_billing_model="PHYSICAL"
  );

CREATE SCHEMA IF NOT EXISTS LND_TBOS_ARCHIVE
DEFAULT COLLATE 'und:ci'
OPTIONS(
  location="us-south1",
  is_case_insensitive=TRUE,
  storage_billing_model="PHYSICAL"
  );
  
