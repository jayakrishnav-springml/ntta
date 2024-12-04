
CREATE TABLE IF NOT EXISTS EDW_TER.Ter_Letter_Alerts_Vrb
(
  alertsrunid INT64,
  vrbletterdueweek DATE,
  sentstatus STRING,
  alertlevel STRING NOT NULL,
  vrbletteranalysis STRING,
  paymentplantiming STRING,
  paymenttiming STRING,
  bankruptcytiming STRING,
  maxlettersthreshold STRING,
  rejectedvrbflag STRING,
  queueletterexpregflag STRING,
  violatorid INT64 NOT NULL,
  vidseq INT64 NOT NULL,
  licplatestate STRING,
  hvdate DATETIME NOT NULL,
  determinationletterdate DATETIME,
  dtrltr40daysdate DATETIME,
  dtrltr40daysduemonday DATETIME,
  defaultedmonday DATETIME,
  vrbletterduemonday DATETIME,
  firstvrblettersenddate DATETIME,
  firstvrbletterdate DATETIME,
  activeagreementdate DATETIME,
  applypaymentplandate DATETIME,
  defaulteddate DATETIME,
  rite_paidinfulldate DATETIME,
  pp_paidinfulldate DATETIME,
  termdate DATETIME,
  bankruptcydate DATETIME,
  bankruptcydismisseddate DATETIME,
  adminhearingdate DATETIME,
  dmvrequestblockdate DATETIME,
  expiringregvrbqueuedate DATETIME,
  dallasinvalidresponsedate DATETIME,
  dlogvrbletterqueueddate DATETIME,
  vrbletterqueueddate DATETIME,
  vrbletterqueuecanceldate DATETIME,
  usercanceldate DATETIME,
  violatorcreateddate DATETIME NOT NULL,
  questmarkdetletterackdate DATETIME,
  vrbletterstatus STRING,
  violatorstatus STRING,
  violatorstatuseligrmdy STRING,
  hvflag INT64 NOT NULL,
  eligrmdyflag INT64 NOT NULL,
  vrbletterflag INT64,
  nonhvpaymentplanid INT64,
  paymentplanid INT64,
  planstartdate DATETIME,
  planenddate DATETIME,
  paymentplanstatus STRING,
  paymentplancount INT64,
  totalnoofmonths INT64,
  lastvrblettersenddate DATETIME,
  vrblettersendcount INT64,
  lastvrbletterdate DATETIME,
  vrblettercount INT64,
  agency STRING NOT NULL,
  docnum STRING,
  maxletterstartdate DATETIME,
  maxletterenddate DATETIME,
  generationdate DATETIME NOT NULL
)
;
