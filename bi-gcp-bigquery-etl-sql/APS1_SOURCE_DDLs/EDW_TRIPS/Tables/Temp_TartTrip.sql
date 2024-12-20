CREATE TABLE [Temp].[TartTrip]
(
	[TART_ID] decimal(18,0) NULL,
	[TpTripID] bigint NOT NULL,
	[VIOLATION_ID] decimal(38,10) NOT NULL,
	[TTXN_ID] bigint NOT NULL,
	[EARNED_REV] decimal(9,2) NULL,
	[ACTUAL_REV] decimal(9,2) NULL,
	[EARNED_AXLES] int NULL,
	[ACTUAL_AXLES] int NULL,
	[PMTY_ID] decimal(14,0) NULL,
	[TXID_ID] decimal(14,0) NULL,
	[LEVEL_0] varchar(19) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL
)
WITH(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([TpTripID]))
