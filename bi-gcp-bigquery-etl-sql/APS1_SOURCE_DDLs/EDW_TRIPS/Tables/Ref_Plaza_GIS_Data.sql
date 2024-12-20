CREATE TABLE [Ref].[Plaza_GIS_Data]
(
	[PlazaID] int NOT NULL,
	[Corridor] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[RoadwayName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[RoadwayType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[RoadwayDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Status] int NOT NULL,
	[Name] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[RiteName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Type] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[TolledLanes] int NOT NULL,
	[XCoord] decimal(19,8) NOT NULL,
	[YCoord] decimal(19,8) NOT NULL,
	[PostCode] int NOT NULL,
	[City] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[County] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL
)
WITH(HEAP, DISTRIBUTION = REPLICATE)
