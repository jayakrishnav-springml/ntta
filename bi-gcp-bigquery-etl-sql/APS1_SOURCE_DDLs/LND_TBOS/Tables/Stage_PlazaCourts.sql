CREATE TABLE [Stage].[PlazaCourts]
(
	[PlazaCourtID] smallint NOT NULL,
	[PlazaID] int NOT NULL,
	[CourtID] smallint NOT NULL,
	[MileMarker] int NULL,
	[IsActive] bit NOT NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([PlazaCourtID] ASC), DISTRIBUTION = HASH([PlazaCourtID]))
