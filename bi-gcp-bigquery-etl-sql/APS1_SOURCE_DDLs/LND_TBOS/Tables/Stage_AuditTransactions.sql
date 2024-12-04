CREATE TABLE [Stage].[AuditTransactions]
(
	[TrxnauditID_PK] bigint NOT NULL,
	[AuditsetupID] bigint NULL,
	[AuditType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[BatchID] bigint NULL,
	[TransactionID] bigint NULL,
	[AgencyCode] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[PlazaID] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LaneID] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[TranID] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[VehicleClass] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TransactionDate] date NOT NULL,
	[TransactionTime] int NULL,
	[PlateRegistration] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PlateJurisdiction] varchar(8) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PlateTypePrefix] varchar(8) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PlateTypeSuffix] varchar(8) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RepresentativeImageID] bigint NULL,
	[RepresentativeImageID2] bigint NULL,
	[StatusID] int NULL,
	[StatusDate] datetime2(0) NULL,
	[EIPReceivedDate] datetime2(0) NULL,
	[IsAIPProcessed] smallint NULL,
	[IsAgree] smallint NULL,
	[UnreadReasonCode] int NULL,
	[DispositionCode] int NULL,
	[FirstReviewer] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[DoubleBlindReviewer] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[DoubleBlindDate] datetime2(0) NULL,
	[AuditComments] varchar(500) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[DoubleBlindReviewerComments] varchar(500) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[SpotCheckStatus] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsCSVGenerated] smallint NULL,
	[SpotCheckReviewedDate] datetime2(0) NULL,
	[SpotCheckReviewer] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PreviousStatusID] int NULL,
	[PreviousReviewerName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EIPCompletionDate] datetime2(0) NULL,
	[PlateType] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(0) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(0) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([TrxnauditID_PK] ASC), DISTRIBUTION = HASH([TrxnauditID_PK]))
