CREATE TABLE IF NOT EXISTS EDW_TER.Ter_Letter_Alerts_Term
(
  alertsrunid INT64 NOT NULL,
  termletterdueweek DATE,
  sentstatus STRING,
  alertlevel STRING NOT NULL,
  termletteranalysis STRING,
  violatorid INT64 NOT NULL,
  vidseq INT64 NOT NULL,
  hvdate DATETIME NOT NULL,
  termdate DATETIME,
  termletterduemonday DATETIME,
  termletterdate DATETIME,
  termletterqueueddate DATETIME,
  termlettersenddate DATETIME,
  questmarktermletterackdate DATETIME,
  termletterstatus STRING,
  violatorstatus STRING,
  violatorstatuseligrmdy STRING,
  hvflag INT64 NOT NULL,
  eligrmdyflag INT64 NOT NULL,
  termletterflag INT64 NOT NULL,
  generationdate DATETIME NOT NULL
)
;