CREATE TABLE [Stage].[InvoicePayment]
(
	[InvoiceNumber] bigint NULL,
	[InvoiceAmount] decimal(19,2) NULL,
	[PBMTollAmount] decimal(19,2) NULL,
	[AVITollAmount] decimal(19,2) NULL,
	[Tolls] decimal(19,2) NULL,
	[TollsPaid] decimal(19,2) NULL,
	[TollsAdjusted] decimal(19,2) NULL,
	[FirstPaymentDate] date NULL,
	[LastPaymentDate] date NULL,
	[EDW_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([InvoiceNumber]))
