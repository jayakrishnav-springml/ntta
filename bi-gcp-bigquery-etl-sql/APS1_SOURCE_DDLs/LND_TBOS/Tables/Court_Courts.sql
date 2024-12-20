CREATE TABLE [Court].[Courts]
(
	[CourtID] smallint NOT NULL,
	[CountyID] smallint NOT NULL,
	[CourtName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[AddressLine1] varchar(150) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[AddressLine2] varchar(150) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[City] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[State] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Zip1] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Zip2] varchar(4) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[StartEffectiveDate] datetime2(3) NOT NULL,
	[EndEffectiveDate] datetime2(3) NULL,
	[PrecinctNumber] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PlaceNumber] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TelephoneNumber] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([CourtID] ASC), DISTRIBUTION = HASH([CourtID]))
