CREATE TABLE [dbo].[nagios_contactgroups_hist]
(
	[contactgroup_id] int NULL,
	[instance_id] smallint NULL,
	[config_type] smallint NULL,
	[contactgroup_object_id] int NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([contactgroup_id]))
