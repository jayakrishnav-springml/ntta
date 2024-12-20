CREATE TABLE [dbo].[Dim_DPSTrooper]
(
	[DPSTrooperID] bigint NOT NULL,
	[FirstName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LastName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Area] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[District] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IDNumber] int NULL,
	[Region] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ChannelID] int NULL,
	[ICNID] bigint NULL,
	[TrooperSignatureImage] varchar(1000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsActive] int NULL,
	[FilePathConfigurationID] int NULL,
	[CreatedDate] datetime2(7) NOT NULL,
	[LND_UpdateDate] datetime2(7) NULL,
	[EDW_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([DPSTrooperID] ASC), DISTRIBUTION = REPLICATE)
