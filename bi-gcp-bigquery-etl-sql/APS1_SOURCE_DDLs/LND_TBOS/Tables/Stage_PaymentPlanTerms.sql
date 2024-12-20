CREATE TABLE [Stage].[PaymentPlanTerms]
(
	[PaymentPlantermID] bigint NOT NULL,
	[PaymentPlanID] bigint NULL,
	[TermNumber] int NULL,
	[TermDueDate] date NULL,
	[CustomTermDueDate] date NULL,
	[TermAmount] decimal(19,2) NULL,
	[TermOutstandingAmount] decimal(19,2) NULL,
	[IsActive] bit NULL,
	[CreatedDate] datetime2(3) NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([PaymentPlantermID] ASC), DISTRIBUTION = HASH([PaymentPlantermID]))
