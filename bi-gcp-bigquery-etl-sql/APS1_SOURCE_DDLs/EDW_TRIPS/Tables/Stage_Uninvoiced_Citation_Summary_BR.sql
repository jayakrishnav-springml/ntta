CREATE TABLE [Stage].[Uninvoiced_Citation_Summary_BR]
(
	[CustomerID] bigint NOT NULL,
	[TPTripID] bigint NOT NULL,
	[CitationID] bigint NOT NULL,
	[TripStatusCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[PostedDate] datetime2(3) NULL,
	[TollAmount] decimal(19,2) NOT NULL,
	[BusinessRuleMatchedFlag] smallint NULL
)
WITH(CLUSTERED INDEX ([CitationID] ASC), DISTRIBUTION = HASH([CitationID]))
