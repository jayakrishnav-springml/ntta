CREATE TABLE [dbo].[Dim_POSLocation]
(
	[POSID] bigint NOT NULL,
	[POSName] varchar(500) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[POSCode] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[POSDesc] varchar(800) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Address1] varchar(150) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[City] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[State] varchar(7) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ZipCode] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LocationType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EDW_UpdateDate] datetime2(7) NOT NULL
)
WITH(CLUSTERED INDEX ([POSID] ASC), DISTRIBUTION = REPLICATE)
