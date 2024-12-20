CREATE TABLE [TollPlus].[Merged_Customers]
(
	[MergeID] bigint NOT NULL,
	[Parent_CustomerID] bigint NULL,
	[Child_CustomerID] bigint NULL,
	[StatusID] int NULL,
	[ICNID] bigint NULL,
	[ChannelID] int NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([MergeID] DESC), DISTRIBUTION = HASH([MergeID]))
