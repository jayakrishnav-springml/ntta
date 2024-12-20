CREATE TABLE [Stage].[ICN_Items]
(
	[ICN_ItemID] bigint NOT NULL,
	[ICNID] bigint NOT NULL,
	[ItemType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ItemActiongroup] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ItemCount] int NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([ICN_ItemID] DESC), DISTRIBUTION = HASH([ICN_ItemID]))
