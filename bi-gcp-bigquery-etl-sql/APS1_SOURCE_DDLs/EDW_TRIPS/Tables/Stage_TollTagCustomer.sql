CREATE TABLE [Stage].[TollTagCustomer] (
    [CustomerID] bigint NOT NULL, 
    [AccountTypeID] smallint NOT NULL, 
    [AccountTypeDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL, 
    [AccountStatusID] smallint NOT NULL, 
    [AccountStatusDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL, 
    [AccountStatusDate] date NOT NULL, 
    [AutoReplenishmentID] int NOT NULL, 
    [AutoReplenishmentCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL, 
    [RebillAmount] decimal(19, 2) NOT NULL, 
    [RebillAmountGroupID] int NULL, 
    [ZipCode] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
    [AccountCreateDate] datetime2(3) NULL, 
    [AccountLastCloseDate] datetime2(3) NULL
)
WITH (CLUSTERED INDEX ( [CustomerID] ASC ), DISTRIBUTION = HASH([CustomerID]));
