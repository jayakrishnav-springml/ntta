CREATE TABLE [Stage].[HVStatusLookup]
(
	[HVStatusLookupID] int NOT NULL,
	[StatusCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[StatusDescription] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ParentStatusID] int NULL,
	[IsActive] bit NOT NULL,
	[DetailedDesc] varchar(1000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NULL,
	[CreatedUser] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NULL,
	[UpdatedUser] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([HVStatusLookupID] ASC), DISTRIBUTION = HASH([HVStatusLookupID]))
