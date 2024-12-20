CREATE TABLE [dbo].[nagios_contactnotificationmethods]
(
	[contactnotificationmethod_id] int NULL,
	[instance_id] smallint NULL,
	[contactnotification_id] int NULL,
	[start_time] datetime NULL,
	[start_time_usec] int NULL,
	[end_time] datetime NULL,
	[end_time_usec] int NULL,
	[command_object_id] int NULL,
	[command_args] nvarchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([contactnotificationmethod_id]))
