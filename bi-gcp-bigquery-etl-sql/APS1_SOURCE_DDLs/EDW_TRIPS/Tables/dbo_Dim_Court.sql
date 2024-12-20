CREATE TABLE [dbo].[Dim_Court]
(
	[CourtID] int NOT NULL,
	[CountyID] int NOT NULL,
	[CourtName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[AddressLine1] varchar(150) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[AddressLine2] varchar(150) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[City] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[State] varchar(7) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Zip1] int NOT NULL,
	[Zip2] int NULL,
	[StartEffectiveDate] datetime2(7) NOT NULL,
	[EndEffectiveDate] datetime2(7) NULL,
	[PrecinctNumber] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PlaceNumber] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TelephoneNumber] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(7) NULL,
	[EDW_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([CourtID] ASC), DISTRIBUTION = REPLICATE)
