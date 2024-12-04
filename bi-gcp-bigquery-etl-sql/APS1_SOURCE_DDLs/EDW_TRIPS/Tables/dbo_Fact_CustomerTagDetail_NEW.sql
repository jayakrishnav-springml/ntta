CREATE TABLE [dbo].[Fact_CustomerTagDetail_NEW] (
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
WITH (CLUSTERED INDEX ( [CustomerID] ASC ), DISTRIBUTION = HASH([CustomerID]));
