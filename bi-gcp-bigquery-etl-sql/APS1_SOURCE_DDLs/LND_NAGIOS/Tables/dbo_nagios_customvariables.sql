CREATE TABLE [dbo].[nagios_customvariables]
(
	[customvariable_id] int NULL,
	[instance_id] smallint NULL,
	[object_id] int NULL,
	[config_type] smallint NULL,
	[has_been_modified] smallint NULL,
	[varname] nvarchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[varvalue] nvarchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([customvariable_id]))
