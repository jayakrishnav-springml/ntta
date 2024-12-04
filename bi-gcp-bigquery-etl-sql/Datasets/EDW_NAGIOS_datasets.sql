CREATE SCHEMA IF NOT EXISTS EDW_NAGIOS
DEFAULT COLLATE 'und:ci'
OPTIONS(
  location="us-south1",
  is_case_insensitive=TRUE,
  storage_billing_model="PHYSICAL"
  );
  
CREATE SCHEMA IF NOT EXISTS EDW_NAGIOS_STAGE
DEFAULT COLLATE 'und:ci'
OPTIONS(
  location="us-south1",
  is_case_insensitive=TRUE,
  storage_billing_model="PHYSICAL"
  );

CREATE SCHEMA IF NOT EXISTS EDW_NAGIOS_SUPPORT
DEFAULT COLLATE 'und:ci'
OPTIONS(
  location="us-south1",
  is_case_insensitive=TRUE,
  storage_billing_model="PHYSICAL"
  );

CREATE SCHEMA IF NOT EXISTS EDW_NAGIOS_DELETE
DEFAULT COLLATE 'und:ci'
OPTIONS(
  location="us-south1",
  is_case_insensitive=TRUE,
  storage_billing_model="PHYSICAL"
  );