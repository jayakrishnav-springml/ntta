CREATE TABLE [Stage].[PmCaseTypes]
(
	[CaseTypeID] bigint NOT NULL,
	[CaseType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[CaseTypeDesc] varchar(128) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsVisible] bit NULL,
	[FetchAPIURL] varchar(500) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Parent_CaseTypeID] bigint NOT NULL,
	[Remarks] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CaseCreatedNotificationTrigger] int NULL,
	[VisibleSelfServiceChannel] bit NULL,
	[CustomerSurveyTrigger] bit NULL,
	[CaseClosureNotificationTrigger] int NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([CaseTypeID] ASC), DISTRIBUTION = HASH([CaseTypeID]))
