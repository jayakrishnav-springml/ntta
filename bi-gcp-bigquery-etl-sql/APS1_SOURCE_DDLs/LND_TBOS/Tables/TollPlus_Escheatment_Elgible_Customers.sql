CREATE TABLE [TollPlus].[Escheatment_Elgible_Customers]
(
	[EscheatmentID] bigint NOT NULL,
	[CustomerID] bigint NULL,
	[AccountStatusID] int NULL,
	[EsStatusID] int NULL,
	[EsStatusDate] datetime2(3) NULL,
	[Amount] decimal(19,2) NULL,
	[LinkID] bigint NULL,
	[LinkSourceName] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[SourceOfEntry] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[AdjustmentID] bigint NULL,
	[FirstName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[MiddleName] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LastName] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ReceivedCheckID] bigint NULL,
	[FromDate] datetime2(3) NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[CreatedDate] datetime2(3) NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([EscheatmentID] ASC), DISTRIBUTION = HASH([EscheatmentID]))
