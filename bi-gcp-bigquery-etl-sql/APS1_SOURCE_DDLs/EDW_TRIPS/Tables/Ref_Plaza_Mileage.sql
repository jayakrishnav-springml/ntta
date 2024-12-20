CREATE TABLE [Ref].[Plaza_Mileage]
(
	[PlazaID] decimal(18,0) NOT NULL,
	[LaneDirection] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Mileage] decimal(8,2) NULL
)
WITH(CLUSTERED INDEX ([PlazaID] ASC), DISTRIBUTION = REPLICATE)
