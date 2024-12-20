CREATE TABLE [dbo].[nagios_contactstatus]
(
	[contactstatus_id] int NULL,
	[instance_id] smallint NULL,
	[contact_object_id] int NULL,
	[status_update_time] datetime NULL,
	[host_notifications_enabled] smallint NULL,
	[service_notifications_enabled] smallint NULL,
	[last_host_notification] datetime NULL,
	[last_service_notification] datetime NULL,
	[modified_attributes] int NULL,
	[modified_host_attributes] int NULL,
	[modified_service_attributes] int NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([contactstatus_id]))
