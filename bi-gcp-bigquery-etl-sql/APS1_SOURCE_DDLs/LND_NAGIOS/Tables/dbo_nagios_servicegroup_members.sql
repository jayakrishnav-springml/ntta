CREATE TABLE [dbo].[nagios_servicegroup_members]
(
	[servicegroup_member_id] int NULL,
	[instance_id] smallint NULL,
	[servicegroup_id] int NULL,
	[service_object_id] int NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([servicegroup_member_id]))
