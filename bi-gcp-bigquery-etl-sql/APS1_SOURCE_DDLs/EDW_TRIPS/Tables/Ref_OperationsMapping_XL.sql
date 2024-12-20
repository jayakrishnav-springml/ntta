CREATE TABLE [Ref].[OperationsMapping_XL]
(
	[Unique_XL_OpsMappingID] bigint NULL,
	[RN] bigint NULL,
	[AsOfDayID] int NULL,
	[TripIdentMethod] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TripWith] char(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TransactionPostingType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TripStageID] bigint NULL,
	[TripStageCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TripStatusID] bigint NULL,
	[TripStatusCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ReasonCode] varchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CitationStageCode] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TripPaymentStatusID] int NULL,
	[TripPaymentStatusDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[SourceName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[OperationsAgency] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[BadAddressFlag] smallint NULL,
	[NonRevenueFlag] smallint NULL,
	[BusinessRuleMatchedFlag] smallint NULL,
	[Mapping] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[MappingDetailed] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PursUnpursStatus] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(HEAP, DISTRIBUTION = ROUND_ROBIN)
