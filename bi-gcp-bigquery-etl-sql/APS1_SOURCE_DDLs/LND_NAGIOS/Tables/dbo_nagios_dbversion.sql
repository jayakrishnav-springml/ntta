CREATE TABLE [dbo].[nagios_dbversion]
(
	[name] nvarchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[version] nvarchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([name]))
