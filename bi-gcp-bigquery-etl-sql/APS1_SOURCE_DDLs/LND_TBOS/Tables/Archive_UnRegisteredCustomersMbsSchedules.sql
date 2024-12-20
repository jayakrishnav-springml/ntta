CREATE TABLE [Archive].[UnRegisteredCustomersMbsSchedules]
(
	[ArchId] bigint NOT NULL,
	[UnRegMbsScheduleID] bigint NOT NULL,
	[ArchiveBatchID] bigint NOT NULL,
	[ArchiveDate] datetime2(3) NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([UnRegMbsScheduleID] DESC), DISTRIBUTION = HASH([UnRegMbsScheduleID]))
