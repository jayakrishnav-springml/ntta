CREATE TABLE [dbo].[ChargeBack_Received]
(
	[MonthID] int NULL,
	[EntityLevel] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EntityID] int NULL,
	[StatusFlag] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[SequenceNumber] int NULL,
	[TransactionDivisionNumber] int NULL,
	[MerchantOrderNumber] int NULL,
	[AccountNumber] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ReasonCode] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[OriginalTransactionDate] datetime2(3) NULL,
	[ChargebackReceivedDate] datetime2(3) NULL,
	[ActivityDate] datetime2(3) NULL,
	[ChargebackAmount] decimal(19,2) NULL,
	[CBCycle] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = REPLICATE)
