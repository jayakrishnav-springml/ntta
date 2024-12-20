CREATE TABLE [Stage].[InvoiceDetail_Tunned]
(
	[InvoiceID] bigint NULL,
	[InvoiceNumber] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LineItemID] bigint NULL,
	[AgencyID] bigint NULL,
	[Roadway] bigint NULL,
	[Type] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Category] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[InvoiceEscalationlevel] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[InvoiceStatus] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TxnType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TxnDate] datetime2(3) NULL,
	[PostedDate] datetime2(3) NULL,
	[InvoiceDate] datetime2(3) NULL,
	[PaidDate] datetime2(3) NULL,
	[PostedAmount] decimal(19,2) NULL,
	[PaidAmount] decimal(19,2) NULL,
	[OutstandingAmount] decimal(19,2) NULL,
	[CitationID] bigint NULL,
	[TpTripID] bigint NULL,
	[TripStatus] int NULL,
	[ReceivableIndication] int NULL,
	[CustomerID] bigint NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([InvoiceID] ASC), DISTRIBUTION = HASH([InvoiceID]))
