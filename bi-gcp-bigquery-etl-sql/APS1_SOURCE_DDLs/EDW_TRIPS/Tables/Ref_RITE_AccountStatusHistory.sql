CREATE TABLE [Ref].[RITE_AccountStatusHistory]
(
	[DataSource] varchar(4) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[TableSource] varchar(17) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[CustomerID] decimal(12,0) NULL,
	[Acct_Status_Code] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AccountStatusID] int NULL,
	[AccountStatusDate] datetime2(3) NULL,
	[CreatedDate] datetime2(3) NULL,
	[CreatedUser] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NULL,
	[UpdatedUser] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RITE_Acct_Hist_Seq] int NOT NULL,
	[RITE_HistLast_RN] bigint NULL
)
WITH(CLUSTERED INDEX ([CustomerID] ASC), DISTRIBUTION = HASH([CustomerID]))
