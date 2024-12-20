CREATE TABLE [Ref].[Bubble_XL_TRIPSDATA_Source_BKUP]
(
	[SnapshotMonthID] int NOT NULL,
	[TxnYr Mnth] int NOT NULL,
	[Facility] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Agency] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[OperationsMappingID] int NULL,
	[Mapping] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Mapping_Detailed] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Purs_UnPurs_Calc] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TRIPIDENTMETHOD] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[SourceName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[isIOPDuplicate] smallint NULL,
	[TripWith] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TransactionPostingType] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TRIPSTAGEID] bigint NULL,
	[TRIPSTAGECODE] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TRIPSTAGEDESCRIPTION] varchar(250) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TRIPSTATUSID] bigint NULL,
	[TRIPSTATUSCODE] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TRIPSTATUSDESCRIPTION] varchar(250) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[REASONCODE] varchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsNonRevenue] smallint NULL,
	[CITATIONSTAGE] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PaymentStatus] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[BadAddress] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[isOOSPlate] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[isBusinessRuleMatched] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ISMANUALLYREVIEWED] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TXNCOUNT] bigint NULL,
	[ExpectedAmount ($)] decimal(19,2) NULL,
	[AdjExpAmt] decimal(19,2) NULL,
	[PaidAmount ($)] decimal(19,2) NULL,
	[FirstPaidMonthID] int NULL,
	[LastPaidMonthID] int NULL,
	[CalcAdjustedAmount ($)] decimal(19,2) NULL,
	[OutStandingAmount ($)] decimal(19,2) NULL,
	[TripWithAdjustedAmount ($)] decimal(19,2) NULL,
	[TollAmount ($)] decimal(19,2) NULL,
	[Rpt_PaidvsAEA] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Rpt_LPState] varchar(3) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Rpt_InvUnInv] varchar(7) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Rpt_VToll] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Rpt_PurUnP] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Rpt_IRStatus] varchar(11) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Rpt_ProcessStatus] varchar(22) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Rpt_PaidStatus] varchar(18) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Rpt_IRRejectStatus] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RecordType] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(HEAP, DISTRIBUTION = ROUND_ROBIN)
