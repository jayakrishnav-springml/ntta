CREATE TABLE [Ref].[TartTPTrip]
(
	[TartID] decimal(18,0) NULL,
	[TPTripID] bigint NOT NULL,
	[TripDayID] int NOT NULL,
	[PMTY_ID] decimal(14,0) NULL,
	[TXID_ID] decimal(14,0) NULL,
	[LEVEL_0] varchar(19) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[VIOLATION_ID] decimal(38,10) NOT NULL,
	[TTXN_ID] bigint NOT NULL,
	[EarnedRev] decimal(6,2) NULL,
	[ActualRev] decimal(6,2) NULL,
	[EARNED_AXLES] int NULL,
	[ACTUAL_AXLES] int NULL,
	[SourceOfEntry] tinyint NULL,
	[RecordType] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EDW_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([TPTripID]))
