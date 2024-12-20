CREATE TABLE [Finance].[ChequePayments]
(
	[PaymentID] bigint NOT NULL,
	[ChequeNumber] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ChequeTxnDate] datetime2(3) NOT NULL,
	[ReferenceURL] varchar(200) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[FilePathConfigurationID] smallint NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([PaymentID] DESC), DISTRIBUTION = HASH([PaymentID]))
