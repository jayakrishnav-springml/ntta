CREATE TABLE IF NOT EXISTS LND_TBOS.Finance_RefundResponseDetails
(
  refundresponseid INT64 NOT NULL,
  customerid INT64,
  disbursementid INT64,
  refundamount NUMERIC(31,2),
  checknumber STRING,
  refundrequesteddate DATETIME,
  disbursementdesc STRING,
  refundissueddate DATETIME,
  errormessage STRING,
  isvalid BOOLEAN,
  status STRING,
  fileid INT64,
  createddate DATETIME,
  createduser STRING,
  updateddate DATETIME,
  updateduser STRING,
  paymentid INT64,
  lnd_updatedate DATETIME,
  lnd_updatetype STRING,  
  src_changedate DATETIME

)cluster by refundresponseid
;