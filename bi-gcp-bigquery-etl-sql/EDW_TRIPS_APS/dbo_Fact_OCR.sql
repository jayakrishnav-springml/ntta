
CREATE TABLE IF NOT EXISTS EDW_TRIPS_APS.Fact_OCR
(
tripdayid INTEGER,	
daynightflag STRING,
laneid INTEGER,
tripstatusid INTEGER,
tripidentmethodid INTEGER,
manuallyreviewedflag INTEGER,
tollamount NUMERIC,
txncount INTEGER,
edw_updatedate DATETIME	
) cluster by tripdayid;