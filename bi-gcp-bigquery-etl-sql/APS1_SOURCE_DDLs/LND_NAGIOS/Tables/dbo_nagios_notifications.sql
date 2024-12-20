CREATE TABLE [dbo].[nagios_notifications]
(
	[notification_id] int NULL,
	[instance_id] smallint NULL,
	[notification_type] smallint NULL,
	[notification_reason] smallint NULL,
	[object_id] int NULL,
	[start_time] datetime NULL,
	[start_time_usec] int NULL,
	[end_time] datetime NULL,
	[end_time_usec] int NULL,
	[state] smallint NULL,
	[output] nvarchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[long_output] nvarchar(max) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[escalated] smallint NULL,
	[contacts_notified] smallint NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([notification_id]))
