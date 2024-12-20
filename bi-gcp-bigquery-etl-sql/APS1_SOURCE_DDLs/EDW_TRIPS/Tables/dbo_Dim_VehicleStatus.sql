CREATE TABLE [dbo].[Dim_VehicleStatus]
(
	[VehicleStatusID] int NOT NULL,
	[VehicleStatusCode] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleStatusDesc] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EDW_UpdateDate] datetime2(7) NULL
)
WITH(CLUSTERED INDEX ([VehicleStatusID] ASC), DISTRIBUTION = REPLICATE)
