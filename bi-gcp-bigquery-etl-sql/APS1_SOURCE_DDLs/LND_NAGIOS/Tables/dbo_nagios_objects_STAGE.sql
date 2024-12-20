CREATE TABLE [dbo].[nagios_objects_STAGE]
(
	[object_id] int NOT NULL,
	[instance_id] smallint NOT NULL,
	[objecttype_id] smallint NOT NULL,
	[name1] varchar(128) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[name2] varchar(128) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[is_active] smallint NOT NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([object_id]))
