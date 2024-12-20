CREATE TABLE [dbo].[nagios_configfiles_hist]
(
	[configfile_id] int NULL,
	[instance_id] smallint NULL,
	[configfile_type] smallint NULL,
	[configfile_path] nvarchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([configfile_id]))
