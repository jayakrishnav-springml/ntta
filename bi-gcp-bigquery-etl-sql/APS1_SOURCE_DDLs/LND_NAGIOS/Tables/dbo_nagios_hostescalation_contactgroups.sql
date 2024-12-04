CREATE TABLE [dbo].[nagios_hostescalation_contactgroups]
(
	[hostescalation_contactgroup_id] int NULL,
	[instance_id] smallint NULL,
	[hostescalation_id] int NULL,
	[contactgroup_object_id] int NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([hostescalation_contactgroup_id]))
