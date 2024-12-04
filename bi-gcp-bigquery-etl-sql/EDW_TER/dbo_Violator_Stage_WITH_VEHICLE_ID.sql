
CREATE TABLE IF NOT EXISTS EDW_TER.Violator_Stage_With_Vehicle_Id
(
  violatorid INT64 NOT NULL,
  vidseq INT64 NOT NULL,
  licplatenbr STRING NOT NULL,
  licplatestatelookupid INT64 NOT NULL,
  vehicle_id INT64 NOT NULL,
  docnum STRING,
  vin STRING,
  primaryviolatorfname STRING,
  primaryviolatorlname STRING,
  secondaryviolatorfname STRING,
  secondaryviolatorlname STRING,
  driverslicense STRING,
  driverslicensestatelookupid INT64 NOT NULL,
  secondarydriverslicense STRING,
  secondarydriverslicensestatelookupid INT64 NOT NULL,
  earliesthvtrandate DATETIME NOT NULL,
  latesthvtrandate DATETIME NOT NULL,
  admincountylookupid INT64 NOT NULL,
  registrationcountylookupid INT64 NOT NULL,
  registrationdatenextmonth INT64 NOT NULL,
  registrationdatenextyear INT64 NOT NULL,
  violatoragencylookupid INT64 NOT NULL,
  violatoraddresssourcelookupid INT64 NOT NULL,
  violatoraddressstatuslookupid INT64 NOT NULL,
  activeflag INT64 NOT NULL,
  confirmedflag INT64 NOT NULL,
  address1 STRING NOT NULL,
  address2 STRING,
  city STRING NOT NULL,
  statelookupid INT64 NOT NULL,
  zipcode STRING NOT NULL,
  plus4 STRING,
  violatoraddresscreatedby STRING NOT NULL,
  violatoraddresscreatedate DATETIME NOT NULL,
  violatoraddressupdatedby STRING,
  violatoraddressupdatedate DATETIME,
  violaddr_last_update_type STRING NOT NULL,
  violaddr_last_update_date DATETIME NOT NULL
)
cluster by violatorid,vidseq
;
