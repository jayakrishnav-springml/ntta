CREATE TABLE [Stage].[TollAdjustments]
(
	[TollAdjustmentID] int NOT NULL,
	[AdjustmentType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AdjustmentTypeDesc] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsActive] bit NULL,
	[ParentAdjustmentType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ParentAdjustmentTypeDesc] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsNTTA] bit NOT NULL,
	[IsTSA] bit NOT NULL,
	[IsDALOrDFW] bit NOT NULL,
	[IsIOP] bit NOT NULL,
	[IsIOPAwayNTTA] bit NOT NULL,
	[IsIOPAwayTSA] bit NOT NULL,
	[IsOnlyInbound] bit NOT NULL,
	[IsOnlyThroughCase] bit NOT NULL,
	[CreatedDate] datetime2(3) NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([TollAdjustmentID] ASC), DISTRIBUTION = HASH([TollAdjustmentID]))
