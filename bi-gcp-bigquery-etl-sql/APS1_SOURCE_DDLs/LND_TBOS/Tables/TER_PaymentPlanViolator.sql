CREATE TABLE [TER].[PaymentPlanViolator]
(
	[PaymentPlanViolatorID] bigint NOT NULL,
	[ViolatorID] bigint NOT NULL,
	[HVID] int NULL,
	[PaymentPlanID] bigint NOT NULL,
	[PaymentPlanViolatorSeq] int NULL,
	[HVFlag] bit NULL,
	[MbsID] bigint NOT NULL,
	[PPCustomerID] bigint NULL,
	[CreatedDate] datetime2(3) NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([PaymentPlanViolatorID] ASC), DISTRIBUTION = HASH([PaymentPlanViolatorID]))
