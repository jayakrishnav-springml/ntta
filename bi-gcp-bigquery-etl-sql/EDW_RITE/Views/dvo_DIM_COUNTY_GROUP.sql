CREATE VIEW [dvo].[DIM_COUNTY_GROUP] AS select	distinct
		COUNTY_GROUP
from	dbo.DIM_ZIPCODE;
