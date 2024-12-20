CREATE TABLE [dbo].[Fact_GL_IOP_UnidentifiedAgingTxnSnapshot]
(
	[SnapshotDate] date NULL,
	[SnapshotMonthID] int NOT NULL,
	[Gl_TxnID] bigint NOT NULL,
	[TPTripID] bigint NOT NULL,
	[LaneID] int NOT NULL,
	[CustomerID] bigint NOT NULL,
	[BusinessUnitId] int NULL,
	[PostingDate] date NULL,
	[TxnDate] date NULL,
	[TxnAmount] decimal(19,2) NOT NULL,
	[DaycountID] int NULL
)
WITH(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([Gl_TxnID]), 
	PARTITION ([SnapshotMonthID] RANGE RIGHT FOR VALUES (202201, 202202, 202203, 202204, 202205, 202206, 202207, 202208, 202209, 202210, 202211, 202212, 202301, 202302, 202303, 202304, 202305, 202306, 202307, 202308, 202309, 202310, 202311, 202312, 202401, 202402, 202403, 202404)))
