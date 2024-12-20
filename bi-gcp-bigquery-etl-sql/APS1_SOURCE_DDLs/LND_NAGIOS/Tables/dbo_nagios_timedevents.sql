CREATE TABLE [dbo].[nagios_timedevents]
(
	[timedevent_id] int NULL,
	[instance_id] smallint NULL,
	[event_type] smallint NULL,
	[queued_time] datetime NULL,
	[queued_time_usec] int NULL,
	[event_time] datetime NULL,
	[event_time_usec] int NULL,
	[scheduled_time] datetime NULL,
	[recurring_event] smallint NULL,
	[object_id] int NULL,
	[deletion_time] datetime NULL,
	[deletion_time_usec] int NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([timedevent_id]))
