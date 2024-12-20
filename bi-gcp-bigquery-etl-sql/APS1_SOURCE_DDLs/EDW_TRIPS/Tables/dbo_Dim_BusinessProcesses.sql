CREATE TABLE [dbo].[Dim_BusinessProcesses]
(
	[BusinessProcessID] int NOT NULL,
	[BusinessProcessCode] varchar(150) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[BusinessProcessDescription] varchar(8000) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Status] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsAvailable] bit NULL,
	[EDW_UpdateDate] datetime2(7) NOT NULL
)
WITH(CLUSTERED INDEX ([BusinessProcessID] ASC), DISTRIBUTION = REPLICATE)
