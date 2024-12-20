CREATE TABLE [Temp].[TartTPTrip_BKUP_20221202]
(
	[TartID] bigint NULL,
	[TPTripID] bigint NOT NULL,
	[PMTY_ID] bigint NULL,
	[TXID_ID] bigint NULL,
	[LEVEL_0] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[VIOLATION_ID] bigint NOT NULL,
	[TTXN_ID] bigint NOT NULL,
	[EarnedRev] decimal(19,2) NULL,
	[ActualRev] decimal(19,2) NULL,
	[EARNED_AXLES] int NULL,
	[ACTUAL_AXLES] int NULL,
	[RecordType] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[EDW_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([TPTripID]))
