
CREATE TABLE IF NOT EXISTS EDW_TER.Violator
(
  id INT64 NOT NULL,
  violatorid INT64 NOT NULL,
  vidseq INT64 NOT NULL,
  current_ind INT64 NOT NULL,
  hv_non_hv_ind INT64 NOT NULL,
  licplatenbr STRING NOT NULL,
  licplatestatelookupid INT64 NOT NULL,
  vehicle_id INT64,
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
  earliesthvtrandate DATE NOT NULL,
  latesthvtrandate DATE NOT NULL,
  admincountylookupid INT64 NOT NULL,
  registrationcountylookupid INT64 NOT NULL,
  registrationdatenextmonth INT64 NOT NULL,
  registrationdatenextyear INT64 NOT NULL,
  violatoragencylookupid INT64 NOT NULL,
  violatoraddresssourcelookupid INT64 NOT NULL,
  violatoraddressstatuslookupid INT64 NOT NULL,
  violatoraddressactiveflag INT64 NOT NULL,
  violatoraddressconfirmedflag INT64 NOT NULL,
  violatoraddress1 STRING NOT NULL,
  violatoraddress2 STRING,
  violatoraddresscity STRING NOT NULL,
  violatoraddressstatelookupid INT64 NOT NULL,
  violatoraddresszipcode STRING NOT NULL,
  violatoraddressplus4 STRING,
  violatoraddresscreatedby STRING,
  violatoraddresscreatedate DATETIME,
  violatoraddressupdatedby STRING,
  violatoraddressupdatedate DATETIME,
  insert_date DATETIME NOT NULL,
  last_update_date DATETIME NOT NULL
)
;
