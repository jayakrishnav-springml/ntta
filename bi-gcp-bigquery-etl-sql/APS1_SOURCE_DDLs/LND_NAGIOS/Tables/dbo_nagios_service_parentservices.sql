CREATE TABLE [dbo].[nagios_service_parentservices]
(
	[service_parentservice_id] int NULL,
	[instance_id] smallint NULL,
	[service_id] int NULL,
	[parent_service_object_id] int NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([service_parentservice_id]))
