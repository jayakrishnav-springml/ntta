
CREATE TABLE IF NOT EXISTS EDW_TER.Ter_Letter_Alerts_Ban
(
  alertsrunid INT64,
  banletterdueweek DATE,
  sentstatus STRING,
  alertlevel STRING NOT NULL,
  banletteranalysis STRING,
  paymentplantiming STRING,
  paymenttiming STRING,
  bankruptcytiming STRING,
  maxlettersthreshold STRING,
  violatorid INT64 NOT NULL,
  vidseq INT64 NOT NULL,
  licplatestate STRING,
  hvdate DATETIME NOT NULL,
  determinationletterdate DATETIME,
  vrbltr30daysdate DATETIME,
  dtrltr40daysdate DATETIME,
  banletterduemonday DATETIME,
  banletterfinalduemonday DATETIME,
  banletterqueueddate DATETIME,
  banlettersenddate DATETIME,
  banletterqueuecanceldate DATETIME,
  banletterdate DATETIME,
  activeagreementdate DATETIME,
  defaulteddate DATETIME,
  rejectedvrbbanletterdate DATETIME,
  applypaymentplandate DATETIME,
  rite_paidinfulldate DATETIME,
  pp_paidinfulldate DATETIME,
  termdate DATETIME,
  bankruptcydate DATETIME,
  bankruptcydismisseddate DATETIME,
  adminhearingdate DATETIME,
  usercanceldate DATETIME,
  violatorcreateddate DATETIME NOT NULL,
  questmarkdetletterackdate DATETIME,
  banletterstatus STRING,
  violatorstatus STRING,
  violatorstatuseligrmdy STRING,
  hvflag INT64 NOT NULL,
  eligrmdyflag INT64 NOT NULL,
  banletterflag INT64 NOT NULL,
  nonhvpaymentplanid INT64,
  paymentplanid INT64,
  planstartdate DATETIME,
  planenddate DATETIME,
  paymentplanstatus STRING,
  paymentplancount INT64,
  totalnoofmonths INT64,
  maxletterstartdate DATETIME,
  maxletterenddate DATETIME,
  generationdate DATETIME NOT NULL
)
;
