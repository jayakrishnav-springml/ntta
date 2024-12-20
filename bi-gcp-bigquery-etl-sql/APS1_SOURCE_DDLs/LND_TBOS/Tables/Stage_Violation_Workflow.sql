CREATE TABLE [Stage].[Violation_Workflow]
(
	[WorkflowID] int NOT NULL,
	[Stage] varchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Status] varchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Type] varchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Description] varchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsManualChangesAllowed] bit NULL,
	[IsAvailbleForUse] bit NULL,
	[TemplateName] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([WorkflowID] DESC), DISTRIBUTION = HASH([WorkflowID]))
