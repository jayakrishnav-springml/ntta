CREATE TABLE [TranProcessing].[TripSource]
(
	[TripSourceID] tinyint NOT NULL,
	[EntryType] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([TripSourceID] ASC), DISTRIBUTION = HASH([TripSourceID]))
