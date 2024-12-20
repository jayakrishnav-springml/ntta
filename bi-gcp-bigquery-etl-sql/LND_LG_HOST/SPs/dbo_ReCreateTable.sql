CREATE PROC [dbo].[ReCreateTable] @SchemaName [varchar](255),@TableName [varchar](255) AS
BEGIN 
		--DECLARE @SchemaName [VARCHAR](255)	= 'TXNOWNER'
		--DECLARE @TableName	[VARCHAR](255)	= 'AVI_TRANSACTIONS'
		DECLARE @DistributionColumn		[VARCHAR](255)	= (SELECT c.name AS [column] FROM sys.pdw_column_distribution_properties d JOIN sys.columns c ON c.object_id = d.object_id AND d.distribution_ordinal = 1 AND c.column_id = d.column_id JOIN sys.tables a ON a.object_id = d.object_id AND a.name = 'AVI_TRANSACTIONS')

		DECLARE @SQLStr NVARCHAR(MAX) = '
		--STEP #1: CREATE STAGING TABLE
		IF OBJECT_ID(''TXNOWNER.AU_TXN_ADJ_DETAILS_NEW'')>0      DROP TABLE TXNOWNER.AU_TXN_ADJ_DETAILS_NEW;

		--STEP #2: Create the NEW table with DISTRIBUTION = HASH([TART_ID]
		CREATE TABLE [' + @SchemaName + '].[' + @TableName + '_NEW] WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([' + @DistributionColumn +']))
		AS 
		SELECT * FROM [' + @SchemaName + '].[' + @TableName + '];

		--STEP #2: Replace OLD table with NEW
		IF OBJECT_ID(''' + @SchemaName + '.' + @TableName + '_OLD'')>0      DROP TABLE ' + @SchemaName + '.' + @TableName + '_OLD;
		IF OBJECT_ID(''' + @SchemaName + '.' + @TableName + ''')>0          RENAME OBJECT::' + @SchemaName + '.' + @TableName + ' TO ' + @SchemaName + '.' + @TableName + '_OLD;
		RENAME OBJECT::' + @SchemaName + '.' + @TableName + '_NEW TO ' + @SchemaName + '.' + @TableName + ';

		SELECT COUNT_BIG(1) FROM ' + @SchemaName + '.' + @TableName + '; '
		PRINT @SQLStr

END

