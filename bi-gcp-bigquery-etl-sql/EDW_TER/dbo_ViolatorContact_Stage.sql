CREATE TABLE IF NOT EXISTS EDW_TER.ViolatorContact_Stage
(
  violatorcontactid INT64 NOT NULL,
  violatorid INT64 NOT NULL,
  vidseq INT64 NOT NULL,
  phonenbr STRING,
  workphonenbr STRING,
  otherphonenbr STRING,
  emailaddress STRING,
  last_update_type STRING NOT NULL,
  last_update_date DATETIME NOT NULL
)
cluster by violatorcontactid
;