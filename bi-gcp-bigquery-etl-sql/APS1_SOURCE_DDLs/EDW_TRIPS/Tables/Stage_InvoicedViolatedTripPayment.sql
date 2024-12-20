CREATE TABLE [Stage].[InvoicedViolatedTripPayment]
(
	[TpTripID] bigint NOT NULL,
	[CitationID] bigint NOT NULL,
	[TripDate] datetime2(3) NULL,
	[TotalTxnAmount] decimal(19,2) NULL,
	[TollAmount] decimal(19,2) NOT NULL,
	[AdjustedAmount] decimal(19,2) NULL,
	[ActualPaidAmount] decimal(19,2) NULL,
	[OutstandingAmount] decimal(19,2) NOT NULL,
	[PaymentStatusID] bigint NULL,
	[FirstPaidDate] datetime2(3) NULL,
	[LastPaidDate] datetime2(3) NULL
)
WITH(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([TpTripID]))
