CREATE TABLE [TollPlus].[Agencies]
(
	[AgencyID] bigint NOT NULL,
	[AgencyTypeID] int NOT NULL,
	[AgencyName] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AgencyCode] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[AgencyDesc] varchar(250) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IFSCCode] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AccountType] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[BankName] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AccountName] varchar(200) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AccountNumber] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RangeID] int NULL,
	[StartFacilityCode] int NULL,
	[EndFacilityCode] int NULL,
	[TagCount] int NULL,
	[CustomerID] bigint NULL,
	[StartHexID] varchar(8) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EndHexID] varchar(8) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RevCode] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EncryptFlag] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PGPKeyID] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[FTPURL] varchar(40) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[FTPLogin] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[FTPPwd] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsActive] bit NOT NULL,
	[StartEffectiveDate] datetime2(3) NOT NULL,
	[EndEffectiveDate] datetime2(3) NOT NULL,
	[IsSwitchable] bit NULL,
	[ProtocolType] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsHomeAgency] bit NULL,
	[ParentAgencyCode] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IOPAgencyID] varchar(4) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[HubID] varchar(4) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TagAgencyID] varchar(4) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ChannelID] int NULL,
	[ICNID] bigint NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([AgencyID] ASC), DISTRIBUTION = HASH([AgencyID]))
