CREATE TABLE [dbo].[Dim_TripStatus]
(
	[TripStatusID] bigint NOT NULL,
	[TripStatusCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[TripStatusDesc] varchar(250) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LND_UpdateDate] datetime2(7) NOT NULL,
	[EDW_UpdateDate] datetime2(7) NOT NULL
)
WITH(CLUSTERED INDEX ([TripStatusID] ASC), DISTRIBUTION = REPLICATE)
