CREATE TABLE [dbo].[nagios_timeperiods]
(
	[timeperiod_id] int NULL,
	[instance_id] smallint NULL,
	[config_type] smallint NULL,
	[timeperiod_object_id] int NULL,
	[alias] nvarchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([timeperiod_id]))
