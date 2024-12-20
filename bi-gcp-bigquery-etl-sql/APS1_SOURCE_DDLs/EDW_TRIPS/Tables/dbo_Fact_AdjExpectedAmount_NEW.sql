CREATE TABLE [dbo].[Fact_AdjExpectedAmount_NEW]
(
	[TPTripID] bigint NOT NULL,
	[TripDayID] int NULL,
	[ClassAdjustmentFlag] smallint NULL,
	[AdjustedExpectedAmount] decimal(19,2) NULL,
	[TripWithAdjustedAmount] decimal(19,2) NULL,
	[AllAdjustedAmount] decimal(19,2) NULL,
	[AllCustTripAdjustedAmount] decimal(19,2) NULL,
	[AllViolatedTripAdjustedAmount] decimal(19,2) NULL,
	[IOP_OutboundPaidAmount] decimal(19,2) NULL,
	[EDW_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([TPTripID] ASC), DISTRIBUTION = HASH([TPTripID]))
