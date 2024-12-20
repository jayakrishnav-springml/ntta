CREATE TABLE [dbo].[Fact_CustomerPaymentDetail]
(
	[CustomerPaymentDetailID] bigint NOT NULL,
	[PaymentLineItemID] bigint NOT NULL,
	[PaymentID] bigint NOT NULL,
	[AdjLineItemID] bigint NOT NULL,
	[AdjustmentID] bigint NOT NULL,
	[CustomerID] bigint NOT NULL,
	[CustomerPaymentTypeID] smallint NULL,
	[AppTxnTypeID] int NOT NULL,
	[CustomerPaymentLevelID] int NOT NULL,
	[PaymentDayID] int NOT NULL,
	[ChannelID] int NOT NULL,
	[PaymentModeID] int NOT NULL,
	[PaymentStatusID] int NOT NULL,
	[RefPaymentID] bigint NULL,
	[RefPaymentStatusID] int NULL,
	[DRCRFlag] char(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LineItemAmount] decimal(19,2) NULL,
	[DeleteFlag] bit NOT NULL,
	[PaymentDate] datetime2(3) NULL,
	[EDW_Update_Date] datetime2(3) NOT NULL
)
WITH(CLUSTERED INDEX ([CustomerPaymentDetailID] ASC), DISTRIBUTION = HASH([CustomerPaymentDetailID]))
