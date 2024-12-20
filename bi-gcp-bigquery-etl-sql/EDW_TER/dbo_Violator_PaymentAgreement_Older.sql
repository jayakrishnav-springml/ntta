
CREATE TABLE IF NOT EXISTS EDW_TER.Violator_PaymentAgreement_Older
(
  violatorid INT64 NOT NULL,
  vidseq INT64 NOT NULL,
  instancenbr INT64 NOT NULL,
  enforcement_tool_code STRING,
  lastname STRING,
  firstname STRING,
  phonenumber STRING,
  licenseplate STRING,
  state STRING,
  agentid INT64 NOT NULL,
  paymentagreement_sourceid INT64 NOT NULL,
  settlementamount NUMERIC(33, 4),
  downpayment NUMERIC(33, 4),
  duedate DATE NOT NULL,
  agreementtypeid INT64 NOT NULL,
  todaysdate DATE NOT NULL,
  collections NUMERIC(33, 4),
  remainingbalancedue STRING,
  paymentplanduedate DATE NOT NULL,
  checknumber STRING,
  paidinfull INT64 NOT NULL,
  defaultind INT64 NOT NULL,
  spanishonly INT64 NOT NULL,
  amnestyaccount INT64 NOT NULL,
  tolltag_acct_id INT64,
  adminfees NUMERIC(33, 4),
  citationfees NUMERIC(33, 4),
  monthlypaymentamount NUMERIC(33, 4),
  defaultdate DATE,
  maintenanceagencyid INT64,
  violatorid2 INT64,
  violatorid3 INT64,
  violatorid4 INT64,
  balancedue NUMERIC(33, 4),
  ntta_collections NUMERIC(33, 4),
  insertdate DATETIME NOT NULL,
  insertbyuser STRING NOT NULL,
  lastupdatedate DATETIME,
  lastupdatebyuser STRING,
  insert_date DATETIME NOT NULL,
  last_update_date DATETIME
)
;
