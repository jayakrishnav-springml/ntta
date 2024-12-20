CREATE TABLE [dbo].[nagios_servicedependencies]
(
	[servicedependency_id] int NULL,
	[instance_id] smallint NULL,
	[config_type] smallint NULL,
	[service_object_id] int NULL,
	[dependent_service_object_id] int NULL,
	[dependency_type] smallint NULL,
	[inherits_parent] smallint NULL,
	[timeperiod_object_id] int NULL,
	[fail_on_ok] smallint NULL,
	[fail_on_warning] smallint NULL,
	[fail_on_unknown] smallint NULL,
	[fail_on_critical] smallint NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([servicedependency_id]))
