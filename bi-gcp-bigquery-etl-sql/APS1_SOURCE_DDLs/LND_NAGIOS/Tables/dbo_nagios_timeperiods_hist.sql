CREATE TABLE [dbo].[nagios_timeperiods_hist]
(
	[timeperiod_id] int NULL,
	[instance_id] smallint NULL,
	[config_type] smallint NULL,
	[timeperiod_object_id] int NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([timeperiod_id]))
