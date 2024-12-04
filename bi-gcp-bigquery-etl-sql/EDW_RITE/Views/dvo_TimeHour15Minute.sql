CREATE VIEW [dvo].[TimeHour15Minute] AS select	distinct
	[HOUR]			as Time_24_Hour
,	[12_Hour]		as Time_12_Hour
,	[AM_PM]			as Time_AM_PM
,	[30_Minute]		as Time_30_Minute
,	[15_Minute]		as Time_15_Minute
from	dbo.DIM_TIME;
