CREATE TABLE [Temp].[Overpayments_DUPS]
(
	[OverPaymentID] bigint NOT NULL,
	[CNT] int NULL
)
WITH(HEAP, DISTRIBUTION = HASH([OverPaymentID]))
