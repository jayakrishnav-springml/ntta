CREATE TABLE [Finance].[BankPayments]
(
	[PaymentID] bigint NOT NULL,
	[BankName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AccountName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AccountNumber] varchar(64) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CcTokenID] varchar(60) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PnRefID] varchar(60) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CustRefID] varchar(64) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ResultCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PaymentStatusID] bigint NULL,
	[RefPaymentID] bigint NULL,
	[ReplaceErrorCode] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ResponseMessage] varchar(150) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AccountType] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RoutingNumber] varchar(150) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[BankSuffix4] bigint NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([PaymentID] DESC), DISTRIBUTION = HASH([PaymentID]))
