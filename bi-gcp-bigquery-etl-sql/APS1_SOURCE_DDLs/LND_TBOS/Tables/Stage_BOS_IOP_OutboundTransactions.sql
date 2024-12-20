CREATE TABLE [Stage].[BOS_IOP_OutboundTransactions]
(
	[BOSIOPTransactionID] int NOT NULL,
	[IOPID] bigint NULL,
	[TransactionTypeID] tinyint NOT NULL,
	[TagType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TransactionDate] datetime2(3) NOT NULL,
	[AgencyID] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EntryPlaza] int NULL,
	[EntryLane] int NULL,
	[TagStatus] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LicenceNumber] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LicenseState] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ExitPlaza] int NOT NULL,
	[ExitLane] int NOT NULL,
	[TransactionStatus] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ReconcilitionFileID] int NULL,
	[TollAmount] decimal(19,2) NOT NULL,
	[AcceptedAmount] decimal(19,2) NULL,
	[IsCorrected] bit NOT NULL,
	[DiscountAmount] decimal(19,2) NULL,
	[TpTripID] bigint NULL,
	[TagSerialNumber] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleClass] varchar(3) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TripMethod] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PostedDate] datetime2(3) NULL,
	[ReSubmitCount] int NULL,
	[TranFileID] bigint NULL,
	[FacilityCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PlazaCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LaneCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EntryTripDateTime] datetime2(3) NULL,
	[ExitTripDateTime] datetime2(3) NULL,
	[PlateType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[FacilityDesc] varchar(250) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EntryPlazaDesc] varchar(250) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ExitPlazaDesc] varchar(250) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EntryTripDateTimeWithTimezone] datetimeoffset(7) NULL,
	[ExitTripDateTimeWithTimezone] datetimeoffset(7) NULL,
	[LicensePlateCountry] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ViolationSerialNumber] bigint NULL,
	[VesTimestamp] datetime2(3) NULL,
	[TagAgencyID] int NULL,
	[ReSubmitReasonCode] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CorrectionReasonCode] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TransactionFlatFee] decimal(19,2) NULL,
	[TransactionPercentFee] decimal(19,2) NULL,
	[SourceOfEntry] tinyint NULL,
	[CorrectionCount] int NULL,
	[SourcePKID] bigint NULL,
	[RecordCode] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AccountAgencyID] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AdjustmentDateTime] datetime2(3) NULL,
	[PostingDisposition] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PostingDispositionReason] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AdjustmentResponsePayLoad] varchar(8000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[HomeAgencyRefID] bigint NULL,
	[Spare1] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Spare2] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Spare3] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Spare4] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Spare5] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[OtherCorrectionDescription] varchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([BOSIOPTransactionID] ASC), DISTRIBUTION = HASH([BOSIOPTransactionID]))
