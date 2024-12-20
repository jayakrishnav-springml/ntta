CREATE TABLE [Stage].[CustomerPaymentDetail]
(
	[PaymentLineItemID] bigint NOT NULL,
	[PaymentID] bigint NOT NULL,
	[CustomerID] bigint NULL,
	[PlanID] int NOT NULL,
	[CustomerPlanDesc] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CustomerPaymentType] varchar(7) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[AppTxnTypeID] int NULL,
	[AppTxnTypeCode] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AppTxnTypeDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CustomerPaymentLevelID] int NOT NULL,
	[LineItemAmount] decimal(21,2) NULL,
	[PaymentDate] datetime2(3) NULL,
	[ChannelID] int NULL,
	[PaymentChannelName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PaymentModeID] bigint NOT NULL,
	[PaymentModeCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PaymentStatusID] bigint NOT NULL,
	[PaymentStatusCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RefPaymentID] bigint NULL,
	[RefPaymentStatusID] bigint NULL,
	[DeleteFlag] bit NULL,
	[EDW_Update_Date] datetime2(7) NOT NULL
)
WITH(CLUSTERED INDEX ([PaymentLineItemID] ASC), DISTRIBUTION = HASH([PaymentLineItemID]))
