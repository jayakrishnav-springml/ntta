CREATE VIEW [dvo].[DIM_COUNTY] AS select	distinct
		COUNTY
,		COUNTY_GROUP
from	dbo.DIM_ZIPCODE;
