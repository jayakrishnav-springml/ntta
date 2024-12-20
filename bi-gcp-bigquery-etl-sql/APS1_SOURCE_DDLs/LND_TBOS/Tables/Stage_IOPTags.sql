CREATE TABLE [Stage].[IOPTags]
(
	[IOPPKID] bigint NOT NULL,
	[StartDate] datetime2(3) NULL,
	[EndDate] datetime2(3) NULL,
	[LastFilets] datetime2(3) NULL,
	[Updatets] datetime2(3) NULL,
	[FileAgencyID] varchar(4) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TagStatus] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TagType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[DiscountPlan] varchar(12) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[DiscPlanStartDate] datetime2(3) NULL,
	[DiscPlanEndDate] datetime2(3) NULL,
	[TagClass] varchar(4) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AccountNo] bigint NULL,
	[FleetIn] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[StartFileID] bigint NULL,
	[EndFileID] bigint NULL,
	[TagAgencyID] varchar(4) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TagSerialNumber] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([IOPPKID] DESC), DISTRIBUTION = HASH([IOPPKID]))
