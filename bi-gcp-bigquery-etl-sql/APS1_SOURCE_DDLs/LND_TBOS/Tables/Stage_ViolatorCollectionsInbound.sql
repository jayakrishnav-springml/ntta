CREATE TABLE [Stage].[ViolatorCollectionsInbound]
(
	[VioCollInboundID] bigint NOT NULL,
	[FileID] bigint NULL,
	[ViolatorID] bigint NULL,
	[InvoiceNumber] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TransactionType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TransactionAmount] decimal(19,2) NULL,
	[BalAfterTransaction] decimal(19,2) NULL,
	[TransactionDate] datetime2(3) NULL,
	[Reason] varchar(300) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PaymentReferenceID] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Status] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[Error] varchar(8000) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PaymentID] bigint NULL,
	[CreatedDate] datetime2(3) NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([VioCollInboundID] ASC), DISTRIBUTION = HASH([VioCollInboundID]))
