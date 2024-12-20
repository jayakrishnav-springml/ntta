CREATE TABLE [Stage].[TRIPS_AccountStatusTracker]
(
	[CustomerID] bigint NULL,
	[DataSource] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[TableSource] varchar(16) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[CustomerStatusDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AccountTypeID] bigint NULL,
	[AccountTypeCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AccountTypeDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AccountStatusID] bigint NULL,
	[AccountStatusCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AccountStatusDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AccountStatusDate] datetime2(3) NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ChannelID] int NULL,
	[ICNID] bigint NULL,
	[EmployeeID] bigint NULL,
	[EmployeeName] varchar(121) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[POSID] bigint NULL,
	[TRIPS_AccStatusHistID] int NULL,
	[TRIPS_HistID] bigint NULL
)
WITH(CLUSTERED INDEX ([CustomerID] ASC), DISTRIBUTION = HASH([CustomerID]))
