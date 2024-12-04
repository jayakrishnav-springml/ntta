CREATE TABLE [Stage].[CustomerTags_Source] (
    [SRC] varchar(7) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL, 
    [HistID] int NULL, 
    [CustTagID] bigint NOT NULL, 
    [CustomerID] bigint NOT NULL, 
    [AccountStatusDesc] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL, 
    [TagAgency] varchar(6) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
    [TagID] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
    [TagStatus] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
    [TagStartDate] datetime2(3) NOT NULL, 
    [TagEndDate] datetime2(3) NOT NULL, 
    [DataIntegrityIssue] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
    [TagAssignedDate] datetime2(3) NULL, 
    [TagAssignedEndDate] datetime2(3) NULL, 
    [TagStatusDate] datetime2(3) NULL, 
    [UpdatedDate] datetime2(3) NOT NULL, 
    [UpdatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
    [CreatedDate] datetime2(3) NOT NULL, 
    [CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
    [TagType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
    [TagAlias] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
    [ReturnedOrAssignedType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
    [ItemCode] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
    [IsNonRevenue] bit NULL, 
    [SpecialityTag] varchar(30) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
    [Mounting] varchar(32) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
    [ChannelID] int NULL, 
    [AccountOpenDate] datetime2(3) NULL, 
    [AccountLastActiveDate] datetime2(3) NULL, 
    [AccountLastCloseDate] datetime2(3) NULL, 
    [EDW_UpdateDate] datetime2(0) NULL
)
WITH (CLUSTERED INDEX ( [CustomerID] ASC ), DISTRIBUTION = HASH([CustomerID]));
