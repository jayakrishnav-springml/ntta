CREATE TABLE [TollPlus].[ICN_Variance]
(
	[VarianceID] bigint NOT NULL,
	[ICNID] bigint NOT NULL,
	[VarCashAmt] decimal(19,2) NULL,
	[VarCheckAmt] decimal(19,2) NULL,
	[VarMOAmt] decimal(19,2) NULL,
	[VarCreditAmt] decimal(19,2) NULL,
	[VarFloatAmt] decimal(19,2) NULL,
	[VarItemReturnedCnt] int NULL,
	[VarItemAssignCnt] int NULL,
	[VarAmtTotal] decimal(19,2) NULL,
	[VarItemTotal] int NULL,
	[VarCashierCheck] decimal(19,2) NULL,
	[SystemBalance] decimal(19,2) NULL,
	[CSREnteredAmount] decimal(19,2) NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([VarianceID] DESC), DISTRIBUTION = HASH([VarianceID]))
