-- Translation time: 2024-06-04T08:06:27.696231Z
-- Translation job ID: a4465f30-9e78-4d9a-ad69-bbfb39271a9b
-- Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TER/Tables/dbo_ViolatorStatus.sql
-- Translated from: SqlServer
-- Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TER.ViolatorStatus
(
  violatorstatusid INT64 NOT NULL,
  violatorid INT64 NOT NULL,
  vidseq INT64 NOT NULL,
  hvflag INT64 NOT NULL,
  hvdate DATETIME NOT NULL,
  violatorstatuslookupid INT64 NOT NULL,
  hvexemptflag INT64 NOT NULL,
  hvexemptdate DATETIME,
  violatorstatustermlookupid INT64,
  termflag INT64 NOT NULL,
  termdate DATETIME,
  violatorstatuseligrmdylookupid INT64 NOT NULL,
  eligrmdyflag INT64 NOT NULL,
  eligrmdydate DATETIME,
  banflag INT64 NOT NULL,
  bandate DATETIME,
  banstartdate DATETIME,
  bancitewarnflag INT64 NOT NULL,
  bancitewarndate DATETIME,
  bancitewarncount INT64,
  banimpoundflag INT64 NOT NULL,
  banimpounddate DATETIME,
  vrbflag INT64,
  vrbdate DATETIME,
  violatorstatusletterdeterminationlookupid INT64,
  determinationletterflag INT64 NOT NULL,
  determinationletterdate DATETIME,
  violatorstatusletterbanlookupid INT64,
  banletterflag INT64 NOT NULL,
  banletterdate DATETIME,
  violatorstatuslettertermlookupid INT64,
  termletterflag INT64 NOT NULL,
  termletterdate DATETIME,
  ban2ndletterdate DATETIME,
  ban2ndletterflag INT64,
  bankruptcydate DATETIME,
  bankruptcyflag INT64,
  violatorstatusletterban2ndlookupid INT64,
  violatorstatuslettervrblookupid INT64,
  vrbletterdate DATETIME,
  vrbletterflag INT64,
  createddate DATETIME NOT NULL,
  createdby STRING NOT NULL,
  updateddate DATETIME,
  updatedby STRING,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
