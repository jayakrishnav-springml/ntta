CREATE VIEW [dvo].[DIM_ZIPCODE] AS select	ZIPCODE
,		ZIPCODE_LATITUDE
,		ZIPCODE_LONGITUDE
,		COUNTY
,		COUNTY_GROUP
from	dbo.DIM_ZIPCODE;
