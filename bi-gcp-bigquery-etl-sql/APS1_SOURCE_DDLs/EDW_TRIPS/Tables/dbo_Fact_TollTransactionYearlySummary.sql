CREATE TABLE [dbo].[Fact_TollTransactionYearlySummary]
(
	[YearID] int NULL,
	[CustomerID] bigint NOT NULL,
	[VehicleTagID] bigint NOT NULL,
	[CustTagID] bigint NOT NULL,
	[TxnCount] int NULL,
	[TollsDue] decimal(38,2) NULL
)
WITH(CLUSTERED INDEX ([CustomerID] ASC), DISTRIBUTION = HASH([CustomerID]))
