CREATE TABLE [dbo].[Dim_VehicleClass]
(
	[VehicleClassID] int NOT NULL,
	[Axles] int NOT NULL,
	[VehicleClass] varchar(7) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[VehicleClassDesc] varchar(69) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[VCLY_ID] int NOT NULL,
	[EDW_UpdatedDate] datetime2(7) NOT NULL
)
WITH(CLUSTERED INDEX ([VehicleClassID] ASC), DISTRIBUTION = REPLICATE)
