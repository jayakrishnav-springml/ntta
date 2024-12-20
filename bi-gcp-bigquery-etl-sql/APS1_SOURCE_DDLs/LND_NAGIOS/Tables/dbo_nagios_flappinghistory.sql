CREATE TABLE [dbo].[nagios_flappinghistory]
(
	[flappinghistory_id] int NULL,
	[instance_id] smallint NULL,
	[event_time] datetime NULL,
	[event_time_usec] int NULL,
	[event_type] smallint NULL,
	[reason_type] smallint NULL,
	[flapping_type] smallint NULL,
	[object_id] int NULL,
	[percent_state_change] float(53) NULL,
	[low_threshold] float(53) NULL,
	[high_threshold] float(53) NULL,
	[comment_time] datetime NULL,
	[internal_comment_id] int NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([flappinghistory_id]))
