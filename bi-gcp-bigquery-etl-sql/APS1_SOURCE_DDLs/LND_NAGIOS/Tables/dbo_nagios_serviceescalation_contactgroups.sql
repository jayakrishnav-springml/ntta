CREATE TABLE [dbo].[nagios_serviceescalation_contactgroups]
(
	[serviceescalation_contactgroup_id] int NULL,
	[instance_id] smallint NULL,
	[serviceescalation_id] int NULL,
	[contactgroup_object_id] int NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([serviceescalation_contactgroup_id]))
