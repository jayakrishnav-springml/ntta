CREATE TABLE [dbo].[Dim_Channel]
(
	[ChannelID] int NOT NULL,
	[ChannelName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[ChannelDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsActive] int NULL,
	[IsDisplay] int NOT NULL,
	[EDW_UpdateDate] datetime2(7) NOT NULL
)
WITH(CLUSTERED INDEX ([ChannelID] ASC), DISTRIBUTION = REPLICATE)
