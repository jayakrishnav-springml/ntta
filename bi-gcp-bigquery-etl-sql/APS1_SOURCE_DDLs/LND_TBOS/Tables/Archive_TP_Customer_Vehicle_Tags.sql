CREATE TABLE [Archive].[TP_Customer_Vehicle_Tags]
(
	[ArchId] bigint NOT NULL,
	[VehicleTagID] bigint NOT NULL,
	[ArchiveBatchID] bigint NOT NULL,
	[ArchiveDate] datetime2(3) NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([VehicleTagID] DESC), DISTRIBUTION = HASH([VehicleTagID]))
