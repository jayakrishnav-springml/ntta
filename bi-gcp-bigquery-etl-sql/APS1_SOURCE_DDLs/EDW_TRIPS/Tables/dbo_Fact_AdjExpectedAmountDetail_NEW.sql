CREATE TABLE [dbo].[Fact_AdjExpectedAmountDetail_NEW]
(
	[TpTripID] bigint NOT NULL,
	[CustTripID] bigint NULL,
	[CitationID] bigint NULL,
	[CurrentTxnFlag] bit NULL,
	[TripDayID] int NULL,
	[SourceID] bigint NULL,
	[SourceName] varchar(40) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TollAdjustmentID] int NULL,
	[AdjustmentReason] varchar(250) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TxnSeqAsc] bigint NULL,
	[TxnDate] datetime2(3) NULL,
	[Amount] decimal(38,2) NULL,
	[RunningTotalAmount] decimal(38,2) NULL,
	[RunningAllAdjAmount] decimal(38,2) NULL,
	[RunningTripWithAdjAmount] decimal(38,2) NULL,
	[TxnSeqDesc] bigint NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[EDW_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([TpTripID] ASC), DISTRIBUTION = HASH([TpTripID]))
