
CREATE TABLE IF NOT EXISTS EDW_TER.ViolatorStatus
(
  violatorstatusid INT64 NOT NULL,
  violatorid INT64 NOT NULL,
  vidseq INT64 NOT NULL,
  hvflag INT64 NOT NULL,
  hvdate DATE NOT NULL,
  violatorstatuslookupid INT64 NOT NULL,
  hvexemptflag INT64 NOT NULL,
  hvexemptdate DATE NOT NULL,
  violatorstatustermlookupid INT64 NOT NULL,
  termflag INT64 NOT NULL,
  termdate DATE NOT NULL,
  violatorstatuseligrmdylookupid INT64 NOT NULL,
  eligrmdyflag INT64 NOT NULL,
  eligrmdydate DATE NOT NULL,
  banflag INT64 NOT NULL,
  bandate DATE NOT NULL,
  banstartdate DATE NOT NULL,
  bancitewarnflag INT64 NOT NULL,
  bancitewarndate DATE NOT NULL,
  bancitewarncount INT64,
  banimpoundflag INT64 NOT NULL,
  banimpounddate DATE NOT NULL,
  vrbflag INT64 NOT NULL,
  vrbdate DATE NOT NULL,
  violatorstatusletterdeterminationlookupid INT64 NOT NULL,
  determinationletterflag INT64 NOT NULL,
  determinationletterdate DATE NOT NULL,
  violatorstatusletterbanlookupid INT64 NOT NULL,
  banletterflag INT64 NOT NULL,
  banletterdate DATE NOT NULL,
  violatorstatuslettertermlookupid INT64 NOT NULL,
  termletterflag INT64 NOT NULL,
  termletterdate DATE NOT NULL,
  hvqamountdue NUMERIC(33, 4) NOT NULL,
  hvqtollsdue NUMERIC(33, 4) NOT NULL,
  hvqtransactions INT64,
  hvqfeesdue NUMERIC(33, 4) NOT NULL,
  totalamountdueinitial NUMERIC(33, 4),
  totalamountdue NUMERIC(33, 4) NOT NULL,
  totaltollsdue NUMERIC(33, 4),
  totalfeesdue NUMERIC(33, 4),
  totalcitationcount INT64 NOT NULL,
  totaltransactionsinitial INT64,
  totaltransactionscount INT64 NOT NULL,
  settlementamount NUMERIC(33, 4),
  downpayment NUMERIC(33, 4),
  collections NUMERIC(33, 4),
  paidinfull INT64,
  defaultind INT64,
  adminfees NUMERIC(33, 4),
  citationfees NUMERIC(33, 4),
  monthlypaymentamount NUMERIC(33, 4),
  balancedue NUMERIC(33, 4),
  excusedamount NUMERIC(33, 4),
  collectableamount NUMERIC(33, 4),
  bankruptcyind INT64,
  hvactive INT64,
  hvremoved INT64,
  vrbacknowledged INT64,
  vrbremoved INT64,
  vrbremovalqueued INT64,
  banbyprocessserver INT64,
  banbydps INT64,
  banbyusmail1stban INT64,
  acct_id INT64,
  acct_status_code STRING,
  has_toll_tag_account INT64,
  tolltransactioncount INT64,
  balance_amount NUMERIC(33, 4),
  pmt_type_code STRING,
  rebill_amt NUMERIC(31, 2),
  rebill_date DATETIME,
  bal_last_updated DATETIME,
  ban2ndletterdate DATETIME,
  ban2ndletterflag INT64,
  violatorstatusletterban2ndlookupid INT64,
  violatorstatuslettervrblookupid INT64,
  vrbletterdate DATETIME,
  vrbletterflag INT64,
  bandpscount INT64,
  banpcpcount INT64,
  banwarncount INT64,
  bancitationcount INT64,
  banimpoundcount INT64,
  bannoactioncount INT64,
  banfennellcount INT64,
  insert_date DATETIME NOT NULL,
  last_update_date DATETIME NOT NULL,
  tag_date_created DATE
)
;