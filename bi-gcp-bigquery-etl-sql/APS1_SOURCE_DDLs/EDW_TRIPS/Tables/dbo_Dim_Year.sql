CREATE TABLE [dbo].[Dim_Year]
(
	[YearID] smallint NOT NULL,
	[YearBeginDate] date NULL,
	[YearDuration] smallint NULL,
	[P1YearID] smallint NULL,
	[P2YearID] smallint NULL,
	[P3YearID] smallint NULL,
	[P4YearID] smallint NULL,
	[P5YearID] smallint NULL,
	[P6YearID] smallint NULL,
	[P7YearID] smallint NULL,
	[LastModified] datetime NOT NULL
)
WITH(CLUSTERED INDEX ([YearID] ASC), DISTRIBUTION = REPLICATE)
