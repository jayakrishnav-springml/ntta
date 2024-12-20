CREATE TABLE [dbo].[nagios_hostgroups_STAGE]
(
	[hostgroup_id] int NULL,
	[instance_id] smallint NULL,
	[config_type] smallint NULL,
	[hostgroup_object_id] int NULL,
	[alias] nvarchar(2048) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([hostgroup_id]))
