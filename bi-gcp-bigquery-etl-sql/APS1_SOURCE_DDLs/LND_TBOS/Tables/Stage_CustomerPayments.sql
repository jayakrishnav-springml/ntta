CREATE TABLE [Stage].[CustomerPayments]
(
	[CustPaymentID] bigint NOT NULL,
	[PaymentID] bigint NULL,
	[CustomerID] bigint NULL,
	[Amount] decimal(19,2) NULL,
	[CreatedDate] datetime2(3) NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([CustPaymentID] ASC), DISTRIBUTION = HASH([CustPaymentID]))
