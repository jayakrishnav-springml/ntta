CREATE TABLE [dbo].[nagios_contactnotifications]
(
	[contactnotification_id] int NULL,
	[instance_id] smallint NULL,
	[notification_id] int NULL,
	[contact_object_id] int NULL,
	[start_time] datetime NULL,
	[start_time_usec] int NULL,
	[end_time] datetime NULL,
	[end_time_usec] int NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([contactnotification_id]))
