CREATE TABLE [dbo].[Fact_HV_FailuretopayCitation]
(
	[FailureCitationID] bigint NULL,
	[HVID] bigint NOT NULL,
	[CustomerID] bigint NOT NULL,
	[CitationID] bigint NOT NULL,
	[TPTripID] bigint NULL,
	[CitationInvoiceID] bigint NOT NULL,
	[MBSID] bigint NOT NULL,
	[LaneID] int NULL,
	[CourtID] int NULL,
	[JudgeID] int NULL,
	[DPSTrooperID] bigint NOT NULL,
	[CitationStatusID] int NOT NULL,
	[InvoiceAgeStageID] int NOT NULL,
	[CitationInvoiceNumber] bigint NOT NULL,
	[CitationNumber] varchar(250) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[DPSCitationNumber] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TripDayID] int NULL,
	[MailDayID] int NULL,
	[DPSCitationIssuedDayID] int NULL,
	[CitationPackageCreatedDayID] int NULL,
	[CourtAppearanceDate] datetime2(3) NULL,
	[PrintDate] datetime2(3) NULL,
	[FirstPaidDate] datetime2(3) NULL,
	[LastPaidDate] datetime2(3) NULL,
	[ActiveFlag] bit NULL,
	[MigratedFlag] int NOT NULL,
	[TxnTollAmount] decimal(21,4) NULL,
	[TxnTollsPaid] decimal(21,4) NULL,
	[TollsOnInvoice] decimal(21,4) NULL,
	[TollsPaidOnInvoice] decimal(21,4) NULL,
	[FeesDueOnInvoice] decimal(22,4) NULL,
	[FeesPaidOnInvoice] decimal(22,4) NULL,
	[TollsAdjustedOnInvoice] decimal(19,2) NULL,
	[EDW_UpdateDate] datetime2(3) NOT NULL
)
WITH(CLUSTERED INDEX ([FailureCitationID] ASC), DISTRIBUTION = REPLICATE)
