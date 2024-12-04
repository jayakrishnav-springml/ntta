CREATE VIEW [dbo].[vw_TimeHourMinuteSecond] AS select	[TIME_ID]		as TimeID
,	[HOUR]			as Time_24_Hour
,	[12_Hour]		as Time_12_Hour
,	[AM_PM]			as Time_AM_PM
,	[30_Minute]		as Time_30_Minute
,	[15_Minute]		as Time_15_Minute
,	[10_Minute]		as Time_10_Minute
,	[5_Minute]		as Time_5_Minute
,	[MINUTE]		as Time_1_Minute
,	[SECOND]		as Time_1_Second
from	dbo.DIM_TIME;
