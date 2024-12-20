CREATE TABLE [dbo].[Dim_ChartOfAccounts]
(
	[Surrogate_COAID] int NOT NULL,
	[ChartOfAccountID] int NOT NULL,
	[AccountName] varchar(250) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ParentChartOfAccountID] int NULL,
	[AgCode] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[AsgCode] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LowerBound] bigint NULL,
	[UpperBound] bigint NULL,
	[Status] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsControlAccount] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[NormalBalanceType] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LegalAccountID] int NULL,
	[AgencyCode] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[StartEffectiveDate] datetime2(3) NULL,
	[EndEffectiveDate] datetime2(3) NULL,
	[Comments] varchar(200) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsDeleted] bit NOT NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EDW_UpdateDate] datetime2(7) NOT NULL
)
WITH(CLUSTERED INDEX ([ChartOfAccountID] ASC), DISTRIBUTION = REPLICATE)
