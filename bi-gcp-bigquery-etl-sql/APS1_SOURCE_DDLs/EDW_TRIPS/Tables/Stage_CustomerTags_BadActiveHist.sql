CREATE TABLE [Stage].[CustomerTags_BadActiveHist] (
    [SRC] varchar(9) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL, 
    [HistID] int NULL, 
    [CustomerID] bigint NOT NULL, 
    [TagAgency] varchar(6) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
    [TagID] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
    [TagStatus] varchar(6) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL, 
    [TagStartDate] datetime2(0) NULL, 
    [TagEndDate] datetime2(0) NULL, 
    [CHANGE_NUM] int NULL
)
WITH (HEAP, DISTRIBUTION = HASH([CustomerID]));
