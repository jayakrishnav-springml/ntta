CREATE TABLE [Utility].[Item90_TestResultDetail]
(
	[TestDate] datetime2(0) NOT NULL,
	[TestRunID] int NOT NULL,
	[TestCaseID] decimal(10,3) NOT NULL,
	[InvoiceNumber] bigint NOT NULL,
	[EDW_UpdateDate] datetime2(3) NOT NULL
)
WITH(CLUSTERED INDEX ([InvoiceNumber] ASC), DISTRIBUTION = HASH([InvoiceNumber]))
