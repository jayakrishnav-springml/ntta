CREATE TABLE [Ref].[Directions]
(
	[DireDesc] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Note] varchar(200) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedBy] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[CreationDate] datetime2(0) NOT NULL,
	[UpdatedBy] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(0) NOT NULL,
	[DireID] decimal(18,0) NOT NULL,
	[LastUpdateType] char(1) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LastUpdateDate] datetime2(2) NOT NULL
)
WITH(CLUSTERED INDEX ([DireID] ASC), DISTRIBUTION = REPLICATE)
