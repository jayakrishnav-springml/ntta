CREATE TABLE [dbo].[Fact_LanePerformanceDailySummary]
(
	[DayID] int NOT NULL,
	[LaneID] int NULL,
	[TripIdentMethodID] smallint NULL,
	[ReasonCodeID] bigint NOT NULL,
	[ImageReviewedFlag] int NULL,
	[TxnCount] int NULL
)
WITH(CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([DayID]))
