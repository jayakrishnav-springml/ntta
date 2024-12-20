CREATE TABLE [Stage].[Adjustment_LineItems]
(
	[AdjLineItemID] bigint NOT NULL,
	[AdjustmentID] bigint NOT NULL,
	[Amount] decimal(19,2) NOT NULL,
	[AppTxnTypeCode] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LinkID] bigint NULL,
	[LinkSourceName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[NewTollAmount] decimal(19,2) NULL,
	[VehicleClass] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LaneID] int NULL,
	[IsVisible] bit NOT NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([AdjLineItemID] DESC), DISTRIBUTION = HASH([AdjLineItemID]))
