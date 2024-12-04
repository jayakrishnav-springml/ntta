## Translation time: 2024-03-13T05:19:34.327071Z
## Translation job ID: 0a711804-adbe-4db7-8cda-d8808bd4ce52
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/NTTA_Missing_DDLs/LND_TBOS_TSA_PostingType.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.TSA_PostingType
(
  posttypeid INT64 NOT NULL,
  transactionpostingtype STRING,
  issourceprepaid_postpaidtag INT64,
  issourcezipcash INT64,
  issourcefleet INT64,
  issourceiop INT64,
  isdestinationprepaid_postpaidtag INT64,
  isdestinationzipcash INT64,
  isdestinationfleet INT64,
  isdestinationiop INT64,
  isrt21_t_transactiontype INT64,
  isrt22_v_withtag_transactiontype INT64,
  isrt22_v_withouttag_transactiontype INT64,
  istxninvoiced_yes INT64,
  istxninvoiced_no INT64,
  istxninvoiced_na INT64,
  isavipostingrate INT64,
  isvideopostingrate INT64,
  postingdescription STRING,
  src_changedate DATETIME
)
CLUSTER BY posttypeid
;