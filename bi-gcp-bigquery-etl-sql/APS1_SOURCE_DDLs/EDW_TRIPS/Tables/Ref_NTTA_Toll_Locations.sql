CREATE TABLE [Ref].[NTTA_Toll_Locations]
(
	[ObjectID] int NULL,
	[FromStatiion] decimal(16,12) NULL,
	[Corridor] varchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RoadwayName] varchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RoadwayType] varchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RoadwayDescription] varchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Name] varchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RiteName] varchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Type] varchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[XCoord] decimal(16,12) NULL,
	[YCoord] decimal(16,12) NULL
)
WITH(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = REPLICATE)
