CREATE SCHEMA IF NOT EXISTS EDW_NAGIOS_APS
DEFAULT COLLATE 'und:ci'
OPTIONS(
  location="us-south1",
  is_case_insensitive=TRUE,
  storage_billing_model="PHYSICAL"
  );
  
CREATE SCHEMA IF NOT EXISTS EDW_NAGIOS_STAGE_APS
DEFAULT COLLATE 'und:ci'
OPTIONS(
  location="us-south1",
  is_case_insensitive=TRUE,
  storage_billing_model="PHYSICAL"
  );