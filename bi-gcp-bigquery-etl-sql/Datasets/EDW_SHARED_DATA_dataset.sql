CREATE SCHEMA IF NOT EXISTS EDW_SHARED_DATA
DEFAULT COLLATE 'und:ci'
OPTIONS(
  location="us-south1",
  is_case_insensitive=TRUE,
  storage_billing_model="PHYSICAL"
  );