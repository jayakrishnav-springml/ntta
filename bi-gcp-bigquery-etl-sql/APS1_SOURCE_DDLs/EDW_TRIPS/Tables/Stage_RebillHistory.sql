CREATE TABLE [Stage].[RebillHistory] (
    [SRC] varchar(7) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL, 
    [HistID] bigint NOT NULL, 
    [CustomerID] bigint NOT NULL, 
    [AutoReplenishmentID] int NULL, 
    [RebillAmount] decimal(19, 2) NULL, 
    [UpdatedDate] datetime2(3) NOT NULL
)
WITH (CLUSTERED INDEX ( [CustomerID] ASC ), DISTRIBUTION = HASH([CustomerID]));
