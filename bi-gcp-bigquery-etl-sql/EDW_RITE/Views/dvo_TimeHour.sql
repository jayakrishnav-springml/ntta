CREATE VIEW [dvo].[TimeHour] AS select	distinct
	[HOUR]			as Time_24_Hour
,	[12_Hour]		as Time_12_Hour
,	[AM_PM]			as Time_AM_PM
from	dbo.DIM_TIME;
