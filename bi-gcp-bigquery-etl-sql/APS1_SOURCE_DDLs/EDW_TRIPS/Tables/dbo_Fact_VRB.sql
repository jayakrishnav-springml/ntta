CREATE TABLE [dbo].[Fact_VRB]
(
	[VRBID] bigint NOT NULL,
	[HVID] bigint NOT NULL,
	[CustomerID] bigint NOT NULL,
	[VehicleID] bigint NOT NULL,
	[VRBStatusID] int NOT NULL,
	[VRBAgencyID] int NOT NULL,
	[VRBRejectReasonID] int NOT NULL,
	[VRBRemovalReasonID] int NOT NULL,
	[VRBLetterDeliverStatusID] int NOT NULL,
	[VRBRequestedDayID] int NULL,
	[VRBAppliedDayID] int NULL,
	[VRBRemovedDayID] int NULL,
	[VRBActiveFlag] bit NOT NULL,
	[DallasScOffLawFlag] bit NULL,
	[VRBCreatedDate] datetime2(3) NULL,
	[VRBRejectionDate] datetime2(3) NULL,
	[VRBLetterMailedDate] datetime2(3) NULL,
	[VRBLetterDeliveredDate] datetime2(3) NULL,
	[EDW_UpdateDate] datetime2(3) NOT NULL
)
WITH(CLUSTERED INDEX ([HVID] ASC), DISTRIBUTION = REPLICATE)
