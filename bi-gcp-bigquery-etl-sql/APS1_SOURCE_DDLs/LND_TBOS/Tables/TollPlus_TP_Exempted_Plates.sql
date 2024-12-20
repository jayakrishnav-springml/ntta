CREATE TABLE [TollPlus].[TP_Exempted_Plates]
(
	[QualifiedVeteranID] bigint NOT NULL,
	[VehicleNumber] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleState] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Country] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Make] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Model] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Color] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleClass] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsActive] bit NULL,
	[Exempted_Type] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Year] int NULL,
	[Agency] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[StartEffectiveDate] datetime2(3) NULL,
	[EndEffectiveDate] datetime2(3) NULL,
	[ProcessStatus] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([QualifiedVeteranID] ASC), DISTRIBUTION = HASH([QualifiedVeteranID]))
