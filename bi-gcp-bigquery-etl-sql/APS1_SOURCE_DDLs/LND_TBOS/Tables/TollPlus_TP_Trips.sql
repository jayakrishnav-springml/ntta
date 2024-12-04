CREATE TABLE [TollPlus].[TP_Trips]
(
	[TpTripID] bigint NOT NULL,
	[Entry_TollTxnID] bigint NOT NULL,
	[Exit_TollTxnID] bigint NOT NULL,
	[EntryTripDateTime] datetime2(3) NULL,
	[EntryTripDateTimeUTC] datetime2(3) NULL,
	[ExitTripDateTime] datetime2(3) NULL,
	[ExitTripDateTimeUTC] datetime2(3) NULL,
	[TripIdentMethod] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TripChargeType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EntryLaneID] int NULL,
	[EntryPlazaID] int NULL,
	[ExitLaneID] int NULL,
	[ExitPlazaID] int NULL,
	[LaneType] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleNumber] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleID] bigint NULL,
	[VehicleState] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleClass] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TagRefID] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TollAmount] decimal(19,2) NULL,
	[ReceivedTollAmount] decimal(19,2) NULL,
	[FeeAmounts] decimal(19,2) NULL,
	[DiscountsAmount] decimal(19,2) NULL,
	[OutstandingAmount] decimal(19,2) NULL,
	[TripStageID] int NULL,
	[TripStatusID] int NULL,
	[TripStatusDate] datetime2(3) NULL,
	[PostedDate] datetime2(3) NULL,
	[IRTripID] bigint NULL,
	[PaymentStatusID] bigint NULL,
	[ReasonCode] varchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[SourceTripID] bigint NULL,
	[TagVehicleClass] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TagType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TransactionTypeID] tinyint NULL,
	[PlateType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IPSTransactionID] bigint NULL,
	[PBMTollAmount] decimal(19,2) NULL,
	[AVITollAmount] decimal(19,2) NULL,
	[OriginalPBMTollAmount] decimal(19,2) NULL,
	[OriginalAVITollAmount] decimal(19,2) NULL,
	[LicensePlateCountry] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LocationID] int NULL,
	[AgencyID] bigint NULL,
	[Disposition] varchar(2) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ReceivedDate] datetime2(3) NULL,
	[TagAgency] varchar(6) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TagAgencyID] int NULL,
	[SourceOfEntry] tinyint NULL,
	[AccountAgencyID] bigint NULL,
	[IsImageReviewed] bit NULL,
	[SourceTXNID] bigint NULL,
	[LinkID] bigint NULL,
	[TripWith] varchar(2) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsNonRevenue] bit NOT NULL,
	[TXNRate] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TransactionPostingType] varchar(25) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[SourceID] bigint NULL,
	[SourceName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Acct_ID] bigint NULL,
	[TTXN_ID] bigint NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([TpTripID] ASC), DISTRIBUTION = HASH([TpTripID]))
