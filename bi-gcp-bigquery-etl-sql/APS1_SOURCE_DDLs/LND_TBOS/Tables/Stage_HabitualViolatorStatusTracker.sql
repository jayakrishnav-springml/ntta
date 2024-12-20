CREATE TABLE [Stage].[HabitualViolatorStatusTracker]
(
	[HVStatusID] bigint NOT NULL,
	[HVID] bigint NOT NULL,
	[ParentStatus] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[SubStatus] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[StatusStartDate] datetime2(3) NOT NULL,
	[StatusEndDate] datetime2(3) NULL,
	[CreatedDate] datetime2(3) NULL,
	[CreatedUser] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NULL,
	[UpdatedUser] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([HVStatusID] ASC), DISTRIBUTION = HASH([HVStatusID]))
