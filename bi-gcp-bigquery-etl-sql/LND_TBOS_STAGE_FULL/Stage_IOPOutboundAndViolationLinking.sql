## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Stage_IOPOutboundAndViolationLinking.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.dbo_IOPOutboundAndViolationLinking
(
  lane_viol_id INT64,
  transaction_id INT64 NOT NULL,
  hub_iop_txn_id INT64,
  violation_id INT64,
  transaction_date DATETIME NOT NULL,
  violationtptripid INT64 NOT NULL,
  outboundtptripid INT64 NOT NULL,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY
outboundtptripid
;