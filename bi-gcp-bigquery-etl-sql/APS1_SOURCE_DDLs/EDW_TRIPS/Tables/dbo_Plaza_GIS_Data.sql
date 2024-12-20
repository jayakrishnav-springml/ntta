CREATE TABLE [dbo].[Plaza_GIS_Data]
(
	[PlazaID] int NOT NULL,
	[PlazaLatitude] decimal(23,12) NOT NULL,
	[PlazaLongitude] decimal(23,12) NOT NULL,
	[ZipCode] int NOT NULL,
	[COUNTY] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL
)
WITH(CLUSTERED INDEX ([PlazaID] ASC), DISTRIBUTION = REPLICATE)
