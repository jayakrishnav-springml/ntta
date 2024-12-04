CREATE TABLE [dbo].[Dim_PaymentPlan]
(
	[PaymentPlanID] bigint NOT NULL,
	[CustomerID] bigint NOT NULL,
	[HVID] int NULL,
	[MbsID] bigint NOT NULL,
	[CustTagID] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[HVStage] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[StatusLookupCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[StatusDescription] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[StatusDateTime] datetime2(3) NULL,
	[AgreementActiveDate] datetime2(3) NULL,
	[LastInstallmentDueDate] datetime2(3) NULL,
	[LastPaidDate] date NULL,
	[NextDueDate] date NULL,
	[DefaultedDate] datetime2(3) NULL,
	[PaidInFullDate] datetime2(3) NULL,
	[QuoteExpiryDate] datetime2(3) NULL,
	[QuoteFinalizedDate] datetime2(3) NULL,
	[QuoteSignedDate] datetime2(3) NULL,
	[DownPaymentDate] datetime2(3) NULL,
	[PreviousDefaultsCount] tinyint NULL,
	[TotalNoOfMonths] int NULL,
	[MBSDue] decimal(19,2) NULL,
	[CalculatedDownPayment] decimal(19,2) NULL,
	[CustomDownPayment] decimal(19,2) NULL,
	[MonthlyPayment] decimal(19,2) NULL,
	[PaidAmount] decimal(19,2) NULL,
	[RemainingAmount] decimal(19,2) NULL,
	[LastPaidAmount] decimal(19,2) NULL,
	[SettlementAmount] decimal(19,2) NULL,
	[TollAmount] decimal(19,2) NULL,
	[FeeAmount] decimal(19,2) NULL,
	[EDW_UpdateDate] datetime2(3) NOT NULL
)
WITH(CLUSTERED INDEX ([HVID] ASC), DISTRIBUTION = REPLICATE)
