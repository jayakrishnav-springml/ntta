CREATE TABLE [dbo].[Dim_CourtJudge]
(
	[JudgeID] int NOT NULL,
	[CourtID] int NOT NULL,
	[LastName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[FirstName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[StartEffectiveDate] datetime2(7) NOT NULL,
	[EndEffectiveDate] datetime2(7) NULL,
	[CreatedDate] datetime2(7) NOT NULL,
	[LND_UpdateDate] datetime2(7) NULL,
	[EDW_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([JudgeID] ASC), DISTRIBUTION = REPLICATE)
