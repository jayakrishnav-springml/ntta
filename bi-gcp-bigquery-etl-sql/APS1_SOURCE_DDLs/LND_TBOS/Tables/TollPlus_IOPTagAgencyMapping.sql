CREATE TABLE [TollPlus].[IOPTagAgencyMapping]
(
	[NTTATagAgencyID] varchar(4) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IOPTagAgencyID] varchar(4) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[HomeAgencyID] varchar(4) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[InternalTagPrefix] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[HubID] varchar(4) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IOPHomeAgencyID] varchar(4) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TID] int NOT NULL,
	[HexTagID] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Agency] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AgencyName] varchar(300) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsHomeAgency] bit NULL,
	[IsDisplayFromApplication] bit NULL,
	[IsExitDateTimeWithTz] int NOT NULL,
	[IMIParentAgency] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([TID] ASC), DISTRIBUTION = HASH([TID]))
