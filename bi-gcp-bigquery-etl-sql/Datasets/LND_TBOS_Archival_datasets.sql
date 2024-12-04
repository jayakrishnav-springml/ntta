CREATE SCHEMA IF NOT EXISTS LND_TBOS_ARCHIVE_IDS
DEFAULT COLLATE 'und:ci'
OPTIONS(
  location="us-south1",
  is_case_insensitive=TRUE,
  storage_billing_model="PHYSICAL"
  );
  
CREATE SCHEMA IF NOT EXISTS LND_TBOS_ARCHIVE_IDS_STAGE_FULL
DEFAULT COLLATE 'und:ci'
OPTIONS(
  location="us-south1",
  is_case_insensitive=TRUE,
  storage_billing_model="PHYSICAL"
  );


CREATE SCHEMA IF NOT EXISTS LND_TBOS_ARCHIVE_IDS_SUPPORT
DEFAULT COLLATE 'und:ci'
OPTIONS(
  location="us-south1",
  is_case_insensitive=TRUE,
  storage_billing_model="PHYSICAL"
  );
 
CREATE SCHEMA IF NOT EXISTS ARCHIVE_IDS_VALIDATION
DEFAULT COLLATE 'und:ci'
OPTIONS(
  location="us-south1",
  is_case_insensitive=TRUE,
  storage_billing_model="PHYSICAL"
  ); 
  
 CREATE SCHEMA IF NOT EXISTS LND_TBOS_ARCHIVE_IDS_STAGE
DEFAULT COLLATE 'und:ci'
OPTIONS(
  location="us-south1",
  is_case_insensitive=TRUE,
  storage_billing_model="PHYSICAL"
  );
  