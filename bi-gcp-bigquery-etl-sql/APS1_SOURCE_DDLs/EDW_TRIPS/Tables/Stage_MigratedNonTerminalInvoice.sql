CREATE TABLE [Stage].[MigratedNonTerminalInvoice]
(
	[InvoiceNumber] bigint NULL,
	[FirstInvoiceID] bigint NOT NULL,
	[CurrentInvoiceID] bigint NOT NULL,
	[CustomerID] bigint NULL,
	[MigratedFlag] int NOT NULL,
	[VTollFlag] int NOT NULL,
	[UnassignedFlag] int NOT NULL,
	[AgeStageID] int NULL,
	[CollectionStatusID] bigint NOT NULL,
	[CurrMbsID] bigint NOT NULL,
	[VehicleID] bigint NULL,
	[ZipCashDate] date NULL,
	[FirstNoticeDate] date NULL,
	[SecondNoticeDate] date NULL,
	[ThirdNoticeDate] datetime2(7) NULL,
	[LegalActionPendingDate] datetime2(7) NULL,
	[CitationDate] datetime2(0) NULL,
	[DueDate] date NULL,
	[CurrMbsGeneratedDate] date NOT NULL,
	[FirstPaymentDate] date NULL,
	[LastPaymentDate] date NULL,
	[FirstFeePaymentDate] datetime2(3) NULL,
	[LastFeePaymentDate] datetime2(3) NULL,
	[InvoiceStatusID] int NULL,
	[TxnCnt] int NULL,
	[InvoiceAmount] decimal(19,2) NULL,
	[PBMTollAmount] decimal(19,2) NULL,
	[AVITollAmount] decimal(19,2) NULL,
	[PremiumAmount] decimal(19,2) NULL,
	[ExcusedAmount] decimal(19,2) NULL,
	[Tolls] decimal(19,2) NULL,
	[FNFees] decimal(19,2) NULL,
	[SNFees] decimal(19,2) NULL,
	[ExpectedAmount] decimal(19,2) NULL,
	[TollsAdjusted] decimal(19,2) NULL,
	[FNFeesAdjusted] decimal(19,2) NULL,
	[SNFeesAdjusted] decimal(19,2) NULL,
	[AdjustedAmount] decimal(19,2) NULL,
	[AdjustedExpectedTolls] decimal(19,2) NULL,
	[AdjustedExpectedFNFees] decimal(19,2) NULL,
	[AdjustedExpectedSNFees] decimal(19,2) NULL,
	[AdjustedExpectedAmount] decimal(19,2) NULL,
	[TollsPaid] decimal(19,2) NULL,
	[FNFeesPaid] decimal(19,2) NULL,
	[SNFeesPaid] decimal(19,2) NULL,
	[PaidAmount] decimal(19,2) NULL,
	[TollOutStandingAmount] decimal(19,2) NULL,
	[FNFeesOutStandingAmount] decimal(19,2) NULL,
	[SNFeesOutStandingAmount] decimal(19,2) NULL,
	[OutstandingAmount] decimal(19,2) NULL,
	[EDW_Update_Date] datetime2(7) NOT NULL,
	[EDW_InvoiceStatusID] int NOT NULL
)
WITH(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([InvoiceNumber]))
