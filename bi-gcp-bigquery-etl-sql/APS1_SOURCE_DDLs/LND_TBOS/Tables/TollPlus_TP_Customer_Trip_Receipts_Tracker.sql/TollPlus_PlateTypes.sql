CREATE TABLE [TollPlus].[PlateTypes]
(
	[PlateTypeID] bigint NOT NULL,
	[PlateType] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PlateTypeDesc] varchar(200) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[StateCode] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CountryCode] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([PlateTypeID] ASC), DISTRIBUTION = HASH([PlateTypeID]))
