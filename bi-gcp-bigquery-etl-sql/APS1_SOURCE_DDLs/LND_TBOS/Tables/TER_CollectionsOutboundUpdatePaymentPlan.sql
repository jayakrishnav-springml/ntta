CREATE TABLE [TER].[CollectionsOutboundUpdatePaymentPlan]
(
	[VioCollOutboundPayPlanID] bigint NOT NULL,
	[FileID] bigint NOT NULL,
	[ViolatorID] bigint NOT NULL,
	[InvoiceNumber] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[PlanID] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[PlanDate] datetime2(3) NOT NULL,
	[PlanStatus] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([VioCollOutboundPayPlanID] ASC), DISTRIBUTION = HASH([VioCollOutboundPayPlanID]))
