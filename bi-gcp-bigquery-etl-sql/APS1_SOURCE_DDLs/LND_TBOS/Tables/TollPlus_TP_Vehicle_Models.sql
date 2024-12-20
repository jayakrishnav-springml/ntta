CREATE TABLE [TollPlus].[TP_Vehicle_Models]
(
	[VehicleModelID] int NOT NULL,
	[Make] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Model] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ModelDesc] varchar(60) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleClass] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[MakeDesc] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RecommendedTagType] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Mounting] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([VehicleModelID] DESC), DISTRIBUTION = HASH([VehicleModelID]))
