CREATE TABLE [dbo].[Dim_VehicleTag]
(
	[VehicleTagID] bigint NOT NULL,
	[CustTagID] bigint NOT NULL,
	[CustomerID] bigint NOT NULL,
	[TagID] varchar(12) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[VehicleID] bigint NOT NULL,
	[TagType] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[TagStatus] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[TagAgency] varchar(6) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TagMounting] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TagSpeciality] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TagStatusDate] date NOT NULL,
	[TagStartDate] date NOT NULL,
	[TagEndDate] date NOT NULL,
	[NonRevenueFlag] int NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[LND_UpdateDate] datetime2(3) NOT NULL,
	[EDW_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([VehicleTagID] ASC), DISTRIBUTION = HASH([CustomerID]))
