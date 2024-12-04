CREATE TABLE [Stage].[RebillHistory_MonthEnd] (
    [MonthID] int NOT NULL, 
    [SRC] varchar(7) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL, 
    [HistID] bigint NOT NULL, 
    [CustomerID] bigint NOT NULL, 
    [AutoReplenishmentID] int NULL, 
    [RebillAmount] decimal(19, 2) NULL, 
    [RebillAmountGroupID] int NULL, 
    [UpdatedDate] datetime2(3) NOT NULL, 
    [RN] bigint NULL
)
WITH (CLUSTERED INDEX ( [CustomerID] ASC ), DISTRIBUTION = HASH([CustomerID]));
