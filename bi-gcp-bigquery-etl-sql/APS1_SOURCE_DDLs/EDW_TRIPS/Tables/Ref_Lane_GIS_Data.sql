CREATE TABLE [Ref].[Lane_GIS_Data]
(
	[LaneID] int NOT NULL,
	[Status] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LaneName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[TollLocation] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Description] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Type] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[PlazaID] int NULL,
	[ID] int NOT NULL,
	[Source] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LaneDirection] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Zipcode] int NOT NULL,
	[PCName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[County] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Latitude] decimal(19,8) NOT NULL,
	[Longitude] decimal(19,8) NOT NULL,
	[PlazaSortOrder] int NOT NULL
)
WITH(CLUSTERED INDEX ([LaneID] ASC), DISTRIBUTION = REPLICATE)
