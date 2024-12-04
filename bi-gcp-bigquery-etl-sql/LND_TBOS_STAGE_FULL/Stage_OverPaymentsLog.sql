--manually translated using bigquery interactive sql translator 

CREATE TABLE IF NOT EXISTS LND_TBOS_STAGE_FULL.TollPlus_OverPaymentsLog
(
  overpaymentlogid INT64 NOT NULL,
  customerid INT64,
  paymentid INT64,
  adjustmentid INT64,
  amountreceived NUMERIC(31, 2),
  linkid INT64,
  linksource STRING,
  reasoncode STRING,
  createddate DATETIME,
  createduser STRING,
  updateddate DATETIME,
  updateduser STRING,
  overpaymentid INT64,
  tripadjustmentid INT64,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)
CLUSTER BY overpaymentlogid
;
