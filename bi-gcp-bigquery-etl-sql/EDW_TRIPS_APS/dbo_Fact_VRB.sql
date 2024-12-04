## Translation time: 2024-03-04T06:41:57.683170Z
## Translation job ID: 00dc6676-2c12-444a-b02a-71c7788bdc89
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Tables/dbo_Fact_VRB.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_APS.Fact_VRB
(
  vrbid INT64 NOT NULL,
  hvid INT64 NOT NULL,
  customerid INT64 NOT NULL,
  vehicleid INT64 NOT NULL,
  vrbstatusid INT64 NOT NULL,
  vrbagencyid INT64 NOT NULL,
  vrbrejectreasonid INT64 NOT NULL,
  vrbremovalreasonid INT64 NOT NULL,
  vrbletterdeliverstatusid INT64 NOT NULL,
  vrbrequesteddayid INT64,
  vrbapplieddayid INT64,
  vrbremoveddayid INT64,
  vrbactiveflag INT64 NOT NULL,
  dallasscofflawflag INT64,
  vrbcreateddate DATETIME,
  vrbrejectiondate DATETIME,
  vrblettermaileddate DATETIME,
  vrbletterdelivereddate DATETIME,
  edw_updatedate DATETIME NOT NULL
)
cluster by hvid
;