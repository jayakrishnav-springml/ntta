## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/Stage_Ref_LookupTypeCodes_Hierarchy.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_STAGE.Ref_LookupTypeCodes_Hierarchy
(
  lookuptypecodeid INT64,
  l1_lookuptypecodeid INT64 NOT NULL,
  l1_lookuptypecode STRING,
  l1_lookuptypecodedesc STRING,
  l2_lookuptypecodeid INT64 NOT NULL,
  l2_lookuptypecode STRING,
  l2_lookuptypecodedesc STRING,
  l3_lookuptypecodeid INT64,
  l3_lookuptypecode STRING,
  l3_lookuptypecodedesc STRING,
  l4_lookuptypecodeid INT64,
  l4_lookuptypecode STRING,
  l4_lookuptypecodedesc STRING,
  edw_updatedate DATETIME
) CLUSTER BY  lookuptypecodeid
;