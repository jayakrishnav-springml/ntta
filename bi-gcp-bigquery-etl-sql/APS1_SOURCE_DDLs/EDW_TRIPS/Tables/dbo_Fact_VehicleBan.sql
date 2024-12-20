CREATE TABLE [dbo].[Fact_VehicleBan]
(
	[VehicleBanID] bigint NOT NULL,
	[HVID] bigint NOT NULL,
	[CustomerID] bigint NOT NULL,
	[VehicleID] bigint NOT NULL,
	[VehicleBanStatusID] int NOT NULL,
	[VehicleBanRemovalStatusID] int NOT NULL,
	[ActiveFlag] bit NOT NULL,
	[VBRequestedDayID] int NULL,
	[VBAppliedDayID] int NULL,
	[RemovedDate] datetime2(3) NULL,
	[EarliestVehicleBanLetterMailedDate] date NULL,
	[EarliestVehicleBanLetterDeliveredDate] date NULL,
	[LatestVehicleBanLetterMailedDate] date NULL,
	[LatestVehicleBanLetterDeliveredDate] date NULL,
	[EDW_UpdateDate] datetime2(3) NOT NULL
)
WITH(CLUSTERED INDEX ([HVID] ASC), DISTRIBUTION = REPLICATE)
