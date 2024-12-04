-- Translation time: 2024-06-04T08:06:27.696231Z
-- Translation job ID: a4465f30-9e78-4d9a-ad69-bbfb39271a9b
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TER/Tables/dbo_ViolatorStatusHistory.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TER.ViolatorStatusHistory
(
  violatorstatushistoryid INT64 NOT NULL,
  violatorstatusid INT64 NOT NULL,
  violatorid INT64 NOT NULL,
  vidseq INT64 NOT NULL,
  hvflag INT64 NOT NULL,
  hvdate DATETIME NOT NULL,
  violatorstatuslookupid INT64 NOT NULL,
  hvexemptflag INT64,
  hvexemptdate DATETIME,
  violatorstatustermlookupid INT64,
  termflag INT64,
  termdate DATETIME,
  violatorstatuseligrmdylookupid INT64,
  eligrmdyflag INT64,
  eligrmdydate DATETIME,
  bankruptcyflag INT64,
  bankruptcydate DATETIME,
  paymentplandefaultcount INT64,
  banflag INT64,
  bandate DATETIME,
  banstartdate DATETIME,
  bancitewarnflag INT64,
  bancitewarndate DATETIME,
  bancitewarncount INT64,
  banimpoundflag INT64,
  banimpounddate DATETIME,
  vrbflag INT64,
  vrbdate DATETIME,
  violatorstatusletterdeterminationlookupid INT64,
  determinationletterflag INT64,
  determinationletterdate DATETIME,
  violatorstatusletterbanlookupid INT64,
  banletterflag INT64,
  banletterdate DATETIME,
  violatorstatusletterban2ndlookupid INT64 NOT NULL,
  ban2ndletterflag INT64 NOT NULL,
  ban2ndletterdate DATETIME,
  violatorstatusprocessserverlookupid INT64,
  processserverflag INT64,
  processserverdate DATETIME,
  violatorstatuslettervrblookupid INT64 NOT NULL,
  vrbletterflag INT64 NOT NULL,
  vrbletterdate DATETIME,
  violatorstatuslettertermlookupid INT64,
  termletterflag INT64,
  termletterdate DATETIME,
  createddate DATETIME NOT NULL,
  createdby STRING NOT NULL,
  updateddate DATETIME,
  updatedby STRING,
  last_update_type STRING,
  last_update_date DATETIME
)
cluster by violatorid,vidseq
;
