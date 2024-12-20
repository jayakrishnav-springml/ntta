CREATE TABLE [dbo].[nagios_configfilevariables]
(
	[configfilevariable_id] int NULL,
	[instance_id] smallint NULL,
	[configfile_id] int NULL,
	[varname] nvarchar(64) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[varvalue] nvarchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([configfilevariable_id]))
