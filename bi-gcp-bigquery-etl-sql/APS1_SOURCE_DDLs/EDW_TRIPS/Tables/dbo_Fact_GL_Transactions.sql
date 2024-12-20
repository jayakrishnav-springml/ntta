CREATE TABLE [dbo].[Fact_GL_Transactions]
(
	[Gl_TxnID] bigint NOT NULL,
	[PostingDate] datetime2(3) NOT NULL,
	[PostingDate_yyyymm] int NOT NULL,
	[CustomerID] bigint NOT NULL,
	[TxnTypeID] int NOT NULL,
	[BusinessProcessID] int NOT NULL,
	[LinkID] bigint NOT NULL,
	[LinkSourceName] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TxnDate] datetime2(3) NOT NULL,
	[TxnAmount] decimal(19,2) NOT NULL,
	[IsContra] bit NULL,
	[Description] varchar(500) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RequestID] int NULL,
	[BusinessUnitId] int NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[DeleteFlag] bit NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[EDW_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([Gl_TxnID] DESC), DISTRIBUTION = HASH([Gl_TxnID]))
