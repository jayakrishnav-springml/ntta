CREATE TABLE [dbo].[nagios_contacts]
(
	[contact_id] int NULL,
	[instance_id] smallint NULL,
	[config_type] smallint NULL,
	[contact_object_id] int NULL,
	[alias] nvarchar(64) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[email_address] nvarchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[pager_address] nvarchar(64) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[minimum_importance] int NULL,
	[host_timeperiod_object_id] int NULL,
	[service_timeperiod_object_id] int NULL,
	[host_notifications_enabled] smallint NULL,
	[service_notifications_enabled] smallint NULL,
	[can_submit_commands] smallint NULL,
	[notify_service_recovery] smallint NULL,
	[notify_service_warning] smallint NULL,
	[notify_service_unknown] smallint NULL,
	[notify_service_critical] smallint NULL,
	[notify_service_flapping] smallint NULL,
	[notify_service_downtime] smallint NULL,
	[notify_host_recovery] smallint NULL,
	[notify_host_down] smallint NULL,
	[notify_host_unreachable] smallint NULL,
	[notify_host_flapping] smallint NULL,
	[notify_host_downtime] smallint NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([contact_id]))
