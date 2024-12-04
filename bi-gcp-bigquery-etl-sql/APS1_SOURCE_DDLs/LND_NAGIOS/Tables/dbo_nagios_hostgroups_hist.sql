CREATE TABLE [dbo].[nagios_hostgroups_hist]
(
	[hostgroup_id] int NULL,
	[instance_id] smallint NULL,
	[config_type] smallint NULL,
	[hostgroup_object_id] int NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([hostgroup_id]))
