CREATE TABLE [dbo].[nagios_host_contactgroups]
(
	[host_contactgroup_id] int NULL,
	[instance_id] smallint NULL,
	[host_id] int NULL,
	[contactgroup_object_id] int NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([host_contactgroup_id]))
