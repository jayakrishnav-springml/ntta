CREATE TABLE [dbo].[nagios_instances]
(
	[instance_id] smallint NULL,
	[instance_name] nvarchar(64) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[instance_description] nvarchar(128) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([instance_id]))
