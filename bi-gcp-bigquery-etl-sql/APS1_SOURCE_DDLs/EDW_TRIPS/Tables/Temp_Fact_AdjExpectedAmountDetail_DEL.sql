CREATE TABLE [Temp].[Fact_AdjExpectedAmountDetail_DEL]
(
	[TpTripID] bigint NOT NULL
)
WITH(CLUSTERED INDEX ([TpTripID] ASC), DISTRIBUTION = HASH([TpTripID]))
