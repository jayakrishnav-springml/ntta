CREATE TABLE [dbo].[Dim_ZipCode] (
    [ZipCode] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL, 
    [City] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
    [County] varchar(50) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL, 
    [State] varchar(5) COLLATE Latin1_General_100_CI_AS_KS_WS NULL, 
    [LND_UpdateDate] datetime2(3) NULL, 
    [EDW_UpdateDate] datetime2(3) NULL
)
WITH (CLUSTERED INDEX ( [ZipCode] ASC ), DISTRIBUTION = REPLICATE);
