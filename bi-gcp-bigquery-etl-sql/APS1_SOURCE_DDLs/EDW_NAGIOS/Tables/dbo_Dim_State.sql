CREATE TABLE [dbo].[Dim_State]
(
	[State_ID] smallint NOT NULL,
	[Object_Type] varchar(10) COLLATE Latin1_General_100_CI_AS_KS_WS NULL,
	[State_Value] smallint NULL,
	[State_Desc] varchar(20) COLLATE Latin1_General_100_CI_AS_KS_WS NOT NULL,
	[EDW_UpdateDate] datetime2(3) NULL
)
WITH(CLUSTERED INDEX ([State_ID] ASC), DISTRIBUTION = REPLICATE)
