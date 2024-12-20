CREATE TABLE [dbo].[Dim_TripIdentMethod]
(
	[TripIdentMethodID] smallint NULL,
	[TripIdentMethodCode] varchar(7) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[TripIdentMethod] varchar(9) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL
)
WITH(CLUSTERED INDEX ([TripIdentMethodID] ASC), DISTRIBUTION = REPLICATE)
