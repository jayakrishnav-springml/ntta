CREATE TABLE [dbo].[Fact_TollTransaction_NEW]
(
	[CustTripID] bigint NOT NULL,
	[TPTripID] bigint NOT NULL,
	[TripDayID] int NOT NULL,
	[LaneID] int NOT NULL,
	[CustomerID] bigint NOT NULL,
	[VehicleID] bigint NOT NULL,
	[CustTagID] bigint NOT NULL,
	[VehicleTagID] bigint NOT NULL,
	[VehicleClassID] smallint NOT NULL,
	[PaymentStatusID] int NOT NULL,
	[TripStageID] int NOT NULL,
	[TripStatusID] int NOT NULL,
	[TripIdentMethodID] int NOT NULL,
	[TransactionPostingTypeID] int NOT NULL,
	[SourceOfEntry] tinyint NOT NULL,
	[TripDate] datetime2(3) NOT NULL,
	[PostedDate] datetime2(3) NOT NULL,
	[TripStatusDate] datetime2(3) NOT NULL,
	[AdjustedDate] datetime2(3) NOT NULL,
	[CurrentTxnFlag] bit NOT NULL,
	[DeleteFlag] bit NOT NULL,
	[TollAmount] decimal(9,2) NOT NULL,
	[FeeAmount] decimal(9,2) NOT NULL,
	[DiscountAmount] decimal(9,2) NOT NULL,
	[NetAmount] decimal(9,2) NOT NULL,
	[RewardDiscountAmount] decimal(9,2) NOT NULL,
	[OutstandingAmount] decimal(9,2) NOT NULL,
	[PBMTollAmount] decimal(9,2) NOT NULL,
	[AVITollAmount] decimal(9,2) NOT NULL,
	[AdjustedTollAmount] decimal(9,2) NOT NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[LND_UpdateDate] datetime2(3) NOT NULL,
	[EDW_UpdateDate] datetime2(3) NOT NULL,
	[TxnDatetime] datetime2(3) NOT NULL,
	[FeeAmounts] decimal(9,2) NOT NULL,
	[AdjustedTolls] decimal(9,2) NOT NULL,
	[TripIdentMethod] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RewardsDiscountAmount] decimal(9,2) NULL,
	[DiscountsAmount] decimal(9,2) NOT NULL
)
WITH(CLUSTERED INDEX ([CustTripID] ASC), DISTRIBUTION = HASH([TPTripID]))
