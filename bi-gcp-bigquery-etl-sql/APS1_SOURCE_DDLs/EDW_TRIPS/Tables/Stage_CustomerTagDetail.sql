CREATE TABLE [Stage].[CustomerTagDetail] (
    [MonthID] int NULL, 
    [CustTagID] bigint NOT NULL, 
    [CustomerID] bigint NOT NULL, 
    [TagAgency] varchar(6) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
    [TagID] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
    [TagCounter] varchar(11) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL, 
    [TagCounterDate] datetime2(0) NULL, 
    [MonthBeginTag] int NOT NULL, 
    [OpenedTag] int NOT NULL, 
    [ClosedTag] int NOT NULL, 
    [MonthEndTag] int NOT NULL
)
WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([CustomerID]));
