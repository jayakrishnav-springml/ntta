CREATE TABLE [dbo].[nagios_hostescalations]
(
	[hostescalation_id] int NULL,
	[instance_id] smallint NULL,
	[config_type] smallint NULL,
	[host_object_id] int NULL,
	[timeperiod_object_id] int NULL,
	[first_notification] smallint NULL,
	[last_notification] smallint NULL,
	[notification_interval] float(53) NULL,
	[escalate_on_recovery] smallint NULL,
	[escalate_on_down] smallint NULL,
	[escalate_on_unreachable] smallint NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([hostescalation_id]))
