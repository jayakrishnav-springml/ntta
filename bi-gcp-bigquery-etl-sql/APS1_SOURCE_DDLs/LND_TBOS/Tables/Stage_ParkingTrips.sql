CREATE TABLE [Stage].[ParkingTrips]
(
	[RecordCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ReferenceID] bigint NULL,
	[EntryTollTxnID] bigint NULL,
	[EntryTripDateTime] datetime2(3) NULL,
	[EntryTripDateTimeUTC] datetime2(3) NULL,
	[ExitTripDateTime] datetime2(3) NULL,
	[ExitTripDateTimeUTC] datetime2(3) NULL,
	[EntryLaneID] int NULL,
	[EntryPlazaID] int NULL,
	[ExitLaneID] int NULL,
	[ExitPlazaID] int NULL,
	[SourceTripID] bigint NULL,
	[InternalDisposition] char(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ExternalDisposition] char(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EntryTagStatus] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ExitTagStatus] char(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ExitTagStatusListBatchID] bigint NULL,
	[EntryTagStatusListBatchID] bigint NULL,
	[EntryRevenueType] smallint NULL,
	[ExitRevenueType] smallint NULL,
	[TagID] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TagVehicleClassification] smallint NULL,
	[TagAgency] varchar(6) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TollAmount] decimal(19,2) NULL,
	[ProcFeeFlat] decimal(19,2) NULL,
	[ProcFeeFlatType] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ProcFeePct] decimal(19,2) NULL,
	[ProcFeePctType] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VendOrFee] decimal(19,2) NULL,
	[SurChargeFeeType] varchar(2) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[OutstandingAmount] decimal(19,2) NULL,
	[PostedDate] datetime2(3) NULL,
	[TripStageID] int NULL,
	[TripStatusID] int NULL,
	[TripStatusDate] datetime2(3) NULL,
	[PaymentStatusID] bigint NULL,
	[Guaranteed] char(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Vendor] varchar(8000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AgencyGuestType] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AgencyTransactionType] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AgencyHostTransactionID] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleNumber] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleID] bigint NULL,
	[VehicleState] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LicensePlateCountry] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AgencyID] bigint NULL,
	[OriginatingAgencyID] bigint NULL,
	[ReasonCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Disposition] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TagAgencyID] int NULL,
	[Attribute5] varchar(40) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TransactionCreatedUser] varchar(40) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TransactionCreatedDate] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Attribute8] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Attribute9] varchar(250) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Attribute10] varchar(250) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ProcessCount] smallint NULL,
	[SourcePKID] bigint NULL,
	[TpTripID] bigint NOT NULL,
	[ExitLocationID] int NULL,
	[SourceDisposition] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[SourceReasonCode] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PreviousReasonCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsReprocessReceived] bit NOT NULL,
	[IsReprocessedFeeApplied] bit NOT NULL,
	[ReceivedEntryLocationCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ReceivedExitLocationCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([TpTripID] ASC), DISTRIBUTION = HASH([TpTripID]))
