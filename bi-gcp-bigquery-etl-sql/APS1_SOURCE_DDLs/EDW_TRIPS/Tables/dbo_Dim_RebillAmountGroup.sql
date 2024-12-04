CREATE TABLE [dbo].[Dim_RebillAmountGroup] (
    [RebillAmountGroupID] smallint NOT NULL, 
    [RebillAmountGroup] varchar(15) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL, 
    [EDW_UpdateDate] datetime2(3) NOT NULL
)
WITH (CLUSTERED INDEX ( [RebillAmountGroupID] ASC ), DISTRIBUTION = REPLICATE);
