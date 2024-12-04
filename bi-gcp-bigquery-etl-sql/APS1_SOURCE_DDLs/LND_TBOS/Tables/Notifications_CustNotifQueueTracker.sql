CREATE TABLE [Notifications].[CustNotifQueueTracker] (
    [CustNotifQueueTrackerID] bigint NOT NULL, 
    [CustomerNotificationQueueID] bigint NULL, 
    [NotifStatus] int NULL, 
    [ProcessedDateTime] datetime2(3) NULL, 
    [Remarks] varchar(100) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
    [CreatedUser] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL, 
    [CreatedDate] datetime2(3) NOT NULL, 
    [LND_UpdateDate] datetime2(3) NULL, 
    [LND_UpdateType] varchar(1) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH (CLUSTERED INDEX ( [CustNotifQueueTrackerID] ASC ), DISTRIBUTION = HASH([CustNotifQueueTrackerID]));
