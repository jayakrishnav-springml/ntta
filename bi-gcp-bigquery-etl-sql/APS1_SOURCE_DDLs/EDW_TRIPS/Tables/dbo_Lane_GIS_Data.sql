CREATE TABLE [dbo].[Lane_GIS_Data]
(
	[LaneID] int NOT NULL,
	[PlazaID] int NOT NULL,
	[LaneName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Direction] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Latitude] decimal(23,12) NULL,
	[Longitude] decimal(23,12) NULL,
	[ZipCode] int NULL,
	[County] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Mileage] decimal(8,2) NOT NULL,
	[Active] int NOT NULL,
	[PlazaSortOrder] int NULL
)
WITH(CLUSTERED INDEX ([LaneID] ASC), DISTRIBUTION = REPLICATE)
