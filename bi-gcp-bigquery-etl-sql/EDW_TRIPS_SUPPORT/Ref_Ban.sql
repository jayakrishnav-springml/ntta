## Translation time: 2024-03-13T05:19:34.327071Z
## Translation job ID: 0a711804-adbe-4db7-8cda-d8808bd4ce52
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/NTTA_Missing_DDLs/EDW_TRIPS_Ref_Ban.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS EDW_TRIPS_SUPPORT.Ban
(
  violatorid INT64,
  vidseq INT64,
  hvflag INT64,
  indicator STRING,
  dayid INT64,
  daydate DATE,
  daydesc STRING,
  violatorstatusletterdeterminationlookupid INT64,
  violatorstatusletterdetermination STRING,
  dayid0 INT64,
  daydate0 DATE,
  daydesc0 STRING,
  violatorstatuslettervrblookupid INT64,
  violatorstatuslettervrblookupdesc STRING,
  violatorstatusletterbanlookupid INT64,
  violatorstatusletterban STRING,
  dayid1 INT64,
  daydate1 DATE,
  daydesc1 STRING,
  dayid2 INT64,
  daydate2 DATE,
  daydesc2 STRING,
  licplatestatelookupid INT64,
  licplatestatename STRING,
  licplatestate STRING,
  cal_monthid INT64 NOT NULL,
  monthdesc STRING,
  dayid3 INT64,
  daydate3 DATE,
  daydesc3 STRING,
  violatorid0 INT64,
  ban STRING NOT NULL,
  registrationcountylookupid INT64,
  registrationcounty STRING
)
;