CREATE TABLE [CaseManager].[PmCase]
(
	[CaseID] bigint NOT NULL,
	[CaseTypeID] bigint NOT NULL,
	[CaseSource] int NOT NULL,
	[CaseTitle] varchar(128) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[DateReported] datetime2(3) NOT NULL,
	[ICNID] bigint NULL,
	[PriorityID] int NULL,
	[StatusID] int NULL,
	[CurrentCaseTypeActivityID] bigint NULL,
	[AssignedTo] bigint NULL,
	[JSONData] varchar(8000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CustomerID] bigint NULL,
	[DueDate] datetime2(3) NULL,
	[SLAExpiryDate] datetime2(3) NULL,
	[Remarks] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CurrentActivityStatusID] int NULL,
	[RoleCaseTypeActCustTypeStatusID] bigint NULL,
	[ClosureReasonCode] int NULL,
	[ChannelID] int NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([CaseID] ASC), DISTRIBUTION = HASH([CaseID]))
