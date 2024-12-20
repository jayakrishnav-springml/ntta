CREATE TABLE [dbo].[nagios_timeperiod_timeranges]
(
	[timeperiod_timerange_id] int NULL,
	[instance_id] smallint NULL,
	[timeperiod_id] int NULL,
	[day] smallint NULL,
	[start_sec] int NULL,
	[end_sec] int NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([timeperiod_timerange_id]))
