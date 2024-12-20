CREATE TABLE [dbo].[Dim_TripStage]
(
	[TripStageID] bigint NOT NULL,
	[TripStageCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[TripStageDesc] varchar(250) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[ParentStageID] bigint NOT NULL,
	[UpdatedDate] datetime2(7) NOT NULL,
	[LND_UpdateDate] datetime2(7) NOT NULL,
	[EDW_UpdateDate] datetime2(7) NOT NULL
)
WITH(CLUSTERED INDEX ([TripStageID] ASC), DISTRIBUTION = REPLICATE)
