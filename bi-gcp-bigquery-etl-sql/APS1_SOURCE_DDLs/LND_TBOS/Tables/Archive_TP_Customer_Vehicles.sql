CREATE TABLE [Archive].[TP_Customer_Vehicles]
(
	[ArchId] bigint NOT NULL,
	[VehicleID] bigint NOT NULL,
	[ArchiveBatchId] bigint NOT NULL,
	[ArchiveDate] datetime2(3) NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([VehicleID] DESC), DISTRIBUTION = HASH([VehicleID]))
