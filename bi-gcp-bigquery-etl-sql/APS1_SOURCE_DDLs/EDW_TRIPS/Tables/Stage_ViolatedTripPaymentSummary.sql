CREATE TABLE [Stage].[ViolatedTripPaymentSummary]
(
	[TpTripID] bigint NOT NULL,
	[CitationID] bigint NULL,
	[TripWith] varchar(2) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[FirstPaidDate] datetime2(3) NULL,
	[LastPaidDate] datetime2(3) NULL,
	[PaidAmount] decimal(19,2) NULL,
	[AdjAmount] decimal(19,2) NULL,
	[PaymentTxnCount] int NULL,
	[AdjTxnCount] int NULL
)
WITH(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([TpTripID]))
