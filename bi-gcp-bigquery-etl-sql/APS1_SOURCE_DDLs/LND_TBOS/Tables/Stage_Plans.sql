CREATE TABLE [Stage].[Plans]
(
	[PlanID] int NOT NULL,
	[PlanName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PlanCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PlanDescription] varchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ParentID] int NOT NULL,
	[IsFeeRequired] bit NOT NULL,
	[IsTagRequired] bit NOT NULL,
	[StatementCycleID] int NULL,
	[StartEffectiveDate] datetime2(3) NOT NULL,
	[EndEffectiveDate] datetime2(3) NOT NULL,
	[InvoiceInterValid] int NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([PlanID] DESC), DISTRIBUTION = HASH([PlanID]))
