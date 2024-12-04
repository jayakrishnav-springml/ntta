CREATE TABLE [Stage].[TollTagCustomerHistory_MonthEnd] (
    [MonthID] int NOT NULL, 
    [SRC] varchar(7) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL, 
    [HistID] bigint NOT NULL, 
    [CustomerID] bigint NOT NULL, 
    [AccountTypeID] bigint NULL, 
    [AccountTypeDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
    [AccountStatusID] bigint NOT NULL, 
    [AccountStatusDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
    [AccountStatusDate] datetime2(3) NULL
)
WITH (CLUSTERED INDEX ( [CustomerID] ASC ), DISTRIBUTION = HASH([CustomerID]));
