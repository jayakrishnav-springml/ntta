CREATE TABLE [dbo].[nagios_statehistory]
(
	[statehistory_id] int NULL,
	[instance_id] smallint NULL,
	[state_time] datetime NULL,
	[state_time_usec] int NULL,
	[object_id] int NULL,
	[state_change] smallint NULL,
	[state] smallint NULL,
	[state_type] smallint NULL,
	[current_check_attempt] smallint NULL,
	[max_check_attempts] smallint NULL,
	[last_state] smallint NULL,
	[last_hard_state] smallint NULL,
	[output] nvarchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[long_output] nvarchar(4000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([statehistory_id]))
