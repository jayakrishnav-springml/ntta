CREATE TABLE [Temp].[TP_ViolatedTrips]
(
	[CitationID] bigint NOT NULL,
	[TpTripID] bigint NOT NULL,
	[ViolatorID] bigint NOT NULL,
	[VehicleNumber] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[VehicleState] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleClass] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleID] bigint NULL,
	[TollAmount] decimal(19,2) NOT NULL,
	[FeeAmounts] decimal(19,2) NOT NULL,
	[OutstandingAmount] decimal(19,2) NOT NULL,
	[CitationStage] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[CitationType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[EntryLaneID] int NOT NULL,
	[ExitLaneID] int NOT NULL,
	[EntryPlazaID] int NOT NULL,
	[ExitPlazaID] int NOT NULL,
	[TripStageID] int NULL,
	[TripStatusID] int NOT NULL,
	[TripStatusDate] datetime2(3) NULL,
	[StageModifiedDate] datetime2(3) NULL,
	[EntryTripDateTime] datetime2(3) NULL,
	[ExitTripDateTime] datetime2(3) NULL,
	[PaymentStatusID] bigint NULL,
	[TransactionTypeID] tinyint NULL,
	[PlateType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AgencyID] bigint NULL,
	[PBMTollAmount] decimal(19,2) NULL,
	[AVITollAmount] decimal(19,2) NULL,
	[LicensePlateCountry] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LocationID] int NULL,
	[CustRefID] bigint NULL,
	[IsImmediateFlag] bit NULL,
	[NetAmount] decimal(19,2) NULL,
	[SourceOfEntry] tinyint NULL,
	[AccountAgencyID] bigint NULL,
	[Acct_ID] bigint NULL,
	[Violation_ID] bigint NULL,
	[Violation_Status] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsExcessiveVToll] bit NOT NULL,
	[TransactionPostingType] varchar(25) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[PostedDate] datetime2(3) NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = ROUND_ROBIN)
