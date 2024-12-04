CREATE TABLE [dbo].[Fact_CustomerTagDetail] (
    [MonthID] int NULL, 
    [CustomerID] bigint NOT NULL, 
    [RebillAmountGroupID] smallint NOT NULL, 
    [RebillAmount] decimal(19, 2) NULL, 
    [AutoReplenishmentID] int NOT NULL, 
    [AccountStatusID] int NOT NULL, 
    [AccountTypeID] int NOT NULL, 
    [ZipCode] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL, 
    [AccountCreateDate] datetime2(3) NULL, 
    [AccountLastCloseDate] datetime2(3) NULL, 
    [CustTagID] bigint NOT NULL, 
    [TagAgency] varchar(6) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
    [TagID] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
    [TagCounter] varchar(11) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL, 
    [TagCounterDate] datetime2(0) NULL, 
    [MonthBeginTag] int NOT NULL, 
    [OpenedTag] int NOT NULL, 
    [ClosedTag] int NOT NULL, 
    [MonthEndTag] int NOT NULL, 
    [EDW_UpdateDate] datetime2(3) NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([CustomerID]),  PARTITION ([MonthID] RANGE RIGHT FOR VALUES (202012, 202101, 202102, 202103, 202104, 202105, 202106, 202107, 202108, 202109, 202110, 202111, 202112, 202201, 202202, 202203, 202204, 202205, 202206, 202207, 202208, 202209, 202210, 202211, 202212, 202301, 202302, 202303, 202304, 202305, 202306, 202307, 202308, 202309, 202310, 202311, 202312, 202401, 202402, 202403, 202404)));
