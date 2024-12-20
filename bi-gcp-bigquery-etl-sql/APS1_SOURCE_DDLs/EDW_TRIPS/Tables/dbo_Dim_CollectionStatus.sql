CREATE TABLE [dbo].[Dim_CollectionStatus]
(
	[CollectionStatusID] int NOT NULL,
	[CollectionStatusCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CollectionStatusDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EDW_UpdateDate] datetime2(7) NULL
)
WITH(CLUSTERED INDEX ([CollectionStatusID] ASC), DISTRIBUTION = REPLICATE)
