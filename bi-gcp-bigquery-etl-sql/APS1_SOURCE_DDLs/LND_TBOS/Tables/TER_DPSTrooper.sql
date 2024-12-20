CREATE TABLE [TER].[DPSTrooper]
(
	[DPSTrooperID] bigint NOT NULL,
	[FirstName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LastName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Area] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[District] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IDNumber] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Region] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ChannelID] int NULL,
	[ICNID] bigint NULL,
	[TrooperSignatureImage] varchar(1000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsActive] bit NULL,
	[FilePathConfigurationID] smallint NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([DPSTrooperID] ASC), DISTRIBUTION = HASH([DPSTrooperID]))
