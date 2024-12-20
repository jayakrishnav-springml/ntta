CREATE TABLE [Stage].[UnRegisteredCustomersMbsSchedules]
(
	[UnRegMbsScheduleID] bigint NOT NULL,
	[CustomerID] bigint NULL,
	[VehicleID] bigint NULL,
	[NextScheduleDate] datetime2(3) NULL,
	[LastMbsID] bigint NULL,
	[LicensePlateNumber] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[StateCode] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[MbsGenStatus] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RetryAttempts] int NOT NULL,
	[ScheduledDate] datetime2(3) NULL,
	[AgencyID] bigint NULL,
	[IsImmediateFlag] bit NULL,
	[IsLoadBalance] bit NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([UnRegMbsScheduleID] ASC), DISTRIBUTION = HASH([UnRegMbsScheduleID]))
