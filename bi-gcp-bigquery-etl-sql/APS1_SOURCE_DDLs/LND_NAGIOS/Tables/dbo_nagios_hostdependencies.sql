CREATE TABLE [dbo].[nagios_hostdependencies]
(
	[hostdependency_id] int NULL,
	[instance_id] smallint NULL,
	[config_type] smallint NULL,
	[host_object_id] int NULL,
	[dependent_host_object_id] int NULL,
	[dependency_type] smallint NULL,
	[inherits_parent] smallint NULL,
	[timeperiod_object_id] int NULL,
	[fail_on_up] smallint NULL,
	[fail_on_down] smallint NULL,
	[fail_on_unreachable] smallint NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([hostdependency_id]))
