-- Translation time: 2024-03-04T06:44:00.523569Z
-- Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Utility_TableLoadParameters.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_APS.TableLoadParameters
(
  tableid INT64 NOT NULL,
  databasename STRING NOT NULL,
  schemaname STRING NOT NULL,
  tablename STRING NOT NULL,
  fullname STRING NOT NULL,
  stagetablename STRING NOT NULL,
  loadprocessid INT64,
  rowcnt INT64,
  useupdateddate INT64 NOT NULL,
  usepartition INT64 NOT NULL,
  active INT64 NOT NULL,
  usemultithreadflag INT64 NOT NULL,
  createflag INT64 NOT NULL,
  cdcflag INT64 NOT NULL,
  notinmasterpackageflag INT64 NOT NULL,
  keephistoryflag INT64 NOT NULL,
  uid_columns STRING,
  updateddatecolumn STRING,
  distributionstring STRING,
  indexstring STRING,
  columnsstring STRING,
  wherestring STRING,
  statssql STRING,
  selectsql STRING,
  deletesql STRING,
  insertsql STRING,
  renamesql STRING,
  updateproc STRING,
  runafterproc STRING,
  updatedate DATETIME,
  archiveflag INT64 DEFAULT 0 NOT NULL
)
CLUSTER BY tableid
;
