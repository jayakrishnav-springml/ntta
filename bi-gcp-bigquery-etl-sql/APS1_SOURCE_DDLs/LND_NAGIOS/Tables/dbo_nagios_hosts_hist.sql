CREATE TABLE [dbo].[nagios_hosts_hist]
(
	[host_id] int NOT NULL,
	[instance_id] smallint NOT NULL,
	[config_type] smallint NOT NULL,
	[host_object_id] int NOT NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([host_id]))
