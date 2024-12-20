CREATE TABLE [Finance].[Overpayments]
(
	[OverPaymentID] bigint NOT NULL,
	[CustomerID] bigint NULL,
	[LinkID] bigint NULL,
	[LinkSourceName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[OverPaymentAmount] decimal(19,2) NULL,
	[Amountused] decimal(19,2) NULL,
	[RemainIngAmount] decimal(19,2) NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NULL,
	[TripAdjustmentID] bigint NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([OverPaymentID] ASC), DISTRIBUTION = HASH([OverPaymentID]))
