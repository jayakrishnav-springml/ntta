CREATE TABLE iF NOT EXISTS LND_TBOS_STAGE_CDC.TollPlus_BalanceTransferQueue
(
  balancetransferqueueid INT64 NOT NULL,
  fromcustomerid INT64,
  tocustomerid INT64,
  transferamount NUMERIC(31, 2),
  reason STRING,
  requesteddate DATETIME,
  transferstatus STRING,
  transferdate DATETIME,
  createdate DATETIME,
  createduser STRING,
  updateddate DATETIME,
  updateduser STRING,
  fromadjustmentid INT64,
  toadjustmentid INT64,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,
  src_changedate DATETIME
)cluster by balancetransferqueueid
;
