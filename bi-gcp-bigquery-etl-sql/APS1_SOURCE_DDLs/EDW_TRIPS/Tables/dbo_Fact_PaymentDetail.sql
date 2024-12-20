CREATE TABLE [dbo].[Fact_PaymentDetail]
(
	[InvoiceNumber] bigint NOT NULL,
	[InvoiceID] bigint NULL,
	[TpTripID] bigint NULL,
	[CitationID] bigint NULL,
	[PaymentID] bigint NOT NULL,
	[OverPaymentID] bigint NULL,
	[PaymentDayID] int NULL,
	[PaymentModeID] bigint NOT NULL,
	[PaymentStatusID] bigint NOT NULL,
	[RefPaymentStatusID] bigint NULL,
	[AppTxnTypeID] int NOT NULL,
	[LaneID] int NULL,
	[CustomerID] bigint NULL,
	[CustomerStatusID] bigint NULL,
	[AccountTypeID] bigint NULL,
	[AccountStatusID] bigint NOT NULL,
	[PlanID] int NOT NULL,
	[RefPaymentID] bigint NULL,
	[VoucherNo] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ChannelID] int NULL,
	[POSID] bigint NOT NULL,
	[ICNID] bigint NULL,
	[IsvirtualCheck] bit NULL,
	[PmtTxnType] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[SubSystemID] int NOT NULL,
	[TxnPaymentDate] datetime2(3) NULL,
	[ApprovedBy] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Reasontext] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TxnAmount] decimal(19,2) NOT NULL,
	[LineItemAmount] decimal(38,6) NULL,
	[AmountReceived] decimal(38,2) NULL,
	[FNFeesPaid] decimal(38,11) NULL,
	[SNFeesPaid] decimal(38,11) NULL,
	[DeleteFlag] bit NOT NULL,
	[EDW_Update_Date] datetime2(3) NOT NULL
)
WITH(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([TpTripID]), 
	PARTITION ([PaymentDayID] RANGE RIGHT FOR VALUES (20110101, 20120101, 20130101, 20140101, 20150101, 20150201, 20150301, 20150401, 20150501, 20150601, 20150701, 20150801, 20150901, 20151001, 20151101, 20151201, 20160101, 20160201, 20160301, 20160401, 20160501, 20160601, 20160701, 20160801, 20160901, 20161001, 20161101, 20161201, 20170101, 20170201, 20170301, 20170401, 20170501, 20170601, 20170701, 20170801, 20170901, 20171001, 20171101, 20171201, 20180101, 20180201, 20180301, 20180401, 20180501, 20180601, 20180701, 20180801, 20180901, 20181001, 20181101, 20181201, 20190101, 20190201, 20190301, 20190401, 20190501, 20190601, 20190701, 20190801, 20190901, 20191001, 20191101, 20191201, 20200101, 20200201, 20200301, 20200401, 20200501, 20200601, 20200701, 20200801, 20200901, 20201001, 20201101)))
