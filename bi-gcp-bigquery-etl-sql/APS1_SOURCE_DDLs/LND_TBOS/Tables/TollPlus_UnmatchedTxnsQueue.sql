CREATE TABLE [TollPlus].[UnmatchedTxnsQueue]
(
	[QueueID] bigint NOT NULL,
	[TripID] bigint NOT NULL,
	[CustomerID] bigint NOT NULL,
	[ToCustomerID] bigint NOT NULL,
	[TransferStatusID] int NOT NULL,
	[EntryTollTxnID] bigint NOT NULL,
	[ExitTollTxnID] bigint NOT NULL,
	[EntryTripDateTime] datetime2(3) NULL,
	[ExitTripDateTime] datetime2(3) NULL,
	[TripIdentMethod] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TripChargeType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EntryLaneID] int NOT NULL,
	[EntryPlazaID] int NOT NULL,
	[ExitLaneID] int NOT NULL,
	[ExitPlazaID] int NOT NULL,
	[VehicleNumber] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleState] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleClass] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleID] bigint NULL,
	[TagRefID] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TollAmount] decimal(19,2) NOT NULL,
	[FeeAmounts] decimal(19,2) NOT NULL,
	[DiscountSAmount] decimal(19,2) NOT NULL,
	[OutstandingAmount] decimal(19,2) NOT NULL,
	[TripStageID] int NOT NULL,
	[TripStatusID] int NOT NULL,
	[TripStatusDate] datetime2(3) NOT NULL,
	[PostedDate] datetime2(3) NULL,
	[PaymentStatusID] bigint NULL,
	[TagType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TransactionTypeID] tinyint NULL,
	[RewardsDiscountAmount] decimal(19,2) NULL,
	[PlateType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Disposition] int NULL,
	[PBMTollAmount] decimal(19,2) NULL,
	[AVITollAmount] decimal(19,2) NULL,
	[LicensePlateCountry] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LocationID] int NULL,
	[AgencyID] bigint NULL,
	[NetAmount] decimal(19,2) NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([QueueID] ASC), DISTRIBUTION = HASH([QueueID]))
