CREATE TABLE [Stage].[RefundRequests_Queue]
(
	[RefundRequestID] bigint NOT NULL,
	[ExceptionRRID] bigint NULL,
	[CustomerID] bigint NULL,
	[RefundRequestState] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RefundRequestType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[SubSystem] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TxnTypeID] int NULL,
	[PayTypeID] int NULL,
	[OrigInalPayTypeID] int NULL,
	[Amount] decimal(19,2) NULL,
	[PaymentTxnID] bigint NULL,
	[RequestedDate] datetime2(3) NULL,
	[ProcessedDate] datetime2(3) NULL,
	[Reason] varchar(256) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ApprovedDate] datetime2(3) NULL,
	[ApprovedBy] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RetryCnt] int NOT NULL,
	[ICNID] bigint NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([RefundRequestID] DESC), DISTRIBUTION = HASH([RefundRequestID]))
