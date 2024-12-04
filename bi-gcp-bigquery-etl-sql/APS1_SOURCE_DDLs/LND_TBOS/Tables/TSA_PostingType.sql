CREATE TABLE [TSA].[PostingType] (
    [PostTypeId] int NOT NULL, 
    [TransactionPostingType] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
    [IsSourcePrepaid_PostpaidTag] bit NULL, 
    [IsSourceZipCash] bit NULL, 
    [IsSourceFleet] bit NULL, 
    [IsSourceIOP] bit NULL, 
    [IsDestinationPrepaid_PostpaidTag] bit NULL, 
    [IsDestinationZipCash] bit NULL, 
    [IsDestinationFleet] bit NULL, 
    [IsDestinationIOP] bit NULL, 
    [IsRT21_T_TransactionType] bit NULL, 
    [IsRT22_V_WithTag_TransactionType] bit NULL, 
    [IsRT22_V_WithOutTag_TransactionType] bit NULL, 
    [IsTxnInvoiced_Yes] bit NULL, 
    [IsTxnInvoiced_No] bit NULL, 
    [IsTxnInvoiced_NA] bit NULL, 
    [IsAVIPostingRate] bit NULL, 
    [IsVideoPostingRate] bit NULL, 
    [PostingDescription] varchar(800) COLLATE Latin1_General_100_CI_AS_KS_WS NULL
)
WITH (CLUSTERED INDEX ( [PostTypeId] ASC ), DISTRIBUTION = REPLICATE);
