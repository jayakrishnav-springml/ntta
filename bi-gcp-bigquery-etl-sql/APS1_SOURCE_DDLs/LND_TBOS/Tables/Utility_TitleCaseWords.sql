CREATE TABLE [Utility].[TitleCaseWords]
(
	[TitleCaseWord] varchar(25) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[WordLen] tinyint NULL
)
WITH(HEAP, DISTRIBUTION = REPLICATE)
