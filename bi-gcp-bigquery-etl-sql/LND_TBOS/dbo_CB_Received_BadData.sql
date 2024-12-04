

CREATE TABLE IF NOT EXISTS LND_TBOS.dbo_CB_Received_BadData
(
  monthid STRING,
  entitylevel STRING,
  entityid STRING,
  statusflag STRING,
  sequencenumber STRING,
  transactiondivisionnumber STRING,
  merchantordernumber STRING,
  accountnumber STRING,
  reasoncode STRING,
  originaltransactiondate STRING,
  chargebackreceiveddate STRING,
  activitydate STRING,
  chargebackamount STRING,
  cbcycle STRING,
  lnd_updatedate DATETIME,
  errorcode STRING,
  errorcolumn STRING,
  src_changedate DATETIME
)
;