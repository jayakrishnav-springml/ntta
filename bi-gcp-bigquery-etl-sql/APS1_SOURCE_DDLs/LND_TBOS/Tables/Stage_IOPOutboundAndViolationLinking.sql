CREATE TABLE [Stage].[IOPOutboundAndViolationLinking]
(
	[Lane_Viol_ID] bigint NULL,
	[Transaction_ID] bigint NOT NULL,
	[Hub_IOP_Txn_ID] bigint NULL,
	[Violation_ID] bigint NULL,
	[Transaction_Date] datetime2(3) NOT NULL,
	[ViolationTPTripID] bigint NOT NULL,
	[OutboundTPTripID] bigint NOT NULL,
	[LND_UpdateDate] datetime2(3) NULL,
	[LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH(CLUSTERED INDEX ([OutboundTPTripID] ASC), DISTRIBUTION = HASH([OutboundTPTripID]))
