CREATE TABLE [Stage].[TP_Customer_Attributes]
(
	[CustomerID] bigint NOT NULL,
	[DriverLicenceNumber] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[DriverLicenceApprovedState] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[DriverLicenceExpirationDate] datetime2(3) NULL,
	[AutoReplenishmentID] int NULL,
	[PreferredShipment] int NULL,
	[TransponderPurchaseMethod] int NULL,
	[CalculatedRebillAmount] decimal(19,2) NULL,
	[ThresholdAmount] decimal(19,2) NULL,
	[IsManualHold] bit NOT NULL,
	[StatementDeliveryOptionID] int NULL,
	[SourceOfChannelID] int NULL,
	[Rebill_Hold_StartEffectiveDate] datetime2(3) NULL,
	[Rebill_Hold_EndEffectiveDate] datetime2(3) NULL,
	[Is_Notifications_Added] bit NOT NULL,
	[CapAmount] decimal(19,2) NULL,
	[KYCStatusID] int NULL,
	[KYCStatusDate] datetime2(3) NULL,
	[StatementCycleID] int NULL,
	[RebillStatus] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[RebillDate] datetime2(3) NULL,
	[PreferredLanguage] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsHearingImpairment] bit NOT NULL,
	[IsFrequentCaller] bit NOT NULL,
	[IsSupervisor] bit NOT NULL,
	[TagsinStatusFile] bit NOT NULL,
	[InvoiceInterValid] int NULL,
	[InvoiceAmount] decimal(19,2) NULL,
	[InvoiceDay] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LowBalanceAmount] decimal(19,2) NULL,
	[MbsGenerationDay] int NULL,
	[SSN] varchar(512) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Is_Commercial] bit NOT NULL,
	[IsEventSponsor] bit NOT NULL,
	[IsVIP] bit NOT NULL,
	[IsMilitary] bit NOT NULL,
	[AutoRecalcReplAmt] bit NOT NULL,
	[NonRevenueTypeID] int NULL,
	[IsTollperks] bit NOT NULL,
	[IsMarketingAndNewsLetter] bit NOT NULL,
	[IsDirectCarrierBilling] bit NOT NULL,
	[CompanyCode] varchar(12) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[IsGroundTransportation] bit NOT NULL,
	[MbsImageID] bigint NULL,
	[ViolatorTypeID] int NULL,
	[ICNID] bigint NULL,
	[ChannelID] int NULL,
	[CreatedDate] datetime2(3) NOT NULL,
	[CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([CustomerID] DESC), DISTRIBUTION = HASH([CustomerID]))
