CREATE TABLE [Stage].[Dim_TERStatus]
(
	[StatusID] int NOT NULL,
	[StatusCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[StatusDescription] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ParentStatusID] int NULL,
	[ActiveFlag] int NOT NULL,
	[DetailedDesc] varchar(1000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(7) NULL,
	[LND_UpdateDate] datetime2(7) NULL,
	[EDW_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([StatusID] ASC), DISTRIBUTION = REPLICATE)
