CREATE TABLE [dbo].[nagios_timedeventqueue]
(
	[timedeventqueue_id] int NULL,
	[instance_id] smallint NULL,
	[event_type] smallint NULL,
	[queued_time] datetime NULL,
	[queued_time_usec] int NULL,
	[scheduled_time] datetime NULL,
	[recurring_event] smallint NULL,
	[object_id] int NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([timedeventqueue_id]))
