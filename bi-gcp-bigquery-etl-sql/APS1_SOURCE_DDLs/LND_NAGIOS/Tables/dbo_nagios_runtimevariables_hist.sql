CREATE TABLE [dbo].[nagios_runtimevariables_hist]
(
	[runtimevariable_id] int NULL,
	[instance_id] smallint NULL,
	[varname] nvarchar(64) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(2) NOT NULL
)
WITH(HEAP, DISTRIBUTION = HASH([runtimevariable_id]))
