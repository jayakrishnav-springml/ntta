CREATE TABLE [Stage].[TP_Customer_Trip_Charges_Tracker]
(
	[TripChargeID] bigint NOT NULL,
	[CustTripID] bigint NOT NULL,
	[Amount] decimal(19,2) NOT NULL,
	[AmountClass] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PaymentStatusID] int NULL,
	[OutstandingAmount] decimal(19,2) NULL,
	[CustomerID] bigint NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([TripChargeID] DESC), DISTRIBUTION = HASH([TripChargeID]))
