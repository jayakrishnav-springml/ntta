CREATE TABLE [Stage].[ViolatorCollectionsOutboundUpdate]
(
	[VioCollOutboundUpdateID] bigint NOT NULL,
	[FileID] bigint NULL,
	[RecordType] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ViolatorID] bigint NULL,
	[InvoiceNumber] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TransactionID] bigint NULL,
	[TransactionType] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TransactionAmount] decimal(19,2) NULL,
	[BalAfterTransaction] decimal(19,2) NULL,
	[TransactionDate] datetime2(3) NULL,
	[AdjustmentReason] varchar(300) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([VioCollOutboundUpdateID] ASC), DISTRIBUTION = HASH([VioCollOutboundUpdateID]))
