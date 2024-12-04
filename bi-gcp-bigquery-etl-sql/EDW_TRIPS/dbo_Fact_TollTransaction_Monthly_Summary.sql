CREATE TABLE IF NOT EXISTS EDW_TRIPS.Fact_TollTransaction_Monthly_Summary
(
  customerid INT64 NOT NULL,
  tripmonthid INT64,
  vehicleid INT64 NOT NULL,
  custtagid INT64 NOT NULL,
  operationsmappingid INT64,
  facilityid INT64,
  txncount INT64,
  adjustedexpectedamount NUMERIC(31, 2) NOT NULL,
  actualpaidamount NUMERIC(31, 2) NOT NULL,
  edw_updatedate DATETIME
)
;
