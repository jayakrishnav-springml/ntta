CREATE TABLE [Ref].[Dim_Year]
(
	[Cal_YearID] smallint NOT NULL,
	[Fiscal_YearID] smallint NOT NULL,
	[Year_Desc] smallint NULL,
	[YearDate] date NULL,
	[YearDuration] smallint NULL,
	[Cal_PrevYearID] smallint NULL,
	[Cal_Prev2YearID] smallint NULL,
	[Cal_Prev3YearID] smallint NULL,
	[Cal_Prev4YearID] smallint NULL,
	[Cal_Prev5YearID] smallint NULL,
	[Cal_Prev6YearID] smallint NULL,
	[Cal_Prev7YearID] smallint NULL
)
WITH(HEAP, DISTRIBUTION = REPLICATE)
