CREATE TABLE [Utility].[Item90_TestResult]
(
	[TestDate] datetime2(0) NOT NULL,
	[TestRunID] int NOT NULL,
	[TestCaseID] decimal(10,3) NOT NULL,
	[TestCaseDesc] varchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TestResultDesc] varchar(255) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TestStatus] varchar(13) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[InvoiceCount] bigint NULL,
	[SampleInvoiceNumber] bigint NULL,
	[DataCategory] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[EDW_UpdateDate] datetime2(3) NOT NULL
)
WITH(CLUSTERED INDEX ([TestDate] ASC), DISTRIBUTION = HASH([TestDate]))
