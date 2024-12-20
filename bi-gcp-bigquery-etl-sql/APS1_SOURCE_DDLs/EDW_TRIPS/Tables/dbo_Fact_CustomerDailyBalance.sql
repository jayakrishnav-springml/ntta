CREATE TABLE [dbo].[Fact_CustomerDailyBalance]
(
	[CustomerID] int NOT NULL,
	[BalanceStartDate] date NULL,
	[BalanceEndDate] date NULL,
	[TollTxnCount] int NOT NULL,
	[TollAmount] decimal(19,2) NOT NULL,
	[CreditAmount] decimal(19,2) NOT NULL,
	[DebitAmount] decimal(19,2) NOT NULL,
	[CreditTxnCount] int NOT NULL,
	[DebitTxnCount] int NOT NULL,
	[BeginningBalanceAmount] decimal(19,2) NOT NULL,
	[EndingBalanceAmount] decimal(19,2) NOT NULL,
	[CalcEndingBalanceAmount] decimal(19,2) NOT NULL,
	[BalanceDiffAmount] decimal(19,2) NOT NULL,
	[BeginningCustTxnID] bigint NULL,
	[EndingCustTxnID] bigint NULL,
	[EDW_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([CustomerID]), 
	PARTITION ([BalanceStartDate] RANGE RIGHT FOR VALUES ('20201201', '20210101', '20210201', '20210301', '20210401', '20210501', '20210601', '20210701', '20210801', '20210901', '20211001', '20211101', '20211201', '20220101', '20220201', '20220301', '20220401', '20220501', '20220601', '20220701', '20220801', '20220901', '20221001', '20221101', '20221201', '20230101', '20230201', '20230301', '20230401', '20230501', '20230601', '20230701', '20230801', '20230901', '20231001', '20231101', '20231201', '20240101', '20240201', '20240301', '20240401')))
