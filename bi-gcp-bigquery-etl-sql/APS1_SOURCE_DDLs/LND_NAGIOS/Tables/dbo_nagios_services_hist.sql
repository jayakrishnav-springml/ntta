CREATE TABLE [dbo].[nagios_services_hist]
(
	[service_id] int NULL,
	[instance_id] smallint NULL,
	[config_type] smallint NULL,
	[service_object_id] int NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([service_object_id]))
