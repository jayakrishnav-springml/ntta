CREATE TABLE IF NOT EXISTS EDW_TER.Dim_MaintenanceAgency
(
  maintenanceagencyid INT64 NOT NULL,
  maintenanceagency STRING NOT NULL,
  insert_datetime DATETIME NOT NULL
)
cluster by maintenanceagencyid
;
