CREATE TABLE [Stage].[DMVExceptionQueue]
(
	[ExceptionQueueID] int NOT NULL,
	[Status] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[ExceptionType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[ExceptionRaisedBy] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[ExceptionRaisedDate] datetime2(3) NOT NULL,
	[ExceptionResolvedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ExceptionResolvedDate] datetime2(3) NULL,
	[Comments] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([ExceptionQueueID] ASC), DISTRIBUTION = HASH([ExceptionQueueID]))
