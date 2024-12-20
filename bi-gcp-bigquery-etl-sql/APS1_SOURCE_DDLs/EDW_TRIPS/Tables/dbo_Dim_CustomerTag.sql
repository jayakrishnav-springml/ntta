CREATE TABLE [dbo].[Dim_CustomerTag]
(
	[CustTagID] bigint NOT NULL,
	[CustomerID] bigint NOT NULL,
	[TagID] varchar(12) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[ChannelID] int NOT NULL,
	[TagAgency] varchar(6) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[TagType] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[TagStatus] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[TagStatusStartDate] date NOT NULL,
	[TagStatusEndDate] date NOT NULL,
	[TagAssignedDate] date NOT NULL,
	[TagAssignedEndDate] date NOT NULL,
	[ItemCode] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[Mounting] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[SpecialityTag] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[NonRevenueFlag] int NOT NULL,
	[UpdatedDate] datetime2(3) NOT NULL,
	[LND_UpdateDate] datetime2(3) NOT NULL,
	[EDW_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([CustTagID] ASC), DISTRIBUTION = HASH([CustomerID]))
