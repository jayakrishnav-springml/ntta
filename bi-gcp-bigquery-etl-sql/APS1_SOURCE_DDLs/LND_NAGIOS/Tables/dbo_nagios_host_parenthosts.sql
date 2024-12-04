CREATE TABLE [dbo].[nagios_host_parenthosts]
(
	[host_parenthost_id] int NULL,
	[instance_id] smallint NULL,
	[host_id] int NULL,
	[parent_host_object_id] int NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([host_parenthost_id]))
