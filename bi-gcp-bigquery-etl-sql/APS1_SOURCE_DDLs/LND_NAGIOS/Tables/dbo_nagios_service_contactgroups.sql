CREATE TABLE [dbo].[nagios_service_contactgroups]
(
	[service_contactgroup_id] int NULL,
	[instance_id] smallint NULL,
	[service_id] int NULL,
	[contactgroup_object_id] int NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([service_contactgroup_id]))
