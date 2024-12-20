CREATE TABLE [dbo].[Dim_RecordType]
(
	[RecordTypeID] smallint NULL,
	[RecordType] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RecordFormat] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[SourceOfEntry] smallint NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[EDW_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([RecordTypeID] ASC), DISTRIBUTION = REPLICATE)
