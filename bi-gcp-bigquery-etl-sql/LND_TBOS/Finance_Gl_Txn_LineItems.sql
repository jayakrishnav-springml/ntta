## Translation time: 2024-03-04T06:44:00.523569Z
## Translation job ID: a86d938d-fa65-424d-bf4e-0008985e1778
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/LND_TBOS/Tables/Finance_Gl_Txn_LineItems.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE TABLE IF NOT EXISTS LND_TBOS.Finance_Gl_Txn_LineItems
(
  pk_id INT64 NOT NULL,
  gl_txnid INT64 NOT NULL,
  description STRING,
  chartofaccountid INT64 NOT NULL,
  debitamount NUMERIC(31, 2) NOT NULL,
  creditamount NUMERIC(31, 2) NOT NULL,
  specialjournalid INT64,
  drcr_flag STRING,
  txntype_li_id INT64,
  txntypeid INT64,
  createddate DATETIME NOT NULL,
  createduser STRING,
  updateddate DATETIME NOT NULL,
  updateduser STRING,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY
pk_id
;