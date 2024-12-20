CREATE TABLE [Stage].[CustomerAdjustmentDetail]
(
	[AdjLineItemID] bigint NOT NULL,
	[AdjustmentID] bigint NOT NULL,
	[CustomerID] bigint NOT NULL,
	[PlanID] int NOT NULL,
	[CustomerPlanDesc] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CustomerPaymentType] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[AppTxnTypeID] int NULL,
	[AppTxnTypeCode] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AppTxnTypeDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CustomerPaymentLevelID] int NOT NULL,
	[LineItemAmount] decimal(21,2) NULL,
	[ApprovedStatusDate] datetime2(3) NOT NULL,
	[PaymentModeID] int NULL,
	[PaymentModeCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AdjApprovalStatusID] int NOT NULL,
	[DRCRFlag] varchar(2) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[DeleteFlag] bit NULL
)
WITH(CLUSTERED INDEX ([AdjLineItemID] ASC), DISTRIBUTION = HASH([AdjLineItemID]))
