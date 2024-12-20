CREATE TABLE [TollPlus].[VehicleClasses]
(
	[VehicleClassID] int NOT NULL,
	[VehicleClassCode] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Name] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleClassDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ThresholdAmount] decimal(19,2) NULL,
	[TagDeposit] decimal(19,2) NULL,
	[StartEffectiveDate] datetime2(3) NULL,
	[EndEffectiveDate] datetime2(3) NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([VehicleClassID] DESC), DISTRIBUTION = HASH([VehicleClassID]))
