CREATE TABLE [dbo].[nagios_servicegroups]
(
	[servicegroup_id] int NULL,
	[instance_id] smallint NULL,
	[config_type] smallint NULL,
	[servicegroup_object_id] int NULL,
	[alias] nvarchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([servicegroup_id]))
