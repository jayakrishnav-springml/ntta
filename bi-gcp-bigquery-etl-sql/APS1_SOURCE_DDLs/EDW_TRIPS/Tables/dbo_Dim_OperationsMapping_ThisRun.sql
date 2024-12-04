CREATE TABLE [dbo].[Dim_OperationsMapping_ThisRun]
(
	[OperationsMappingID] int NOT NULL,
	[TripIdentMethod] varchar(9) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[TripWith] char(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TransactionPostingType] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[TripStageCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[TripStatusCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[ReasonCode] varchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[CitationStageCode] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[TripPaymentStatusDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[SourceName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[OperationsAgency] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[BadAddressFlag] smallint NULL,
	[NonRevenueFlag] smallint NULL,
	[BusinessRuleMatchedFlag] smallint NULL,
	[Mapping] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[MappingDetailed] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[PursUnpursStatus] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[TripIdentMethodID] int NOT NULL,
	[TripIdentMethodCode] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[TransactionPostingTypeID] int NOT NULL,
	[TransactionPostingTypeDesc] varchar(500) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[TripStageID] bigint NOT NULL,
	[TripStageDesc] varchar(250) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[TripStatusID] bigint NOT NULL,
	[TripStatusDesc] varchar(250) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[ReasonCodeID] bigint NULL,
	[CitationStageID] int NOT NULL,
	[CitationStageDesc] varchar(256) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[TripPaymentStatusID] int NOT NULL,
	[TripPaymentStatusCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[MSTR_UpdateUser] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[MSTR_UpdateDate] datetime2(3) NULL,
	[EDW_UpdateDate] datetime2(3) NOT NULL,
	[BackupDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([OperationsMappingID] ASC), DISTRIBUTION = REPLICATE)
