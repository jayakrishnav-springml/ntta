CREATE TABLE [Stage].[CustomerZipcodeHistory_MonthEnd] (
    [MonthID] int NOT NULL, 
    [SRC] varchar(7) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL, 
    [CustomerID] bigint NOT NULL, 
    [ZipCode] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL, 
    [UpdatedDate] datetime2(3) NOT NULL, 
    [RN] bigint NULL
)
WITH (CLUSTERED INDEX ( [CustomerID] ASC ), DISTRIBUTION = HASH([CustomerID]));
