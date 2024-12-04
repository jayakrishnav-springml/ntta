CREATE TABLE [dbo].[Fact_Violation_NEW]
(
	[CitationID] bigint NOT NULL,
	[TPTripID] bigint NOT NULL,
	[TripDayID] int NOT NULL,
	[LaneID] int NOT NULL,
	[CustomerID] bigint NOT NULL,
	[CustRefID] bigint NOT NULL,
	[VehicleID] bigint NOT NULL,
	[AccountAgencyID] bigint NOT NULL,
	[TripStatusID] int NOT NULL,
	[TripStageID] int NOT NULL,
	[TransactionTypeID] smallint NOT NULL,
	[TransactionPostingTypeID] int NOT NULL,
	[CitationStageID] int NOT NULL,
	[PaymentStatusID] bigint NOT NULL,
	[VehicleClassID] smallint NOT NULL,
	[SourceOfEntry] tinyint NOT NULL,
	[TripDate] datetime2(3) NOT NULL,
	[TripStatusDate] datetime2(3) NOT NULL,
	[PostedDate] datetime2(3) NOT NULL,
	[WriteOffDate] datetime2(3) NOT NULL,
	[WriteOffFlag] bit NOT NULL,
	[CurrentTxnFlag] bit NOT NULL,
	[DeleteFlag] bit NOT NULL,
	[TollAmount] decimal(9,2) NOT NULL,
	[FeeAmount] decimal(9,2) NOT NULL,
	[OutStandingAmount] decimal(9,2) NOT NULL,
	[NetAmount] decimal(9,2) NOT NULL,
	[PBMTollAmount] decimal(9,2) NOT NULL,
	[AVITollAmount] decimal(9,2) NOT NULL,
	[WriteOffAmount] decimal(9,2) NOT NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[LND_UpdateDate] datetime2(3) NOT NULL,
	[EDW_UpdateDate] datetime2(3) NOT NULL,
	[TransactionDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([CitationID] ASC), DISTRIBUTION = HASH([TPTripID]))
