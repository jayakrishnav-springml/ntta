CREATE TABLE [IOP].[Agencies]
(
	[AgencyID] bigint NOT NULL,
	[AgencyCode] varchar(2) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AgencyDesc] varchar(40) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RangeID] int NOT NULL,
	[StartFacilityCode] int NOT NULL,
	[EndFacilityCode] int NOT NULL,
	[TagCount] int NOT NULL,
	[CustomerID] bigint NULL,
	[StartHexID] varchar(8) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EndHexID] varchar(8) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RevCode] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EncryptFlag] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PGPKeyID] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[FTPUrl] varchar(40) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[FTPLogIn] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[FTPPwd] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Active] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdateUser] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([AgencyID] DESC), DISTRIBUTION = HASH([AgencyID]))
