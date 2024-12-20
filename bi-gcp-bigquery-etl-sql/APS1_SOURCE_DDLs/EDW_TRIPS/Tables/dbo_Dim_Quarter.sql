CREATE TABLE [dbo].[Dim_Quarter]
(
	[QuarterID] int NULL,
	[QuarterBeginDate] date NULL,
	[QuarterEndDate] date NULL,
	[YearQuarterDesc] varchar(7) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[QuarterYearDesc] varchar(12) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[QuarterDesc] varchar(2) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[QuarterDuration] int NULL,
	[YearID] smallint NULL,
	[YearBeginDate] date NULL,
	[YearDuration] smallint NULL,
	[P1QuarterID] int NULL,
	[P2QuarterID] int NULL,
	[P3QuarterID] int NULL,
	[P4QuarterID] int NULL,
	[LY1QuarterID] int NULL,
	[P1YearID] smallint NULL,
	[P2YearID] smallint NULL,
	[P3YearID] smallint NULL,
	[P4YearID] smallint NULL,
	[P5YearID] smallint NULL,
	[P6YearID] smallint NULL,
	[P7YearID] smallint NULL,
	[LastModified] datetime NOT NULL
)
WITH(CLUSTERED INDEX ([QuarterID] ASC), DISTRIBUTION = REPLICATE)
