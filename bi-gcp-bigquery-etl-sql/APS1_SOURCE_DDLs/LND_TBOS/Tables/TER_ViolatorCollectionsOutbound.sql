CREATE TABLE [TER].[ViolatorCollectionsOutbound]
(
	[VioCollOutboundID] bigint NOT NULL,
	[FileID] bigint NULL,
	[RecordType] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ViolatorID] bigint NULL,
	[InvoiceNumber] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[MbsID] bigint NULL,
	[FirstName] varchar(60) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LastName] varchar(60) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Address1] varchar(150) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Address2] varchar(150) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[City] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[State] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[ZipCode] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[MobilePhoneNumber] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[WorkPhoneNumber] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[InvoiceAmount] decimal(19,2) NULL,
	[TollAmount] decimal(19,2) NULL,
	[FeeAmount] decimal(19,2) NULL,
	[PaymentOrCreditAdjustment] decimal(19,2) NULL,
	[ReversalOrCharge] decimal(19,2) NULL,
	[TotalAmountDue] decimal(19,2) NULL,
	[NSFIndicator] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[NSFDate] datetime2(3) NULL,
	[ZCInvoiceDate] datetime2(3) NULL,
	[FirstNNPDate] datetime2(3) NULL,
	[SecondNNPDate] datetime2(3) NULL,
	[ThirdNNPDate] datetime2(3) NULL,
	[VehicleNumber] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleState] varchar(2) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleMake] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleModel] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleColor] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[VehicleYear] smallint NULL,
	[HasTSATransactions] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RentalCarIndicator] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RecallDate] datetime2(3) NULL,
	[LastActivityOnInvoice] datetime2(3) NULL,
	[CreatedDate] datetime2(3) NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([VioCollOutboundID] ASC), DISTRIBUTION = HASH([VioCollOutboundID]))
