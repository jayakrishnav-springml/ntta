CREATE TABLE [Temp].[TP_Trips_DUPS]
(
	[TpTripID] bigint NOT NULL,
	[CNT] int NULL
)
WITH(HEAP, DISTRIBUTION = HASH([TpTripID]))
