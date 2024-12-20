CREATE TABLE [dbo].[Fact_TollTransaction_Adj]
(
	[CustTripID] bigint NOT NULL,
	[AdjLineItemID] bigint NOT NULL,
	[AdjustmentID] bigint NOT NULL,
	[TPTripID] bigint NOT NULL,
	[CustomerID] bigint NOT NULL,
	[LaneID] int NOT NULL,
	[TripIdentMethodID] int NOT NULL,
	[TripDayID] int NOT NULL,
	[AdjustedDayID] int NOT NULL,
	[TripDate] datetime2(3) NOT NULL,
	[PostedDate] datetime2(3) NOT NULL,
	[AdjustedDate] datetime2(3) NOT NULL,
	[DrCrFlag] varchar(2) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[DeleteFlag] bit NOT NULL,
	[AdjustedTollAmount] decimal(9,2) NOT NULL,
	[LND_UpdateDate] datetime2(3) NOT NULL,
	[EDW_UpdateDate] datetime2(3) NOT NULL
)
WITH(CLUSTERED INDEX ([CustTripID] ASC), DISTRIBUTION = HASH([CustTripID]))
