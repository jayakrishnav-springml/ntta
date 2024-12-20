CREATE TABLE [TranProcessing].[RecordTypes]
(
	[RecID] int NOT NULL,
	[RecordTypeCode] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RecordFormat] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[SourceOfEntry] int NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([RecID] ASC), DISTRIBUTION = HASH([RecID]))
