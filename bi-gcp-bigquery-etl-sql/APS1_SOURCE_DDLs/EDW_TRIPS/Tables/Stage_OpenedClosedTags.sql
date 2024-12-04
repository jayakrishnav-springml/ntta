CREATE TABLE [Stage].[OpenedClosedTags] (
    [MonthID] int NULL, 
    [SRC] varchar(9) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL, 
    [HistID] int NULL, 
    [CustTagID] bigint NOT NULL, 
    [CustomerID] bigint NOT NULL, 
    [TagAgency] varchar(6) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
    [TagID] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
    [TagStatus] varchar(6) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL, 
    [TagStartDate] datetime2(0) NULL, 
    [TagEndDate] datetime2(0) NULL, 
    [TAGSTATUS_LAG] varchar(6) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
    [CHANGE_NUM] int NULL, 
    [CHANGE_NUM_SEQ] bigint NULL, 
    [DataIntegrityIssue] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
    [EDW_UpdateDate] datetime2(0) NULL
)
WITH (HEAP, DISTRIBUTION = HASH([CustomerID]));
