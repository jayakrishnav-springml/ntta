CREATE TABLE [dbo].[Dim_AppTxnType]
(
	[AppTxnTypeID] int NOT NULL,
	[AppTxnTypeCode] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[AppTxnTypeDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Effected_BalanceType_Positive] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Effected_BalanceType_Negative] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Main_Balance_Type] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TxnTypeCategoryID] int NOT NULL,
	[TxnTypeCategory] varchar(51) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TxnTypeParentCategoryID] int NOT NULL,
	[TxnTypeParentCategory] varchar(51) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EDW_UpdateDate] datetime2(7) NOT NULL
)
WITH(CLUSTERED INDEX ([AppTxnTypeID] ASC), DISTRIBUTION = REPLICATE)
