CREATE TABLE [Stage].[MigratedInvoice]
(
	[RN_MAX] bigint NULL,
	[InvoiceNumber] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[InvoiceID] bigint NOT NULL,
	[CustomerID] bigint NULL,
	[AgeStageID] int NULL,
	[CollectionStatus] bigint NULL,
	[VehicleID] bigint NULL,
	[InvoiceDate] datetime2(3) NULL,
	[DueDate] datetime2(3) NULL,
	[AdjustedAmount] decimal(19,2) NULL,
	[InvoiceStatus] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AgeStageID_RI] int NOT NULL,
	[ZipCashDate_RI] date NOT NULL,
	[FirstNoticeDate_RI] date NULL,
	[SecondNoticeDate_RI] date NULL,
	[ThirdNoticeDate_RI] datetime2(7) NULL,
	[CitationDate_RI] datetime2(0) NULL,
	[LegalActionPendingDate_RI] datetime2(7) NULL,
	[DueDate_RI] date NOT NULL,
	[CurrMBSGeneratedDate_RI] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[FirstpaymentDate_RI] date NULL,
	[LastPaymentDate_RI] date NULL
)
WITH(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([InvoiceNumber]))
