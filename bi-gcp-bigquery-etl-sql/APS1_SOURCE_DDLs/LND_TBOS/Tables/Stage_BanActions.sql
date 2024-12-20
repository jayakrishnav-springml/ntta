CREATE TABLE [Stage].[BanActions]
(
	[BanActionID] bigint NOT NULL,
	[VehicleBanID] bigint NULL,
	[BanAction] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IssuedDate] datetime2(3) NULL,
	[IssuedBy] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LinkID] bigint NULL,
	[LinkSource] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[FileUpload] varchar(500) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[FilePathConfigurationID] smallint NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([BanActionID] ASC), DISTRIBUTION = HASH([BanActionID]))
