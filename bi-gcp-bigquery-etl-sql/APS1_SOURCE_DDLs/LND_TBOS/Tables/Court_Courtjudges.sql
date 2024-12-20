CREATE TABLE [Court].[Courtjudges]
(
	[JudgeID] int NOT NULL,
	[CourtID] smallint NOT NULL,
	[LastName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[FirstName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[StartEffectiveDate] datetime2(3) NOT NULL,
	[EndEffectiveDate] datetime2(3) NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([JudgeID] ASC), DISTRIBUTION = HASH([JudgeID]))
