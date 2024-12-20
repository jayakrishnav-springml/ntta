CREATE PROC [Utility].[RunInSourceSQL] AS
/*
USE LND_TBOS
GO
IF OBJECT_ID ('Utility.RunInSourceSQL', 'P') IS NOT NULL DROP PROCEDURE Utility.RunInSourceSQL
GO
###################################################################################################################
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc just for storing the code for run on the source
###################################################################################################################
*/



/*
###################################################################################################################
===================================================================================================================
Code Description: 
-------------------------------------------------------------------------------------------------------------------
This code for adding a new table to SSIS load process. Create this code on source, run it on APS and then may create a packege using BIML
To use it on another database (IPS or DMV) - replace all 'TBOS' to 'IPS' or 'DMV' in the text
*******************************************************************************************************************
USE TBOS 
GO

SET NOCOUNT ON
GO

IF OBJECT_ID('tempdb..#uf_TitleCase') IS NOT NULL DROP PROC #uf_TitleCase
GO

CREATE PROC #uf_TitleCase @Text [Varchar](8000), @Ret Varchar(8000) OUT 
AS
Begin  

	Declare @Reset Bit = 1;
	DECLARE @i Int = 2; -- Start checking from 2-nd letter - first should be title
	Declare @c Char(1);
	SET @Ret = '';

	If @Text Is Null
		Return -1;

	DECLARE @IsT BIT = 0;
	WHILE (@i <= Len(@Text))
	Begin
		Set @c = Substring(@Text, @i, 1)
		IF (ASCII(@c) BETWEEN 97 AND 122) SET @IsT = 1

		SET @i = @i + 1

		IF @IsT = 1 BREAK

	END


	IF @IsT = 0
		SET @Text = LOWER(@Text)

	SET @i = 1;

	While (@i <= Len(@Text))
	Begin
		Set @c = Substring(@Text, @i, 1)
		Set @Ret = @Ret + Case When @Reset = 1 Then Upper(@c) Else Lower(@c) End
		Set @Reset = Case When @c Like '[a-z]' Then 0 Else 1 End
		Set @i = @i + 1
	End

	SET @Ret = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@Ret,
		'By','By'),'HV','HV'),'ID','ID'),'In','In'),'Is','Is'),'No','No'),'Of','Of'),'Or','Or'),'PK','PK'),'To','To'),'Acc','Acc'),'Act','Act'),'Add','Add'),'Adj','Adj'),'AIP','AIP'),'Amt','Amt'),'And','And'),'Bad','Bad'),'Ban','Ban'),'BOS','BOS'),'Cnt','Cnt'),'CSV','CSV'),'Cut','Cut'),'Day','Day'),'DMV','DMV'),'DPS','DPS'),'Due','Due'),'EIP','EIP'),'End','End'),'Enh','Enh'),'Fee','Fee'),'FK_','FK_'),'FTP','FTP'),'Hex','Hex'),'ICN','ICN'),'IDX','IDX'),'Img','Img'),'INX','INX'),'IOP','IOP'),'IPS','IPS'),'IX_','IX_'),'Key','Key'),'Lic','Lic'),'Log','Log'),'Map','Map'),'MIR','MIR'),'New','New'),'NNP','NNP'),'Non','Non'),'Num','Num'),'OCR','OCR'),'Out','Out'),'Own','Own'),'Pay','Pay'),'PBM','PBM'),'Raw','Raw'),'Ref','Ref'),'Reg','Reg'),'Rev','Rev'),'ROI','ROI'),'Seq','Seq'),'Sig','Sig'),'SSN','SSN'),'Tag','Tag'),'Tax','Tax'),'Top','Top'),'TP_','TP_'),'TSA','TSA'),'Txn','Txn'),'UQ_','UQ_'),'UTC','UTC'),'VCF','VCF'),'VIN','VIN'),'VIP','VIP'),'VRB','VRB'),'VSR','VSR'),'Web','Web'),'Zip','Zip'),'ALPR','ALPR'),'Attr','Attr'),'Auto','Auto'),'Axle','Axle'),'Bill','Bill'),'Body','Body'),'Call','Call'),'Case','Case'),'Cash','Cash'),'City','City'),'Clos','Clos'),'Code','Code'),'Coll','Coll'),'Comm','Comm'),'Cust','Cust'),'Data','Data'),'Date','Date'),'Desc','Desc'),'Down','Down'),'Driv','Driv'),'Effe','Effe'),'Exit','Exit'),'File','File'),'Flag','Flag'),'Hist','Hist'),'Hold','Hold'),'Home','Home'),'Host','Host'),'Info','Info'),'Item','Item'),'JSON','JSON'),'Lane','Lane'),'Last','Last'),'Left','Left'),'Line','Line'),'List','List'),'Load','Load'),'Look','Look'),'Mail','Mail'),'Main','Main'),'Make','Make'),'Mark','Mark'),'Mode','Mode'),'MST_','MST_'),'Name','Name'),'NIX_','NIX_'),'Note','Note'),'NTTA','NTTA'),'Paid','Paid'),'Path','Path'),'Phon','Phon'),'Plan','Plan'),'Plus','Plus'),'Port','Port'),'Post','Post'),'Prev','Prev'),'Quer','Quer'),'Rate','Rate'),'Read','Read'),'Role','Role'),'Self','Self'),'Send','Send'),'Sent','Sent'),'Ship','Ship'),'Size','Size'),'Step','Step'),'Term','Term'),'Time','Time'),'Toll','Toll'),'Tran','Tran'),'Trip','Trip'),'Type','Type'),'User','User'),'With','With'),'Work','Work'),'Year','Year'),'Activ','Activ'),'Admin','Admin'),'Agenc','Agenc'),'Alert','Alert'),'Alias','Alias'),'Batch','Batch'),'Blind','Blind'),'Block','Block'),'Check','Check'),'Citat','Citat'),'Class','Class'),'Color','Color'),'Count','Count'),'Court','Court'),'Creat','Creat'),'Cycle','Cycle'),'Email','Email'),'Entry','Entry'),'Error','Error'),'Event','Event'),'Expir','Expir'),'First','First'),'Float','Float'),'Group','Group'),'Horiz','Horiz'),'Ident','Ident'),'Image','Image'),'Index','Index'),'Langu','Langu'),'Major','Major'),'Match','Match'),'Minor','Minor'),'Modif','Modif'),'Plate','Plate'),'Plaza','Plaza'),'Print','Print'),'Prior','Prior'),'Purch','Purch'),'Queue','Queue'),'Raise','Raise'),'Right','Right'),'Setup','Setup'),'Shift','Shift'),'Short','Short'),'Speed','Speed'),'Spons','Spons'),'Stage','Stage'),
		'Stand','Stand'),'Start','Start'),'STAT_','STAT_'),'State','State'),'Style','Style'),'Super','Super'),'Surve','Surve'),'Table','Table'),'Title','Title'),'TxDot','TxDot'),'Updat','Updat'),'Usage','Usage'),'Valid','Valid'),'Value','Value'),'Verif','Verif'),'Video','Video'),'VToll','VToll'),'Waive','Waive'),'Write','Write'),'Action','Action'),'Amount','Amount'),'Appear','Appear'),'Approv','Approv'),'Assign','Assign'),'Bottom','Bottom'),'Bright','Bright'),'Calcul','Calcul'),'Change','Change'),'Charge','Charge'),'Confid','Confid'),'Config','Config'),'Credit','Credit'),'Detail','Detail'),'Direct','Direct'),'DocMgr','DocMgr'),'Enable','Enable'),'Ground','Ground'),'Handle','Handle'),'Header','Header'),'Height','Height'),'Histor','Histor'),'Invoic','Invoic'),'Length','Length'),'Letter','Letter'),'Manual','Manual'),'Messag','Messag'),'Method','Method'),'Middle','Middle'),'Normal','Normal'),'Option','Option'),'Parent','Parent'),'Period','Period'),'Portal','Portal'),'Prefer','Prefer'),'Prefix','Prefix'),'Primar','Primar'),'Protec','Protec'),'Qualif','Qualif'),'Reason','Reason'),'Rebill','Rebill'),'Record','Record'),'Reject','Reject'),'Remain','Remain'),'Remark','Remark'),'Renter','Renter'),'Report','Report'),'Result','Result'),'Retail','Retail'),'Return','Return'),'Review','Review'),'Serial','Serial'),'Source','Source'),'Status','Status'),'Street','Street'),'Submit','Submit'),'Suffix','Suffix'),'Syntax','Syntax'),'System','System'),'Unread','Unread'),'Upload','Upload'),'Violat','Violat'),'Volume','Volume'),'Account','Account'),'Balance','Balance'),'Carrier','Carrier'),'Categor','Categor'),'Channel','Channel'),'Complet','Complet'),'Consume','Consume'),'Contact','Contact'),'Correct','Correct'),'Default','Default'),'Deliver','Deliver'),'Deposit','Deposit'),'Dismiss','Dismiss'),'Display','Display'),'Facilit','Facilit'),'Frequen','Frequen'),'Generat','Generat'),'Hearing','Hearing'),'Inbound','Inbound'),'Indicat','Indicat'),'Invalid','Invalid'),'Mailing','Mailing'),'Malform','Malform'),'Manager','Manager'),'Misread','Misread'),'Notific','Notific'),'Parking','Parking'),'Pending','Pending'),'Premium','Premium'),'Process','Process'),'Receipt','Receipt'),'Receive','Receive'),'Renewal','Renewal'),'Replace','Replace'),'Request','Request'),'Require','Require'),'Resolve','Resolve'),'Service','Service'),'Sponsor','Sponsor'),'Storage','Storage'),'Summary','Summary'),'Tracker','Tracker'),'Trigger','Trigger'),'Trooper','Trooper'),'Unmatch','Unmatch'),'Vehicle','Vehicle'),'Visible','Visible'),'Authorit','Authorit'),'Conflict','Conflict'),'Contrast','Contrast'),'Decision','Decision'),'Discount','Discount'),'Download','Download'),'Eligible','Eligible'),'Inventor','Inventor'),'Loaction','Loaction'),'Location','Location'),'Metadata','Metadata'),'Normalis','Normalis'),'Position','Position'),'Response','Response'),'Sequence','Sequence'),'Template','Template'),'Terminat','Terminat'),'Vertical','Vertical'),
		'Affidavit','Affidavit'),'Determina','Determina'),'Exception','Exception'),'Excessive','Excessive'),'Registrat','Registrat'),'Signature','Signature'),'Subscribe','Subscribe'),'Surrender','Surrender'),'Telephone','Telephone'),'Threshold','Threshold'),'Bankruptcy','Bankruptcy'),'Correspond','Correspond'),'Processing','Processing'),'Disposition','Disposition'),'Outstanding','Outstanding'),'Transaction','Transaction'),'Jurisdiction','Jurisdiction'),'Representativ','Representativ')

	Return 0

End
GO


IF OBJECT_ID('tempdb..#PRINT_LONG_VARIABLE_VALUE') IS NOT NULL DROP PROC #PRINT_LONG_VARIABLE_VALUE
GO

CREATE PROC #PRINT_LONG_VARIABLE_VALUE @sql [VARCHAR](MAX) AS
BEGIN
	DECLARE @ST_R INT = 0
	DECLARE @CUT_LEN INT = 8000
	DECLARE @CUT_R INT = @CUT_LEN
	DECLARE @SQL_PART VARCHAR(8000)
	DECLARE @LONG INT = LEN(@sql)
	DECLARE @SQL_PART_REV VARCHAR(MAX)
	DECLARE @LAST_ENTER_SYMBOL_NBR INT

	WHILE (@ST_R <= @LONG)
	BEGIN
		SET @SQL_PART = SUBSTRING(@sql, @ST_R, @CUT_LEN)
		SET @CUT_R = LEN(@SQL_PART) 
		-- Every time we print something - it prints on the next row
		-- it means, if we stopped in the middle of the row the next part of this row will be on the next row - we don't want this

		IF @ST_R + @CUT_LEN < @LONG -- it does not metter if this is the last part
		BEGIN
			SET @SQL_PART_REV = REVERSE(@SQL_PART)

			-- We are looking for the last "ENTER" symbol in our string part and cutting out everything after this - it will go to the next part
			-- To find it better to reverse the string
			SET @LAST_ENTER_SYMBOL_NBR = CHARINDEX(CHAR(13),@SQL_PART_REV)

			IF @LAST_ENTER_SYMBOL_NBR > 0
			BEGIN
				SET @SQL_PART = LEFT(@SQL_PART, @CUT_R - @LAST_ENTER_SYMBOL_NBR)
				-- Now should set a new length of the string part plus Enter symbol we don't want to have again
				SET @CUT_R = @CUT_R - @LAST_ENTER_SYMBOL_NBR + 1
			END
		END

		PRINT @SQL_PART
		-- Set beginning of the next part as the last part beginning + length of string part + next sybmol (+1) 
		SET @ST_R = @ST_R + @CUT_R + 1
	END
END
GO

IF OBJECT_ID('tempdb..#GET_INDEX_STRING') IS NOT NULL DROP PROC #GET_INDEX_STRING
GO
CREATE PROC #GET_INDEX_STRING @SCHEMA_NAME [VARCHAR](100), @TABLE [VARCHAR](100),@SQL_STRING [VARCHAR](MAX) OUT AS

BEGIN
	DECLARE @TABLE_INDEX VARCHAR(100)

	SELECT @TABLE_INDEX = I.type_desc
	FROM sys.tables as t
	JOIN sys.indexes AS I ON I.object_id = t.object_id
	WHERE t.name = @TABLE AND I.index_id <=1

	IF @TABLE_INDEX = 'CLUSTERED'
	BEGIN
		WITH CTE AS
		(
			SELECT C.column_id, u.name AS column_name, CASE WHEN C.is_descending_key = 1 THEN ' DESC' ELSE ' ASC' END AS column_Order
				, ROW_NUMBER() OVER (ORDER BY C.column_id) AS RN 
			FROM sys.tables as t
			JOIN sys.schemas as S ON S.SCHEMA_ID = t.SCHEMA_ID AND S.name = @SCHEMA_NAME
			JOIN sys.indexes AS I ON I.object_id = t.object_id AND I.index_id <=1
			JOIN sys.index_columns AS C ON C.object_id = t.object_id AND C.index_id = I.index_id
			JOIN sys.columns AS u ON u.column_id = C.column_id AND u.object_id = t.object_id
			WHERE t.name = @TABLE
		)
		, CTE_JOINT AS 
		(
			SELECT
				' [' + CTE1.column_name + ']' AS INDEX_1st_COLUMN
				, ' [' + CTE1.column_name + ']' + CTE1.column_Order
				+ ISNULL(', ['+ CTE2.column_name + ']' + CTE2.column_Order, '')
				+ ISNULL(', ['+ CTE3.column_name + ']' + CTE3.column_Order, '')
				+ ISNULL(', ['+ CTE4.column_name + ']' + CTE4.column_Order, '')
				+ ISNULL(', ['+ CTE5.column_name + ']' + CTE5.column_Order, '')
				+ ISNULL(', ['+ CTE6.column_name + ']' + CTE6.column_Order, '')
				+ ISNULL(', ['+ CTE7.column_name + ']' + CTE7.column_Order, '')
				+ ISNULL(', ['+ CTE8.column_name + ']' + CTE8.column_Order, '')
				+ ISNULL(', ['+ CTE9.column_name + ']' + CTE9.column_Order, '')
				+ ISNULL(', ['+ CTE10.column_name + ']' + CTE10.column_Order, '') + ' ' AS INDEX_COULUMNS
			FROM CTE AS CTE1
			LEFT JOIN CTE AS CTE2 ON  CTE2.RN = 2
			LEFT JOIN CTE AS CTE3 ON  CTE3.RN = 3
			LEFT JOIN CTE AS CTE4 ON  CTE4.RN = 4
			LEFT JOIN CTE AS CTE5 ON  CTE5.RN = 5
			LEFT JOIN CTE AS CTE6 ON  CTE6.RN = 6
			LEFT JOIN CTE AS CTE7 ON  CTE7.RN = 7
			LEFT JOIN CTE AS CTE8 ON  CTE8.RN = 8
			LEFT JOIN CTE AS CTE9 ON  CTE9.RN = 9
			LEFT JOIN CTE AS CTE10 ON CTE10.RN = 10
			WHERE CTE1.RN = 1
		)
		SELECT TOP 1
			@SQL_STRING = @TABLE_INDEX + ' INDEX (' + INDEX_COULUMNS + '), DISTRIBUTION = HASH(' + INDEX_1st_COLUMN + ')'
		FROM CTE_JOINT
	END
	ELSE
	BEGIN
		IF @TABLE_INDEX = 'CLUSTERED COLUMNSTORE'
		BEGIN
			SET @SQL_STRING = @TABLE_INDEX + ' INDEX, DISTRIBUTION = ROUND_ROBIN'
		END
		ELSE
		BEGIN
			SET @SQL_STRING = @TABLE_INDEX
		END
		--WITH (CLUSTERED INDEX ( [ACCT_ID] ASC , [ACCT_TAG_SEQ] ASC ), DISTRIBUTION = HASH([ACCT_ID]));
	END
END
GO

IF OBJECT_ID('tempdb..#GET_CREATE_STATISTICS_SQL') IS NOT NULL DROP PROC #GET_CREATE_STATISTICS_SQL
GO
CREATE PROC #GET_CREATE_STATISTICS_SQL @SCHEMA_NAME [VARCHAR](100), @TABLE [VARCHAR](100),@SQL_STRING [VARCHAR](MAX) OUT AS
BEGIN
	--DECLARE @SCHEMA_NAME [VARCHAR](100) = 'TollPlus', @TABLE [VARCHAR](100) = 'Tp_Customer_Balances', @SQL_STRING [VARCHAR](MAX)
	
	IF OBJECT_ID('TempDB..#TABLE_STATS') IS NOT NULL DROP TABLE #TABLE_STATS;


	WITH CTE AS
	(
		-- Statistic for foreign key
		SELECT 
			s.[name] AS schemaName, 
			OBJECT_NAME(A.PARENT_OBJECT_ID) AS [table_name], 
			'STAT_' + F.name AS [stats_name], 
			B.name AS [column_name], 
			ROW_NUMBER() OVER (PARTITION BY F.name ORDER BY b.column_id) AS RN
		FROM SYS.FOREIGN_KEY_COLUMNS A 
		JOIN sys.foreign_keys f on f.object_id = a.constraint_object_id
		JOIN sys.schemas S	ON S.schema_id = f.schema_id AND S.name = @SCHEMA_NAME
		JOIN SYS.COLUMNS B ON A.PARENT_COLUMN_ID = B.COLUMN_ID 
			AND A.PARENT_OBJECT_ID = B.OBJECT_ID 
		WHERE OBJECT_NAME(A.PARENT_OBJECT_ID) = @TABLE

		UNION ALL

		-- Statistics for nonclustered indexes - instead of create indexes
		SELECT 
			s.[name] AS schemaName, 
			t.name AS [table_name], 
			'STAT_' + I.name AS [stats_name], 
			u.name AS column_name,
			ROW_NUMBER() OVER (PARTITION BY I.name ORDER BY C.column_id) AS RN 
		FROM sys.tables as t
		JOIN sys.schemas as S ON S.SCHEMA_ID = t.SCHEMA_ID AND S.name = @SCHEMA_NAME
		JOIN sys.indexes AS I ON I.object_id = t.object_id AND I.index_id > 1
		JOIN sys.index_columns AS C ON C.object_id = t.object_id AND C.index_id = I.index_id
		JOIN sys.columns AS u ON u.column_id = C.column_id AND u.object_id = t.object_id
		WHERE t.name = @TABLE

		UNION ALL

		-- User-created stats
		SELECT
			s.[name] AS schemaName
			,t.[name] AS [table_name]
			,'STAT_' + ss.[name] AS [stats_name]
			,c.name AS [column_name]
			, ROW_NUMBER() OVER (PARTITION BY ss.[name] ORDER BY C.column_id) AS RN 
		FROM        sys.schemas s
		JOIN        sys.tables t                    ON      t.[schema_id]  = s.[schema_id]
		JOIN		sys.stats ss					ON		ss.[object_id] = t.[object_id] AND ss.user_created = 1
		JOIN		sys.stats_columns sc			ON		sc.[object_id] = t.[object_id] AND ss.stats_id = sc.stats_id
		JOIN        sys.columns c                   ON      t.[object_id]  = c.[object_id] AND sc.column_id  = c.column_id
		WHERE  t.[name] = @TABLE
	)
	, CTE_JOINT AS 
	(
		SELECT 
			CTE1.schemaName
			,CTE1.table_name
			,CTE1.stats_name
			, '[' + CTE1.column_name + ']'
			+ ISNULL(', ['+ CTE2.column_name + ']', '')
			+ ISNULL(', ['+ CTE3.column_name + ']', '')
			+ ISNULL(', ['+ CTE4.column_name + ']', '')
			+ ISNULL(', ['+ CTE5.column_name + ']', '')
			+ ISNULL(', ['+ CTE6.column_name + ']', '')
			+ ISNULL(', ['+ CTE7.column_name + ']', '')
			+ ISNULL(', ['+ CTE8.column_name + ']', '')
			+ ISNULL(', ['+ CTE9.column_name + ']', '')
			+ ISNULL(', ['+ CTE10.column_name + ']', '') AS stats_col 
		FROM CTE AS CTE1
		LEFT JOIN CTE AS CTE2 ON CTE2.stats_name = CTE1.stats_name AND CTE2.RN = 2
		LEFT JOIN CTE AS CTE3 ON CTE3.stats_name = CTE1.stats_name AND CTE3.RN = 3
		LEFT JOIN CTE AS CTE4 ON CTE4.stats_name = CTE1.stats_name AND CTE4.RN = 4
		LEFT JOIN CTE AS CTE5 ON CTE5.stats_name = CTE1.stats_name AND CTE5.RN = 5
		LEFT JOIN CTE AS CTE6 ON CTE6.stats_name = CTE1.stats_name AND CTE6.RN = 6
		LEFT JOIN CTE AS CTE7 ON CTE7.stats_name = CTE1.stats_name AND CTE7.RN = 7
		LEFT JOIN CTE AS CTE8 ON CTE8.stats_name = CTE1.stats_name AND CTE8.RN = 8
		LEFT JOIN CTE AS CTE9 ON CTE9.stats_name = CTE1.stats_name AND CTE9.RN = 9
		LEFT JOIN CTE AS CTE10 ON CTE10.stats_name = CTE1.stats_name AND CTE10.RN = 10
		WHERE CTE1.RN = 1
	)
	SELECT 
			schemaName
			,table_name
			,stats_name
			,stats_col
			,'CREATE STATISTICS [' + stats_name + '] ON ' + @SCHEMA_NAME + '.[' + @TABLE + '] (' + stats_col + ');' AS SQL_STRING
			, ROW_NUMBER() OVER(ORDER BY stats_name) AS RN
	INTO #TABLE_STATS
	FROM CTE_JOINT

	--SELECT * FROM #TABLE_STATS

	DECLARE @NUM_OF_COLUMNS INT
	DECLARE @THIS_SQL_STRING VARCHAR(MAX) = '', @Title_SQL_String VARCHAR(MAX) = ''
	DECLARE @INDICAT SMALLINT = 1

	SET @SQL_STRING  = ''

	SELECT @NUM_OF_COLUMNS = MAX(RN) FROM #TABLE_STATS
	SET @INDICAT = 1
	-- If only 1 period (and 1 partition) - @PART_RANGES is empty
	WHILE (@INDICAT <= @NUM_OF_COLUMNS)
	BEGIN
		
		SELECT @THIS_SQL_STRING = SQL_STRING FROM #TABLE_STATS WHERE RN = @INDICAT --ORDER BY stats_name
		EXEC #uf_TitleCase @THIS_SQL_STRING, @Title_SQL_String OUTPUT

		SET @SQL_STRING = @SQL_STRING + char(13) + char(9) + REPLACE(REPLACE(@Title_SQL_String,'CREATE STATISTICS','CREATE STATISTICS'), ' ON ', ' ON ')

		SET @INDICAT += 1

	END

	--PRINT @SQL_STRING
END
go

IF OBJECT_ID('tempdb..#GET_CREATE_TABLE_SQL') IS NOT NULL DROP PROC #GET_CREATE_TABLE_SQL
GO
CREATE PROC #GET_CREATE_TABLE_SQL @SCHEMA_NAME [VARCHAR](100), @TABLE_NAME [VARCHAR](100) AS 

BEGIN

	DECLARE @SQL_STRING VARCHAR(MAX) = '';
	DECLARE @TitleTableName VARCHAR(100)
	DECLARE @TitleSchemaName VARCHAR(100)
	EXEC #uf_TitleCase @TABLE_NAME, @TitleTableName OUTPUT
	EXEC #uf_TitleCase @SCHEMA_NAME, @TitleSchemaName OUTPUT
	SELECT @TitleSchemaName = REPLACE(@TitleSchemaName,'TER','TER')

	DECLARE @NUM_OF_COLUMNS INT
	DECLARE @TABLE_DISTRIBUTION VARCHAR(100) = ''
	DECLARE @TABLE_INDEX VARCHAR(MAX) = ''
	--DECLARE @NEW_TABLE_NAME VARCHAR(100) = @TABLE_NAME + '_NEW_SET'

	--EXEC EDW_RITE.DBO.GET_DISRTIBUTION_STRING @SCHEMA_NAME, @TABLE_NAME, @TABLE_DISTRIBUTION OUTPUT 

	EXEC #GET_INDEX_STRING @SCHEMA_NAME, @TABLE_NAME, @TABLE_INDEX OUTPUT 

	IF OBJECT_ID('tempdb..#TABLE_COLUMNS') IS NOT NULL DROP TABLE #TABLE_COLUMNS;
	SELECT      s.name AS SchemaName, t.name AS TableName, CASE WHEN c.name = 'ERRORCODE' THEN 'ReplaceErrorCode' ELSE c.name END AS ColumnName, C.column_id, TYPE_NAME(c.system_type_id) AS ColumnType, c.max_length, c.PRECISION,c.scale,C.is_nullable, 
				ROW_NUMBER() OVER(ORDER BY C.column_id) AS RN
	INTO #TABLE_COLUMNS
	FROM        sys.columns c
	JOIN        sys.tables  t   ON c.object_id = t.object_id
	JOIN		sys.schemas S	ON S.schema_id = t.schema_id AND S.name = @SCHEMA_NAME
	WHERE       t.name = @TABLE_NAME

	--:: Alert check
	IF EXISTS (SELECT * FROM #TABLE_COLUMNS WHERE ColumnType IN ('IMAGE','BINARY','VARBINARY')) SELECT * FROM #TABLE_COLUMNS WHERE ColumnType IN ('IMAGE','BINARY','VARBINARY')
	IF EXISTS (SELECT * FROM #TABLE_COLUMNS WHERE ColumnType IN ('TEXT','NTEXT','NVARCHAR','MONEY')) SELECT * FROM #TABLE_COLUMNS WHERE ColumnType IN ('TEXT','NTEXT','NVARCHAR', 'NCHAR','MONEY')

	--PRINT 'GOT NEW_TABLE_COLUMNS'

	SELECT @NUM_OF_COLUMNS = MAX(RN) FROM #TABLE_COLUMNS

	DECLARE @SELECT_String VARCHAR(MAX) = '  '
	--DECLARE @THIS_SELECT_String VARCHAR(MAX) = ''
	DECLARE @Delimiter VARCHAR(3) = ''
	DECLARE @INDICAT SMALLINT = 1
	DECLARE @ColumnName Varchar(100)
	DECLARE @ColumnType Varchar(100)
	DECLARE @TitleCName Varchar(100)
	-- If only 1 period (and 1 partition) - @PART_RANGES is empty

	WHILE (@INDICAT <= @NUM_OF_COLUMNS)
	BEGIN
		
		SELECT
			@ColumnName = M.ColumnName,  
			@ColumnType = CASE 
				WHEN M.ColumnType = 'IMAGE' THEN 'VARBINARY'
				WHEN M.ColumnType = 'XML' THEN 'VARCHAR'
				WHEN M.ColumnType = 'TEXT' THEN 'VARCHAR'
				WHEN M.ColumnType = 'NTEXT' THEN 'VARCHAR'
				WHEN M.ColumnType = 'NVARCHAR' THEN 'VARCHAR'
				WHEN M.ColumnType = 'NUMERIC' THEN 'DECIMAL'
				WHEN M.ColumnType = 'Money' THEN 'DECIMAL(19,2)'
				WHEN M.ColumnType = 'DATETIME' THEN 'DATETIME2(3)'
				ELSE UPPER(M.ColumnType)
			END +
			CASE 
				WHEN M.ColumnType = 'IMAGE' THEN '(MAX)'
				WHEN M.ColumnType = 'XML' THEN '(8000)'
				WHEN M.ColumnType = 'TEXT' THEN '(8000)'
				WHEN M.ColumnType = 'NTEXT' THEN '(8000)'
				WHEN M.ColumnType = 'DATETIME2' THEN '(' + CAST(m.scale AS VARCHAR) +')'
				WHEN M.ColumnType IN ('BINARY','VARBINARY') THEN '(' + ISNULL(NULLIF(CAST(m.max_length AS VARCHAR),'-1'),'8000') +')'
				WHEN M.ColumnType IN ('DECIMAL','NUMERIC') THEN '(' + CAST(m.PRECISION AS VARCHAR) + ',' + CAST(m.scale AS VARCHAR) +')'
				WHEN M.ColumnType LIKE '%CHAR' THEN '(' + ISNULL(NULLIF(CAST(m.max_length AS VARCHAR),'-1'),'8000') +')'
				ELSE ''
			END + CHAR(9) + CASE WHEN m.is_nullable = 0 THEN ' NOT' ELSE '' END + ' NULL'
		FROM #TABLE_COLUMNS M
		WHERE M.RN = @INDICAT AND M.ColumnType NOT IN ('IMAGE','BINARY','VARBINARY') 

		EXEC #uf_TitleCase @ColumnName, @TitleCName OUTPUT
		
		IF @ColumnName IS NOT NULL
		BEGIN
			SET @SELECT_String = @SELECT_String +  + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) + @Delimiter + '[' + @TitleCName + '] ' + @ColumnType

			SET	@Delimiter = ', '
		END
		SET @INDICAT += 1

	END

	SET @SELECT_String = @SELECT_String + '
		, [LND_UpdateDate] DATETIME2(3) NULL
		, [LND_UpdateType] VARCHAR(1) NULL'

	DECLARE @TABLE_STATISTICS VARCHAR(MAX) = ''
	EXEC #GET_CREATE_STATISTICS_SQL @TitleSchemaName, @TitleTableName, @TABLE_STATISTICS OUTPUT 
	
	SET @TABLE_STATISTICS = @TABLE_STATISTICS + '
	CREATE STATISTICS [STAT_' + @TitleTableName + '_LND_UpdateDate] ON ' + @TitleSchemaName + '.[' + @TitleTableName + '] (LND_UpdateDate);'

	-- Add to statistics UpdatedDate and distribution culumn (first column fron clustered index)
	IF CHARINDEX('[UpdatedDate]',@SELECT_String) > 0 -- If this column exists - create statistics for it.
	BEGIN
		SET @TABLE_STATISTICS = @TABLE_STATISTICS + '
	CREATE STATISTICS [STAT_' + @TitleTableName + '_UpdatedDate] ON ' + @TitleSchemaName + '.[' + @TitleTableName + '] (UpdatedDate);'
	END 

	SET @SQL_STRING = '
	IF OBJECT_ID(''' + @TitleSchemaName + '.' + @TitleTableName + ''') IS NOT NULL			DROP TABLE ' + @TitleSchemaName + '.' + @TitleTableName + ';

	CREATE TABLE ' + @TitleSchemaName + '.' + @TitleTableName + ' (' + @SELECT_String + ') 
	WITH (' + @TABLE_INDEX + ')'

	IF OBJECT_ID('tempdb..#TABLE_COLUMNS') IS NOT NULL DROP TABLE #TABLE_COLUMNS;

	EXEC #PRINT_LONG_VARIABLE_VALUE @SQL_STRING
	EXEC #PRINT_LONG_VARIABLE_VALUE @TABLE_STATISTICS

END
GO

IF OBJECT_ID('tempdb..#GET_Service_INSERT_Table_SQL') IS NOT NULL DROP PROC #GET_Service_INSERT_Table_SQL
GO

CREATE PROC #GET_Service_INSERT_Table_SQL @TABLE_NAME VARCHAR(100), @DataBaseName VARCHAR(10) AS
BEGIN
	--DECLARE @SQL_STRING VARCHAR(MAX) = ''
	DECLARE @SQL VARCHAR(MAX) = ''
	DECLARE @ROW_COUNT BIGINT = 0

	SET @SQL = 'DECLARE @SQL_STRING VARCHAR(MAX)
	SELECT @SQL_STRING = ''EXEC Utility.TableLoadParameters_Insert ''''' + @DataBaseName + ''''',''''' + @TABLE_NAME + ''''', '' + CAST(COUNT_BIG(1) AS VARCHAR)
	FROM ' + @TABLE_NAME + '
	PRINT @SQL_STRING'

	EXEC (@SQL)

END
GO



IF OBJECT_ID('tempdb..#GET_CREATE_TABLES_BY_LIST') IS NOT NULL DROP PROC #GET_CREATE_TABLES_BY_LIST
GO
CREATE PROC #GET_CREATE_TABLES_BY_LIST @TABLE_LIST VARCHAR(MAX), @DataBaseName VARCHAR(10) AS --,@SQL_STRING [VARCHAR](MAX) OUT AS
BEGIN

	DECLARE @NUM_OF_TABLES INT
	DECLARE @TABLE_NAME VARCHAR(100)
	DECLARE @SCHEMA_NAME VARCHAR(100)
	DECLARE @TitleFullName VARCHAR(130)
	DECLARE @TitleTableName VARCHAR(100)
	DECLARE @TitleSchemaName VARCHAR(100)

	IF OBJECT_ID('tempdb..#SCHEMA_TABLES') IS NOT NULL DROP TABLE #SCHEMA_TABLES;

	SELECT SchemaName,TableName,FULL_NAME,
			ROW_NUMBER() OVER(ORDER BY SchemaName, TableName) AS RN
	INTO #SCHEMA_TABLES
	FROM
		(
			SELECT      s.name AS SchemaName, t.name AS TableName, '[' + s.name + '].[' + t.name + ']' AS FULL_NAME--, '[HISTORY].[' + H.TableName + ']' AS History_TableName, 
			FROM        sys.tables  t   
			JOIN		sys.schemas S	ON S.schema_id = t.schema_id
		) A
	WHERE CHARINDEX(A.FULL_NAME,@TABLE_LIST) > 0

	SELECT * FROM #SCHEMA_TABLES

	SELECT @NUM_OF_TABLES = MAX(RN) FROM #SCHEMA_TABLES

	DECLARE @INDICAT SMALLINT = 1
	-- If only 1 period (and 1 partition) - @PART_RANGES is empty

	PRINT 'UPDATE Utility.TableLoadParameters SET CreateFlag = 0'

	WHILE (@INDICAT <= @NUM_OF_TABLES)
	BEGIN
		
		SELECT @TABLE_NAME = TableName, @SCHEMA_NAME = SchemaName--, @FULL_NAME = FULL_NAME--, @History_TableName = History_TableName
		FROM #SCHEMA_TABLES M
		WHERE M.RN = @INDICAT --AND CHARINDEX(M.FULL_NAME,@EXCLUDE_TABLES) = 0
		
		IF @TABLE_NAME IS NOT NULL
		BEGIN

			EXEC #uf_TitleCase @TABLE_NAME, @TitleTableName OUTPUT
			EXEC #uf_TitleCase @SCHEMA_NAME, @TitleSchemaName OUTPUT
			SELECT @TitleSchemaName = REPLACE(@TitleSchemaName,'TER','TER')

			SET @TitleFullName = '[' + @TitleSchemaName + '].' + '[' + @TitleTableName + ']'

			EXEC #GET_CREATE_TABLE_SQL @TitleSchemaName, @TitleTableName --, @SQL_SELECT OUTPUT, @SQL_STATS OUTPUT;


			EXEC #GET_Service_INSERT_Table_SQL @TitleFullName, @DataBaseName

			PRINT 'EXEC Utility.CreateStageTables ''' + @TitleFullName + ''''

		END
		SET @INDICAT += 1
	END

END
GO


DECLARE @INCLUDE_TABLES VARCHAR(MAX), @DataBaseName VARCHAR(10) = 'TBOS'

SET @INCLUDE_TABLES = '
[FINANCE].[REFUNDREQUESTS_QUEUE]
'

EXEC #GET_CREATE_TABLES_BY_LIST @INCLUDE_TABLES, @DataBaseName

###################################################################################################################
*/


/*
###################################################################################################################
===================================================================================================================
Code Description: 
-------------------------------------------------------------------------------------------------------------------
This Code is to Update RowCount on Parameters. Run created script on APS
To use it on another database (IPS or DMV) - replace all 'TBOS' to 'IPS' or 'DMV' in the text
Make sure the table list is up to date
*******************************************************************************************************************
USE TBOS 
GO

SET NOCOUNT ON
GO

IF OBJECT_ID('tempdb..#GET_Service_INSERT_Table_SQL') IS NOT NULL DROP PROC #GET_Service_INSERT_Table_SQL
GO

CREATE PROC #GET_Service_INSERT_Table_SQL @TABLE_NAME [VARCHAR](100) AS
BEGIN
	--DECLARE @SQL_STRING VARCHAR(MAX) = ''
	DECLARE @SQL VARCHAR(MAX) = ''
	DECLARE @ROW_COUNT BIGINT = 0
	DECLARE @DataBaseName VARCHAR(30) = 'TBOS'
	--DECLARE @Full_NAME VARCHAR(100) = 

	SET @SQL = 'DECLARE @SQL_STRING VARCHAR(MAX)
	SELECT @SQL_STRING = ''UPDATE Utility.TableLoadParameters SET RowCnt = '' + CAST(COUNT_BIG(1) AS VARCHAR) + '' WHERE FullName = ''''' + @TABLE_NAME + '''''''
	FROM ' + @TABLE_NAME + '
	PRINT @SQL_STRING'

	EXEC (@SQL)

END
GO

IF OBJECT_ID('tempdb..#GET_CREATE_TABLES_BY_LIST') IS NOT NULL DROP PROC #GET_CREATE_TABLES_BY_LIST
GO
CREATE PROC #GET_CREATE_TABLES_BY_LIST @TABLE_LIST [VARCHAR](MAX) AS --,@SQL_STRING [VARCHAR](MAX) OUT AS
BEGIN

	DECLARE @NUM_OF_TABLES INT
	DECLARE @TABLE_NAME VARCHAR(100)

	IF OBJECT_ID('tempdb..#SCHEMA_TABLES') IS NOT NULL DROP TABLE #SCHEMA_TABLES;

	SELECT TableName,FULL_NAME,
			ROW_NUMBER() OVER(ORDER BY TableName) AS RN
	INTO #SCHEMA_TABLES
	FROM
		(
			SELECT      s.name + '.' +  t.name AS TableName, '[' + s.name + '].[' +  t.name + ']' AS FULL_NAME 
			FROM        sys.tables  t   
			JOIN		sys.schemas S	ON S.schema_id = t.schema_id
		) A
	WHERE CHARINDEX(A.FULL_NAME,@TABLE_LIST) > 0 OR CHARINDEX(A.TableName,@TABLE_LIST) > 0

	--SELECT * FROM #SCHEMA_TABLES
	SELECT @NUM_OF_TABLES = MAX(RN) FROM #SCHEMA_TABLES

	DECLARE @INDICAT SMALLINT = 1
	-- If only 1 period (and 1 partition) - @PART_RANGES is empty

	WHILE (@INDICAT <= @NUM_OF_TABLES)
	BEGIN
		
		SELECT @TABLE_NAME = TableName
		FROM #SCHEMA_TABLES M
		WHERE M.RN = @INDICAT --AND CHARINDEX(M.FULL_NAME,@EXCLUDE_TABLES) = 0
		
		IF @TABLE_NAME IS NOT NULL
		BEGIN
			EXEC #GET_Service_INSERT_Table_SQL @TABLE_NAME
		END
		SET @INDICAT += 1
	END

END
GO


DECLARE @INCLUDE_TABLES VARCHAR(MAX)

SET @INCLUDE_TABLES = '
[COURT].[AdminHearing]
[COURT].[Counties]
[COURT].[Courts]
[COURT].[PlazaCourts]
[CASEMANAGER].[PmCase]
[CASEMANAGER].[PmCaseTypes]
[TER].[PaymentPlans]
[TER].[PaymentPlanTerms]
[TER].[PaymentPlanViolator]
[TER].[HvStatusLookup]
[TER].[HabitualViolators]
[TER].[ViolatorCollectionsOutbound]
[TER].[VehicleRegBlocks]
[TER].[VRBRequestDMV]
[TER].[DPSBanActions]
[TER].[VehicleBan]
[TER].[BanActions]
[TER].[CitationNumberSequence]
[TER].[CollectionAgencies]
[TER].[CollectionAgencyCounties]
[TER].[FailuretoPayCitations]
[TER].[HVEligibleTransactions]
[TER].[ViolatorCollectionsAgencyTracker]
[TER].[ViolatorCollectionsInbound]
[FINANCE].[ADJUSTMENT_LINEITEMS]
[FINANCE].[ADJUSTMENTS]
[FINANCE].[CustomerPayments]
[FINANCE].[PAYMENTTXN_LINEITEMS]
[FINANCE].[PAYMENTTXNS]
[FINANCE].[REFUNDREQUESTS_QUEUE]
[NOTIFICATIONS].[CustomerNotificationQueue]
[NOTIFICATIONS].[ConfigAlertTypeAlertChannels]
[NOTIFICATIONS].[ALERTCHANNELS]
[NOTIFICATIONS].[ALERTTYPES]
[DOCMGR].[TP_CUSTOMER_OUTBOUNDCOMMUNICATIONS]
[TOLLPLUS].[REF_LOOKUPTYPECODES_HIERARCHY]
[TOLLPLUS].[INVOICE_HEADER]
[TOLLPLUS].[INVOICE_LINEITEMS]
[TOLLPLUS].[ICN]
[TOLLPLUS].[TP_BANKRUPTCY_FILING]
[TOLLPLUS].[TP_VIOLATEDTRIPS]
[TOLLPLUS].[TP_CUSTOMER_VEHICLES]
[TOLLPLUS].[TP_CUSTOMER_CONTACTS]
[TOLLPLUS].[TP_CUSTOMER_ATTRIBUTES]
[TOLLPLUS].[TP_CUSTOMER_ADDRESSES]
[TOLLPLUS].[TP_CUSTOMER_PHONES]
[TOLLPLUS].[TP_CUSTOMER_EMAILS]
[TOLLPLUS].[TP_CUSTOMER_BALANCES]
[TOLLPLUS].[TP_CUSTOMER_FLAGS]
[TOLLPLUS].[TP_CUSTOMER_INTERNAL_USERS]
[TOLLPLUS].[TP_CUSTOMER_TAGS]
[TOLLPLUS].[TP_CUSTOMER_TRIP_CHARGES_TRACKER]
[TOLLPLUS].[TP_CUSTOMER_TRIP_RECEIPTS_TRACKER]
[TOLLPLUS].[TP_CUSTOMER_VEHICLE_TAGS]
[TOLLPLUS].[TP_CUSTOMERS]
[TOLLPLUS].[TP_CUSTOMERTRIPS]
[TOLLPLUS].[TP_CUSTOMERTRIPSTATUSTRACKER]
[TOLLPLUS].[TP_TRIPS]
[TOLLPLUS].[TP_VEHICLE_MODELS]
[TOLLPLUS].[TP_VIOLATED_TRIP_CHARGES_TRACKER]
[TOLLPLUS].[TP_VIOLATED_TRIP_RECEIPTS_TRACKER]
[TOLLPLUS].[TP_VIOLATEDTRIPS]
[TOLLPLUS].[TP_VIOLATEDTRIPSTATUSTRACKER]
[TOLLPLUS].[TP_IMAGE_REVIEW_RESULT_IMAGES]
[TOLLPLUS].[TP_IMAGE_REVIEW_RESULTS]
[TOLLPLUS].[TP_EXEMPTED_PLATES]
[TOLLPLUS].[CustomerFlagReferenceLookup]
[TOLLPLUS].[MbsHeader]
[TOLLPLUS].[MbsInvoices]
[TOLLPLUS].[InvoiceAttributes]
[TOLLPLUS].[BankruptcyStatuses]
[TOLLPLUS].[AddressSources]
[TOLLPLUS].[AGENCIES]
[TOLLPLUS].[CaseLinks]
[TOLLPLUS].[Dispositions]
[TOLLPLUS].[DMVExceptionDetails]
[TOLLPLUS].[DMVExceptionQueue]
[TOLLPLUS].[ESCHEATMENT_ELGIBLE_CUSTOMERS]
[TOLLPLUS].[FleetCustomerAttributes]
[TOLLPLUS].[FleetCustomersFileTracker]
[TOLLPLUS].[FleetCustomerVehiclesQueue]
[TOLLPLUS].[ICN_CASH]
[TOLLPLUS].[ICN_ITEMS]
[TOLLPLUS].[ICN_TXNS]
[TOLLPLUS].[ICN_VARIANCE]
[TOLLPLUS].[INVOICE_CHARGES_TRACKER]
[TOLLPLUS].[LANES]
[TOLLPLUS].[LOCATIONS]
[TOLLPLUS].[PLAZA_TYPES]
[TOLLPLUS].[PLAZAS]
[TOLLPLUS].[REF_INVOICE_WORKFLOW_STAGE_FEES]
[TOLLPLUS].[REF_INVOICE_WORKFLOW_STAGES]
[TOLLPLUS].[TRIPSTAGES]
[TOLLPLUS].[TRIPSTATUSES]
[TOLLPLUS].[TXNTYPE_CATEGORIES]
[TOLLPLUS].[UnMatchedTxnsQueue]
[TOLLPLUS].[VEHICLECLASSES]
[TOLLPLUS].[VIOLATION_WORKFLOW]
[TOLLPLUS].[ZipCodes]
[TOLLPLUS].[TP_EXEMPTED_PLATES]
[Court].[CourtJudges]
[Finance].[BANKPAYMENTS]
[Finance].[CHEQUEPAYMENTS]
[IOP].[AGENCIES]
[TollPlus].[REF_FEETYPES]
[Finance].[GL_TXN_LINEITEMS]
[Inventory].[ITEMINVENTORY]
[Inventory].[ITEMINVENTORYLOCATIONS]
[Inventory].[ITEMTYPES]
[IOP].[BOS_IOP_OUTBOUNDTRANSACTIONS]
[IOP].[IopPlates]
[IOP].[IopTags]
[Parking].[ParkingTrips]
[TER].[DPSTrooper]
[TollPlus].[TpFileTracker]
[TollPlus].[LaneCategories]
[Finance].[Adjustments]
[TollPlus].[PlateTypes]
[TollPlus].[TP_TRANSACTION_TYPES]
[TollPlus].[TP_TOLLTXN_REASONCODES]
[TOLLPLUS].[Channels]
[TOLLPLUS].[TP_Transaction_Types]
[TranProcessing].[HostBosFileTracker]
[TranProcessing].[IOPInboundRawTransactions]
[TranProcessing].[NTTAHostBOSFileTracker]
[TranProcessing].[NTTARawTransactions]
[TranProcessing].[TripSource]
[TranProcessing].[TSARawTransactions]
[TranProcessing].[TxnDispositions]
[Finance].[BusInessProcess_TxnTypes_Associations]
[Finance].[BusinessProcesses]
[Finance].[CharTofAccounts]
[Finance].[GL_Transactions]
[Finance].[TxnTypes]
[Finance].[GlDailySummaryByCoaIdBuId]
[TER].[HabitualViolatorStatusTracker]
[TER].[VRBRequestDallas]
[TollPlus].[MbsProcessStatus]
[TollPlus].[Merged_Customers]
[TollPlus].[OperationalLocations]
[TollPlus].[TP_AppLication_Parameters]
[TollPlus].[TP_Customer_AccStatus_Tracker]
[TollPlus].[TP_CustTxns]
[TollPlus].[TP_FileTracker]
[TollPlus].[TP_Invoice_Receipts_Tracker]
[TranProcessing].[RecordTypes]
[TollPlus].[AppTxnTypes] 
[TollPlus].[SubSystems]
[TollPlus].[TP_Customer_Business] 
[TollPlus].[TP_Customer_Plans]
[TollPlus].[Plans]
[FINANCE].[BulkPayments]
[TOLLPLUS].[BOS_IOP_INBOUNDTRANSACTIONS]
[TOLLPLUS].[COLLECTIONS_INBOUND]
[TOLLPLUS].[COLLECTIONS_OUTBOUND]
[TOLLPLUS].[TP_CUSTOMER_TAGS_HISTORY]
[TOLLPLUS].[TP_IMAGEREVIEW]
[TRANPROCESSING].[TSAImageRawTransactions]
'


EXEC #GET_CREATE_TABLES_BY_LIST @INCLUDE_TABLES


###################################################################################################################
*/


/*
###################################################################################################################
===================================================================================================================
Code Description: 
-------------------------------------------------------------------------------------------------------------------
This Code is to Insert or Update all infromation about the tables on Parameters. Run created script on APS
To use it on another database (IPS or DMV) - replace all 'TBOS' to 'IPS' or 'DMV' in the text
Make sure the table list is up to date
*******************************************************************************************************************
USE TBOS 
GO

SET NOCOUNT ON
GO

IF OBJECT_ID('tempdb..#GET_Service_INSERT_Table_SQL') IS NOT NULL DROP PROC #GET_Service_INSERT_Table_SQL
GO

CREATE PROC #GET_Service_INSERT_Table_SQL @TABLE_NAME [VARCHAR](100) AS
BEGIN
	--DECLARE @SQL_STRING VARCHAR(MAX) = ''
	DECLARE @SQL VARCHAR(MAX) = ''
	DECLARE @ROW_COUNT BIGINT = 0
	DECLARE @DataBaseName VARCHAR(30) = 'TBOS'

	SET @SQL = 'DECLARE @SQL_STRING VARCHAR(MAX)
	SELECT @SQL_STRING = ''EXEC Utility.TableLoadParameters_Insert ''''' + @DataBaseName + ''''',''''' + @TABLE_NAME + ''''', '' + CAST(COUNT_BIG(1) AS VARCHAR)
	FROM ' + @TABLE_NAME + '
	PRINT @SQL_STRING'

	EXEC (@SQL)

END
GO



IF OBJECT_ID('tempdb..#GET_CREATE_TABLES_BY_LIST') IS NOT NULL DROP PROC #GET_CREATE_TABLES_BY_LIST
GO
CREATE PROC #GET_CREATE_TABLES_BY_LIST @TABLE_LIST [VARCHAR](MAX) AS --,@SQL_STRING [VARCHAR](MAX) OUT AS
BEGIN

	DECLARE @NUM_OF_TABLES INT
	DECLARE @TABLE_NAME VARCHAR(100)

	IF OBJECT_ID('tempdb..#SCHEMA_TABLES') IS NOT NULL DROP TABLE #SCHEMA_TABLES;

	SELECT TableName,FULL_NAME,
			ROW_NUMBER() OVER(ORDER BY TableName) AS RN
	INTO #SCHEMA_TABLES
	FROM
		(
			SELECT      s.name + '.' +  t.name AS TableName, '[' + s.name + '].[' +  t.name + ']' AS FULL_NAME 
			FROM        sys.tables  t   
			JOIN		sys.schemas S	ON S.schema_id = t.schema_id
		) A
	WHERE CHARINDEX(A.FULL_NAME,@TABLE_LIST) > 0 OR CHARINDEX(A.TableName,@TABLE_LIST) > 0

	--SELECT * FROM #SCHEMA_TABLES

	SELECT @NUM_OF_TABLES = MAX(RN) FROM #SCHEMA_TABLES

	DECLARE @INDICAT SMALLINT = 1
	-- If only 1 period (and 1 partition) - @PART_RANGES is empty

	WHILE (@INDICAT <= @NUM_OF_TABLES)
	BEGIN
		
		SELECT @TABLE_NAME = FULL_NAME
		FROM #SCHEMA_TABLES M
		WHERE M.RN = @INDICAT --AND CHARINDEX(M.FULL_NAME,@EXCLUDE_TABLES) = 0
		
		IF @TABLE_NAME IS NOT NULL
		BEGIN
			EXEC #GET_Service_INSERT_Table_SQL @TABLE_NAME
		END
		SET @INDICAT += 1
	END

END
GO


DECLARE @INCLUDE_TABLES VARCHAR(MAX)

SET @INCLUDE_TABLES = '
[COURT].[AdminHearing]
[COURT].[Counties]
[COURT].[Courts]
[COURT].[PlazaCourts]
[CASEMANAGER].[PmCase]
[CASEMANAGER].[PmCaseTypes]
[TER].[PaymentPlans]
[TER].[PaymentPlanTerms]
[TER].[PaymentPlanViolator]
[TER].[HvStatusLookup]
[TER].[HabitualViolators]
[TER].[ViolatorCollectionsOutbound]
[TER].[VehicleRegBlocks]
[TER].[VRBRequestDMV]
[TER].[DPSBanActions]
[TER].[VehicleBan]
[TER].[BanActions]
[TER].[CitationNumberSequence]
[TER].[CollectionAgencies]
[TER].[CollectionAgencyCounties]
[TER].[FailuretoPayCitations]
[TER].[HVEligibleTransactions]
[TER].[ViolatorCollectionsAgencyTracker]
[TER].[ViolatorCollectionsInbound]
[FINANCE].[ADJUSTMENT_LINEITEMS]
[FINANCE].[ADJUSTMENTS]
[FINANCE].[CustomerPayments]
[FINANCE].[PAYMENTTXN_LINEITEMS]
[FINANCE].[PAYMENTTXNS]
[FINANCE].[REFUNDREQUESTS_QUEUE]
[NOTIFICATIONS].[CustomerNotificationQueue]
[NOTIFICATIONS].[ConfigAlertTypeAlertChannels]
[NOTIFICATIONS].[ALERTCHANNELS]
[NOTIFICATIONS].[ALERTTYPES]
[DOCMGR].[TP_CUSTOMER_OUTBOUNDCOMMUNICATIONS]
[TOLLPLUS].[REF_LOOKUPTYPECODES_HIERARCHY]
[TOLLPLUS].[INVOICE_HEADER]
[TOLLPLUS].[INVOICE_LINEITEMS]
[TOLLPLUS].[ICN]
[TOLLPLUS].[TP_BANKRUPTCY_FILING]
[TOLLPLUS].[TP_VIOLATEDTRIPS]
[TOLLPLUS].[TP_CUSTOMER_VEHICLES]
[TOLLPLUS].[TP_CUSTOMER_CONTACTS]
[TOLLPLUS].[TP_CUSTOMER_ATTRIBUTES]
[TOLLPLUS].[TP_CUSTOMER_ADDRESSES]
[TOLLPLUS].[TP_CUSTOMER_PHONES]
[TOLLPLUS].[TP_CUSTOMER_EMAILS]
[TOLLPLUS].[TP_CUSTOMER_BALANCES]
[TOLLPLUS].[TP_CUSTOMER_FLAGS]
[TOLLPLUS].[TP_CUSTOMER_INTERNAL_USERS]
[TOLLPLUS].[TP_CUSTOMER_TAGS]
[TOLLPLUS].[TP_CUSTOMER_TRIP_CHARGES_TRACKER]
[TOLLPLUS].[TP_CUSTOMER_TRIP_RECEIPTS_TRACKER]
[TOLLPLUS].[TP_CUSTOMER_VEHICLE_TAGS]
[TOLLPLUS].[TP_CUSTOMERS]
[TOLLPLUS].[TP_CUSTOMERTRIPS]
[TOLLPLUS].[TP_CUSTOMERTRIPSTATUSTRACKER]
[TOLLPLUS].[TP_TRIPS]
[TOLLPLUS].[TP_VEHICLE_MODELS]
[TOLLPLUS].[TP_VIOLATED_TRIP_CHARGES_TRACKER]
[TOLLPLUS].[TP_VIOLATED_TRIP_RECEIPTS_TRACKER]
[TOLLPLUS].[TP_VIOLATEDTRIPS]
[TOLLPLUS].[TP_VIOLATEDTRIPSTATUSTRACKER]
[TOLLPLUS].[TP_IMAGE_REVIEW_RESULT_IMAGES]
[TOLLPLUS].[TP_IMAGE_REVIEW_RESULTS]
[TOLLPLUS].[TP_EXEMPTED_PLATES]
[TOLLPLUS].[CustomerFlagReferenceLookup]
[TOLLPLUS].[MbsHeader]
[TOLLPLUS].[MbsInvoices]
[TOLLPLUS].[InvoiceAttributes]
[TOLLPLUS].[BankruptcyStatuses]
[TOLLPLUS].[AddressSources]
[TOLLPLUS].[AGENCIES]
[TOLLPLUS].[CaseLinks]
[TOLLPLUS].[Dispositions]
[TOLLPLUS].[DMVExceptionDetails]
[TOLLPLUS].[DMVExceptionQueue]
[TOLLPLUS].[ESCHEATMENT_ELGIBLE_CUSTOMERS]
[TOLLPLUS].[FleetCustomerAttributes]
[TOLLPLUS].[FleetCustomersFileTracker]
[TOLLPLUS].[FleetCustomerVehiclesQueue]
[TOLLPLUS].[ICN_CASH]
[TOLLPLUS].[ICN_ITEMS]
[TOLLPLUS].[ICN_TXNS]
[TOLLPLUS].[ICN_VARIANCE]
[TOLLPLUS].[INVOICE_CHARGES_TRACKER]
[TOLLPLUS].[LANES]
[TOLLPLUS].[LOCATIONS]
[TOLLPLUS].[PLAZA_TYPES]
[TOLLPLUS].[PLAZAS]
[TOLLPLUS].[REF_INVOICE_WORKFLOW_STAGE_FEES]
[TOLLPLUS].[REF_INVOICE_WORKFLOW_STAGES]
[TOLLPLUS].[TRIPSTAGES]
[TOLLPLUS].[TRIPSTATUSES]
[TOLLPLUS].[TXNTYPE_CATEGORIES]
[TOLLPLUS].[UnMatchedTxnsQueue]
[TOLLPLUS].[VEHICLECLASSES]
[TOLLPLUS].[VIOLATION_WORKFLOW]
[TOLLPLUS].[ZipCodes]
[TOLLPLUS].[TP_EXEMPTED_PLATES]
[Court].[CourtJudges]
[Finance].[BANKPAYMENTS]
[Finance].[CHEQUEPAYMENTS]
[IOP].[AGENCIES]
[TollPlus].[REF_FEETYPES]
[Finance].[GL_TXN_LINEITEMS]
[Inventory].[ITEMINVENTORY]
[Inventory].[ITEMINVENTORYLOCATIONS]
[Inventory].[ITEMTYPES]
[IOP].[BOS_IOP_OUTBOUNDTRANSACTIONS]
[IOP].[IopPlates]
[IOP].[IopTags]
[Parking].[ParkingTrips]
[TER].[DPSTrooper]
[TollPlus].[TpFileTracker]
[TollPlus].[LaneCategories]
[Finance].[Adjustments]
[TollPlus].[PlateTypes]
[TollPlus].[TP_TRANSACTION_TYPES]
[TollPlus].[TP_TOLLTXN_REASONCODES]
[TOLLPLUS].[Channels]
[TOLLPLUS].[TP_Transaction_Types]
[TranProcessing].[HostBosFileTracker]
[TranProcessing].[IOPInboundRawTransactions]
[TranProcessing].[NTTAHostBOSFileTracker]
[TranProcessing].[NTTARawTransactions]
[TranProcessing].[TripSource]
[TranProcessing].[TSARawTransactions]
[TranProcessing].[TxnDispositions]
[Finance].[BusInessProcess_TxnTypes_Associations]
[Finance].[BusinessProcesses]
[Finance].[CharTofAccounts]
[Finance].[GL_Transactions]
[Finance].[TxnTypes]
[Finance].[GlDailySummaryByCoaIdBuId]
[TER].[HabitualViolatorStatusTracker]
[TER].[VRBRequestDallas]
[TollPlus].[MbsProcessStatus]
[TollPlus].[Merged_Customers]
[TollPlus].[OperationalLocations]
[TollPlus].[TP_AppLication_Parameters]
[TollPlus].[TP_Customer_AccStatus_Tracker]
[TollPlus].[TP_CustTxns]
[TollPlus].[TP_FileTracker]
[TollPlus].[TP_Invoice_Receipts_Tracker]
[TranProcessing].[RecordTypes]
[TollPlus].[AppTxnTypes] 
[TollPlus].[SubSystems]
[TollPlus].[TP_Customer_Business] 
[TollPlus].[TP_Customer_Plans]
[TollPlus].[Plans]
[FINANCE].[BulkPayments]
[TOLLPLUS].[BOS_IOP_INBOUNDTRANSACTIONS]
[TOLLPLUS].[COLLECTIONS_INBOUND]
[TOLLPLUS].[COLLECTIONS_OUTBOUND]
[TOLLPLUS].[TP_CUSTOMER_TAGS_HISTORY]
[TOLLPLUS].[TP_IMAGEREVIEW]
[TRANPROCESSING].[TSAImageRawTransactions]
'


EXEC #GET_CREATE_TABLES_BY_LIST @INCLUDE_TABLES


###################################################################################################################
*/

/*
###################################################################################################################
===================================================================================================================
Code Description: 
-------------------------------------------------------------------------------------------------------------------
This Code is to Insert or Update all infromation about the tables on Parameters. Run created script on APS
To use it on another database (IPS or DMV) - replace all 'TBOS' to 'IPS' or 'DMV' in the text
Make sure the table list is up to date
*******************************************************************************************************************
USE IPS 
GO

SET NOCOUNT ON
GO

IF OBJECT_ID('tempdb..#GET_Service_INSERT_Table_SQL') IS NOT NULL DROP PROC #GET_Service_INSERT_Table_SQL
GO

CREATE PROC #GET_Service_INSERT_Table_SQL @TABLE_NAME [VARCHAR](100) AS
BEGIN
	--DECLARE @SQL_STRING VARCHAR(MAX) = ''
	DECLARE @SQL VARCHAR(MAX) = ''
	DECLARE @ROW_COUNT BIGINT = 0
	DECLARE @DataBaseName VARCHAR(30) = 'IPS'

	SET @SQL = 'DECLARE @SQL_STRING VARCHAR(MAX)
	SELECT @SQL_STRING = ''EXEC Utility.TableLoadParameters_Insert ''''' + @DataBaseName + ''''',''''' + @TABLE_NAME + ''''', '' + CAST(COUNT_BIG(1) AS VARCHAR)
	FROM ' + @TABLE_NAME + '
	PRINT @SQL_STRING'

	EXEC (@SQL)

END
GO


IF OBJECT_ID('tempdb..#GET_CREATE_TABLES_BY_LIST') IS NOT NULL DROP PROC #GET_CREATE_TABLES_BY_LIST
GO
CREATE PROC #GET_CREATE_TABLES_BY_LIST @TABLE_LIST [VARCHAR](MAX) AS --,@SQL_STRING [VARCHAR](MAX) OUT AS
BEGIN

	DECLARE @NUM_OF_TABLES INT
	DECLARE @TABLE_NAME VARCHAR(100)

	IF OBJECT_ID('tempdb..#SCHEMA_TABLES') IS NOT NULL DROP TABLE #SCHEMA_TABLES;

	SELECT TableName,FULL_NAME,
			ROW_NUMBER() OVER(ORDER BY TableName) AS RN
	INTO #SCHEMA_TABLES
	FROM
		(
			SELECT      s.name + '.' +  t.name AS TableName, '[' + s.name + '].[' +  t.name + ']' AS FULL_NAME 
			FROM        sys.tables  t   
			JOIN		sys.schemas S	ON S.schema_id = t.schema_id
		) A
	WHERE CHARINDEX(A.FULL_NAME,@TABLE_LIST) > 0 OR CHARINDEX(A.TableName,@TABLE_LIST) > 0

	--SELECT * FROM #SCHEMA_TABLES

	SELECT @NUM_OF_TABLES = MAX(RN) FROM #SCHEMA_TABLES

	DECLARE @INDICAT SMALLINT = 1
	-- If only 1 period (and 1 partition) - @PART_RANGES is empty

	WHILE (@INDICAT <= @NUM_OF_TABLES)
	BEGIN
		
		SELECT @TABLE_NAME = FULL_NAME
		FROM #SCHEMA_TABLES M
		WHERE M.RN = @INDICAT --AND CHARINDEX(M.FULL_NAME,@EXCLUDE_TABLES) = 0
		
		IF @TABLE_NAME IS NOT NULL
		BEGIN
			EXEC #GET_Service_INSERT_Table_SQL @TABLE_NAME
		END
		SET @INDICAT += 1
	END

END
GO


DECLARE @INCLUDE_TABLES VARCHAR(MAX)

SET @INCLUDE_TABLES = '
[EIP].[inboundfiletracker]
[EIP].[imagefiletracker]
[eip].[request_tracker]
[eip].[transactions]
[eip].[vehicleimages]
[eip].[ocrresults]
[mir].[mir_workqueue_stage]
[mir].[mir_transactions]
[eip].[results_log]
[mir].[txnstages]
[mir].[txnstagetypes]
[mir].[txnstatuses]
[mir].[mst_dispositioncodes]
[mir].[reasoncodes]
[mir].[mst_sourcetypes]
[mir].[mst_responsetypes]
[eip].[image_storage_paths]
[mir].[txnqueues]
[mir].[txnstageshistory]
[mir].[txnstagetypeshistory]
[mir].[txnstatuseshistory]
[mir].[reasoncodeshistory]
[EIP].[Audit_Summary]
[EIP].[AuditTracker]
[EIP].[AuditTransactions]
[EIP].[AuditTypes]
[MIR].[Transaction_InputLog]
[MIR].[MST_TransactionTypes]
'
EXEC #GET_CREATE_TABLES_BY_LIST @INCLUDE_TABLES

###################################################################################################################
*/

/*
###################################################################################################################
===================================================================================================================
Code Description: 
-------------------------------------------------------------------------------------------------------------------
This Code is to Insert or Update all infromation about the tables on Parameters. Run created script on APS
To use it on another database (IPS or DMV) - replace all 'TBOS' to 'IPS' or 'DMV' in the text
Make sure the table list is up to date
*******************************************************************************************************************
USE DMV 
GO

SET NOCOUNT ON
GO

IF OBJECT_ID('tempdb..#GET_Service_INSERT_Table_SQL') IS NOT NULL DROP PROC #GET_Service_INSERT_Table_SQL
GO

CREATE PROC #GET_Service_INSERT_Table_SQL @TABLE_NAME [VARCHAR](100) AS
BEGIN
	--DECLARE @SQL_STRING VARCHAR(MAX) = ''
	DECLARE @SQL VARCHAR(MAX) = ''
	DECLARE @ROW_COUNT BIGINT = 0
	DECLARE @DataBaseName VARCHAR(30) = 'DMV'

	SET @SQL = 'DECLARE @SQL_STRING VARCHAR(MAX)
	SELECT @SQL_STRING = ''EXEC Utility.TableLoadParameters_Insert ''''' + @DataBaseName + ''''',''''' + @TABLE_NAME + ''''', '' + CAST(COUNT_BIG(1) AS VARCHAR)
	FROM ' + @TABLE_NAME + '
	PRINT @SQL_STRING'

	EXEC (@SQL)

END
GO


IF OBJECT_ID('tempdb..#GET_CREATE_TABLES_BY_LIST') IS NOT NULL DROP PROC #GET_CREATE_TABLES_BY_LIST
GO
CREATE PROC #GET_CREATE_TABLES_BY_LIST @TABLE_LIST [VARCHAR](MAX) AS --,@SQL_STRING [VARCHAR](MAX) OUT AS
BEGIN

	DECLARE @NUM_OF_TABLES INT
	DECLARE @TABLE_NAME VARCHAR(100)

	IF OBJECT_ID('tempdb..#SCHEMA_TABLES') IS NOT NULL DROP TABLE #SCHEMA_TABLES;

	SELECT TableName,FULL_NAME,
			ROW_NUMBER() OVER(ORDER BY TableName) AS RN
	INTO #SCHEMA_TABLES
	FROM
		(
			SELECT      s.name + '.' +  t.name AS TableName, '[' + s.name + '].[' +  t.name + ']' AS FULL_NAME 
			FROM        sys.views  t   
			JOIN		sys.schemas S	ON S.schema_id = t.schema_id
		) A
	WHERE CHARINDEX(A.FULL_NAME,@TABLE_LIST) > 0 OR CHARINDEX(A.TableName,@TABLE_LIST) > 0

	--SELECT * FROM #SCHEMA_TABLES

	SELECT @NUM_OF_TABLES = MAX(RN) FROM #SCHEMA_TABLES

	DECLARE @INDICAT SMALLINT = 1
	-- If only 1 period (and 1 partition) - @PART_RANGES is empty

	WHILE (@INDICAT <= @NUM_OF_TABLES)
	BEGIN
		
		SELECT @TABLE_NAME = FULL_NAME
		FROM #SCHEMA_TABLES M
		WHERE M.RN = @INDICAT --AND CHARINDEX(M.FULL_NAME,@EXCLUDE_TABLES) = 0
		
		IF @TABLE_NAME IS NOT NULL
		BEGIN
			EXEC #GET_Service_INSERT_Table_SQL @TABLE_NAME
		END
		SET @INDICAT += 1
	END

END
GO


DECLARE @INCLUDE_TABLES VARCHAR(MAX)

SET @INCLUDE_TABLES = '
[Dmv].[eTagPlates]
[Dmv].[HardLicensePlates]'
EXEC #GET_CREATE_TABLES_BY_LIST @INCLUDE_TABLES

###################################################################################################################
*/



/*
###################################################################################################################
===================================================================================================================
Code Description: 
-------------------------------------------------------------------------------------------------------------------
This Code is to create a new table on APS (delete the previous version if exists. Run created script on APS
*******************************************************************************************************************
USE TBOS 
GO

SET NOCOUNT ON
GO

IF OBJECT_ID('tempdb..#uf_TitleCase') IS NOT NULL DROP PROC #uf_TitleCase
GO

CREATE PROC #uf_TitleCase @Text [Varchar](8000), @Ret Varchar(8000) OUT 
AS
Begin  

	Declare @Reset Bit = 1;
	DECLARE @i Int = 2; -- Start checking from 2-nd letter - first should be title
	Declare @c Char(1);
	SET @Ret = '';

	If @Text Is Null
		Return -1;

	DECLARE @IsT BIT = 0;
	WHILE (@i <= Len(@Text))
	Begin
		Set @c = Substring(@Text, @i, 1)
		IF (ASCII(@c) BETWEEN 97 AND 122) SET @IsT = 1

		SET @i = @i + 1

		IF @IsT = 1 BREAK

	END


	IF @IsT = 0
		SET @Text = LOWER(@Text)

	SET @i = 1;

	While (@i <= Len(@Text))
	Begin
		Set @c = Substring(@Text, @i, 1)
		Set @Ret = @Ret + Case When @Reset = 1 Then Upper(@c) Else Lower(@c) End
		Set @Reset = Case When @c Like '[a-z]' Then 0 Else 1 End
		Set @i = @i + 1
	End

	SET @Ret = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@Ret,
		'By','By'),'HV','HV'),'ID','ID'),'In','In'),'Is','Is'),'No','No'),'Of','Of'),'Or','Or'),'PK','PK'),'To','To'),'Acc','Acc'),'Act','Act'),'Add','Add'),'Adj','Adj'),'AIP','AIP'),'Amt','Amt'),'And','And'),'Bad','Bad'),'Ban','Ban'),'BOS','BOS'),'Cnt','Cnt'),'CSV','CSV'),'Cut','Cut'),'Day','Day'),'DMV','DMV'),'DPS','DPS'),'Due','Due'),'EIP','EIP'),'End','End'),'Enh','Enh'),'Fee','Fee'),'FK_','FK_'),'FTP','FTP'),'Hex','Hex'),'ICN','ICN'),'IDX','IDX'),'Img','Img'),'INX','INX'),'IOP','IOP'),'IPS','IPS'),'IX_','IX_'),'Key','Key'),'Lic','Lic'),'Log','Log'),'Map','Map'),'MIR','MIR'),'New','New'),'NNP','NNP'),'Non','Non'),'Num','Num'),'OCR','OCR'),'Out','Out'),'Own','Own'),'Pay','Pay'),'PBM','PBM'),'Raw','Raw'),'Ref','Ref'),'Reg','Reg'),'Rev','Rev'),'ROI','ROI'),'Seq','Seq'),'Sig','Sig'),'SSN','SSN'),'Tag','Tag'),'Tax','Tax'),'Top','Top'),'TP_','TP_'),'TSA','TSA'),'Txn','Txn'),'UQ_','UQ_'),'UTC','UTC'),'VCF','VCF'),'VIN','VIN'),'VIP','VIP'),'VRB','VRB'),'VSR','VSR'),'Web','Web'),'Zip','Zip'),'ALPR','ALPR'),'Attr','Attr'),'Auto','Auto'),'Axle','Axle'),'Bill','Bill'),'Body','Body'),'Call','Call'),'Case','Case'),'Cash','Cash'),'City','City'),'Clos','Clos'),'Code','Code'),'Coll','Coll'),'Comm','Comm'),'Cust','Cust'),'Data','Data'),'Date','Date'),'Desc','Desc'),'Down','Down'),'Driv','Driv'),'Effe','Effe'),'Exit','Exit'),'File','File'),'Flag','Flag'),'Hist','Hist'),'Hold','Hold'),'Home','Home'),'Host','Host'),'Info','Info'),'Item','Item'),'JSON','JSON'),'Lane','Lane'),'Last','Last'),'Left','Left'),'Line','Line'),'List','List'),'Load','Load'),'Look','Look'),'Mail','Mail'),'Main','Main'),'Make','Make'),'Mark','Mark'),'Mode','Mode'),'MST_','MST_'),'Name','Name'),'NIX_','NIX_'),'Note','Note'),'NTTA','NTTA'),'Paid','Paid'),'Path','Path'),'Phon','Phon'),'Plan','Plan'),'Plus','Plus'),'Port','Port'),'Post','Post'),'Prev','Prev'),'Quer','Quer'),'Rate','Rate'),'Read','Read'),'Role','Role'),'Self','Self'),'Send','Send'),'Sent','Sent'),'Ship','Ship'),'Size','Size'),'Step','Step'),'Term','Term'),'Time','Time'),'Toll','Toll'),'Tran','Tran'),'Trip','Trip'),'Type','Type'),'User','User'),'With','With'),'Work','Work'),'Year','Year'),'Activ','Activ'),'Admin','Admin'),'Agenc','Agenc'),'Alert','Alert'),'Alias','Alias'),'Batch','Batch'),'Blind','Blind'),'Block','Block'),'Check','Check'),'Citat','Citat'),'Class','Class'),'Color','Color'),'Count','Count'),'Court','Court'),'Creat','Creat'),'Cycle','Cycle'),'Email','Email'),'Entry','Entry'),'Error','Error'),'Event','Event'),'Expir','Expir'),'First','First'),'Float','Float'),'Group','Group'),'Horiz','Horiz'),'Ident','Ident'),'Image','Image'),'Index','Index'),'Langu','Langu'),'Major','Major'),'Match','Match'),'Minor','Minor'),'Modif','Modif'),'Plate','Plate'),'Plaza','Plaza'),'Print','Print'),'Prior','Prior'),'Purch','Purch'),'Queue','Queue'),'Raise','Raise'),'Right','Right'),'Setup','Setup'),'Shift','Shift'),'Short','Short'),'Speed','Speed'),'Spons','Spons'),'Stage','Stage'),
		'Stand','Stand'),'Start','Start'),'STAT_','STAT_'),'State','State'),'Style','Style'),'Super','Super'),'Surve','Surve'),'Table','Table'),'Title','Title'),'TxDot','TxDot'),'Updat','Updat'),'Usage','Usage'),'Valid','Valid'),'Value','Value'),'Verif','Verif'),'Video','Video'),'VToll','VToll'),'Waive','Waive'),'Write','Write'),'Action','Action'),'Amount','Amount'),'Appear','Appear'),'Approv','Approv'),'Assign','Assign'),'Bottom','Bottom'),'Bright','Bright'),'Calcul','Calcul'),'Change','Change'),'Charge','Charge'),'Confid','Confid'),'Config','Config'),'Credit','Credit'),'Detail','Detail'),'Direct','Direct'),'DocMgr','DocMgr'),'Enable','Enable'),'Ground','Ground'),'Handle','Handle'),'Header','Header'),'Height','Height'),'Histor','Histor'),'Invoic','Invoic'),'Length','Length'),'Letter','Letter'),'Manual','Manual'),'Messag','Messag'),'Method','Method'),'Middle','Middle'),'Normal','Normal'),'Option','Option'),'Parent','Parent'),'Period','Period'),'Portal','Portal'),'Prefer','Prefer'),'Prefix','Prefix'),'Primar','Primar'),'Protec','Protec'),'Qualif','Qualif'),'Reason','Reason'),'Rebill','Rebill'),'Record','Record'),'Reject','Reject'),'Remain','Remain'),'Remark','Remark'),'Renter','Renter'),'Report','Report'),'Result','Result'),'Retail','Retail'),'Return','Return'),'Review','Review'),'Serial','Serial'),'Source','Source'),'Status','Status'),'Street','Street'),'Submit','Submit'),'Suffix','Suffix'),'Syntax','Syntax'),'System','System'),'Unread','Unread'),'Upload','Upload'),'Violat','Violat'),'Volume','Volume'),'Account','Account'),'Balance','Balance'),'Carrier','Carrier'),'Categor','Categor'),'Channel','Channel'),'Complet','Complet'),'Consume','Consume'),'Contact','Contact'),'Correct','Correct'),'Default','Default'),'Deliver','Deliver'),'Deposit','Deposit'),'Dismiss','Dismiss'),'Display','Display'),'Facilit','Facilit'),'Frequen','Frequen'),'Generat','Generat'),'Hearing','Hearing'),'Inbound','Inbound'),'Indicat','Indicat'),'Invalid','Invalid'),'Mailing','Mailing'),'Malform','Malform'),'Manager','Manager'),'Misread','Misread'),'Notific','Notific'),'Parking','Parking'),'Pending','Pending'),'Premium','Premium'),'Process','Process'),'Receipt','Receipt'),'Receive','Receive'),'Renewal','Renewal'),'Replace','Replace'),'Request','Request'),'Require','Require'),'Resolve','Resolve'),'Service','Service'),'Sponsor','Sponsor'),'Storage','Storage'),'Summary','Summary'),'Tracker','Tracker'),'Trigger','Trigger'),'Trooper','Trooper'),'Unmatch','Unmatch'),'Vehicle','Vehicle'),'Visible','Visible'),'Authorit','Authorit'),'Conflict','Conflict'),'Contrast','Contrast'),'Decision','Decision'),'Discount','Discount'),'Download','Download'),'Eligible','Eligible'),'Inventor','Inventor'),'Loaction','Loaction'),'Location','Location'),'Metadata','Metadata'),'Normalis','Normalis'),'Position','Position'),'Response','Response'),'Sequence','Sequence'),'Template','Template'),'Terminat','Terminat'),'Vertical','Vertical'),
		'Affidavit','Affidavit'),'Determina','Determina'),'Exception','Exception'),'Excessive','Excessive'),'Registrat','Registrat'),'Signature','Signature'),'Subscribe','Subscribe'),'Surrender','Surrender'),'Telephone','Telephone'),'Threshold','Threshold'),'Bankruptcy','Bankruptcy'),'Correspond','Correspond'),'Processing','Processing'),'Disposition','Disposition'),'Outstanding','Outstanding'),'Transaction','Transaction'),'Jurisdiction','Jurisdiction'),'Representativ','Representativ')

	Return 0

End
GO


IF OBJECT_ID('tempdb..#PRINT_LONG_VARIABLE_VALUE') IS NOT NULL DROP PROC #PRINT_LONG_VARIABLE_VALUE
GO

CREATE PROC #PRINT_LONG_VARIABLE_VALUE @sql [VARCHAR](MAX) AS
BEGIN
	DECLARE @ST_R INT = 0
	DECLARE @CUT_LEN INT = 8000
	DECLARE @CUT_R INT = @CUT_LEN
	DECLARE @SQL_PART VARCHAR(8000)
	DECLARE @LONG INT = LEN(@sql)
	DECLARE @SQL_PART_REV VARCHAR(MAX)
	DECLARE @LAST_ENTER_SYMBOL_NBR INT

	WHILE (@ST_R <= @LONG)
	BEGIN
		SET @SQL_PART = SUBSTRING(@sql, @ST_R, @CUT_LEN)
		SET @CUT_R = LEN(@SQL_PART) 
		-- Every time we print something - it prints on the next row
		-- it means, if we stopped in the middle of the row the next part of this row will be on the next row - we don't want this

		IF @ST_R + @CUT_LEN < @LONG -- it does not metter if this is the last part
		BEGIN
			SET @SQL_PART_REV = REVERSE(@SQL_PART)

			-- We are looking for the last "ENTER" symbol in our string part and cutting out everything after this - it will go to the next part
			-- To find it better to reverse the string
			SET @LAST_ENTER_SYMBOL_NBR = CHARINDEX(CHAR(13),@SQL_PART_REV)

			IF @LAST_ENTER_SYMBOL_NBR > 0
			BEGIN
				SET @SQL_PART = LEFT(@SQL_PART, @CUT_R - @LAST_ENTER_SYMBOL_NBR)
				-- Now should set a new length of the string part plus Enter symbol we don't want to have again
				SET @CUT_R = @CUT_R - @LAST_ENTER_SYMBOL_NBR + 1
			END
		END

		PRINT @SQL_PART
		-- Set beginning of the next part as the last part beginning + length of string part + next sybmol (+1) 
		SET @ST_R = @ST_R + @CUT_R + 1
	END
END
GO

IF OBJECT_ID('tempdb..#GET_INDEX_STRING') IS NOT NULL DROP PROC #GET_INDEX_STRING
GO
CREATE PROC #GET_INDEX_STRING @SCHEMA_NAME [VARCHAR](100), @TABLE [VARCHAR](100),@SQL_STRING [VARCHAR](MAX) OUT AS

BEGIN
	DECLARE @TABLE_INDEX VARCHAR(100)

	SELECT @TABLE_INDEX = I.type_desc
	FROM sys.tables as t
	JOIN sys.indexes AS I ON I.object_id = t.object_id
	WHERE t.name = @TABLE AND I.index_id <=1

	IF @TABLE_INDEX = 'CLUSTERED'
	BEGIN
		WITH CTE AS
		(
			SELECT C.column_id, u.name AS column_name, CASE WHEN C.is_descending_key = 1 THEN ' DESC' ELSE ' ASC' END AS column_Order
				, ROW_NUMBER() OVER (ORDER BY C.column_id) AS RN 
			FROM sys.tables as t
			JOIN sys.schemas as S ON S.SCHEMA_ID = t.SCHEMA_ID AND S.name = @SCHEMA_NAME
			JOIN sys.indexes AS I ON I.object_id = t.object_id AND I.index_id <=1
			JOIN sys.index_columns AS C ON C.object_id = t.object_id AND C.index_id = I.index_id
			JOIN sys.columns AS u ON u.column_id = C.column_id AND u.object_id = t.object_id
			WHERE t.name = @TABLE
		)
		, CTE_JOINT AS 
		(
			SELECT
				' [' + CTE1.column_name + ']' AS INDEX_1st_COLUMN
				, ' [' + CTE1.column_name + ']' + CTE1.column_Order
				+ ISNULL(', ['+ CTE2.column_name + ']' + CTE2.column_Order, '')
				+ ISNULL(', ['+ CTE3.column_name + ']' + CTE3.column_Order, '')
				+ ISNULL(', ['+ CTE4.column_name + ']' + CTE4.column_Order, '')
				+ ISNULL(', ['+ CTE5.column_name + ']' + CTE5.column_Order, '')
				+ ISNULL(', ['+ CTE6.column_name + ']' + CTE6.column_Order, '')
				+ ISNULL(', ['+ CTE7.column_name + ']' + CTE7.column_Order, '')
				+ ISNULL(', ['+ CTE8.column_name + ']' + CTE8.column_Order, '')
				+ ISNULL(', ['+ CTE9.column_name + ']' + CTE9.column_Order, '')
				+ ISNULL(', ['+ CTE10.column_name + ']' + CTE10.column_Order, '') + ' ' AS INDEX_COULUMNS
			FROM CTE AS CTE1
			LEFT JOIN CTE AS CTE2 ON  CTE2.RN = 2
			LEFT JOIN CTE AS CTE3 ON  CTE3.RN = 3
			LEFT JOIN CTE AS CTE4 ON  CTE4.RN = 4
			LEFT JOIN CTE AS CTE5 ON  CTE5.RN = 5
			LEFT JOIN CTE AS CTE6 ON  CTE6.RN = 6
			LEFT JOIN CTE AS CTE7 ON  CTE7.RN = 7
			LEFT JOIN CTE AS CTE8 ON  CTE8.RN = 8
			LEFT JOIN CTE AS CTE9 ON  CTE9.RN = 9
			LEFT JOIN CTE AS CTE10 ON CTE10.RN = 10
			WHERE CTE1.RN = 1
		)
		SELECT TOP 1
			@SQL_STRING = @TABLE_INDEX + ' INDEX (' + INDEX_COULUMNS + '), DISTRIBUTION = HASH(' + INDEX_1st_COLUMN + ')'
		FROM CTE_JOINT
	END
	ELSE
	BEGIN
		IF @TABLE_INDEX = 'CLUSTERED COLUMNSTORE'
		BEGIN
			SET @SQL_STRING = @TABLE_INDEX + ' INDEX, DISTRIBUTION = ROUND_ROBIN'
		END
		ELSE
		BEGIN
			SET @SQL_STRING = @TABLE_INDEX
		END
		--WITH (CLUSTERED INDEX ( [ACCT_ID] ASC , [ACCT_TAG_SEQ] ASC ), DISTRIBUTION = HASH([ACCT_ID]));
	END
END
GO

IF OBJECT_ID('tempdb..#GET_CREATE_STATISTICS_SQL') IS NOT NULL DROP PROC #GET_CREATE_STATISTICS_SQL
GO
CREATE PROC #GET_CREATE_STATISTICS_SQL @SCHEMA_NAME [VARCHAR](100), @TABLE [VARCHAR](100),@SQL_STRING [VARCHAR](MAX) OUT AS
BEGIN
	--DECLARE @SCHEMA_NAME [VARCHAR](100) = 'TollPlus', @TABLE [VARCHAR](100) = 'Tp_Customer_Balances', @SQL_STRING [VARCHAR](MAX)
	
	IF OBJECT_ID('TempDB..#TABLE_STATS') IS NOT NULL DROP TABLE #TABLE_STATS;


	WITH CTE AS
	(
		-- Statistic for foreign key
		SELECT 
			s.[name] AS schemaName, 
			OBJECT_NAME(A.PARENT_OBJECT_ID) AS [table_name], 
			'STAT_' + F.name AS [stats_name], 
			B.name AS [column_name], 
			ROW_NUMBER() OVER (PARTITION BY F.name ORDER BY b.column_id) AS RN
		FROM SYS.FOREIGN_KEY_COLUMNS A 
		JOIN sys.foreign_keys f on f.object_id = a.constraint_object_id
		JOIN sys.schemas S	ON S.schema_id = f.schema_id AND S.name = @SCHEMA_NAME
		JOIN SYS.COLUMNS B ON A.PARENT_COLUMN_ID = B.COLUMN_ID 
			AND A.PARENT_OBJECT_ID = B.OBJECT_ID 
		WHERE OBJECT_NAME(A.PARENT_OBJECT_ID) = @TABLE

		UNION ALL

		-- Statistics for nonclustered indexes - instead of create indexes
		SELECT 
			s.[name] AS schemaName, 
			t.name AS [table_name], 
			'STAT_' + I.name AS [stats_name], 
			u.name AS column_name,
			ROW_NUMBER() OVER (PARTITION BY I.name ORDER BY C.column_id) AS RN 
		FROM sys.tables as t
		JOIN sys.schemas as S ON S.SCHEMA_ID = t.SCHEMA_ID AND S.name = @SCHEMA_NAME
		JOIN sys.indexes AS I ON I.object_id = t.object_id AND I.index_id > 1
		JOIN sys.index_columns AS C ON C.object_id = t.object_id AND C.index_id = I.index_id
		JOIN sys.columns AS u ON u.column_id = C.column_id AND u.object_id = t.object_id
		WHERE t.name = @TABLE

		UNION ALL

		-- User-created stats
		SELECT
			s.[name] AS schemaName
			,t.[name] AS [table_name]
			,'STAT_' + ss.[name] AS [stats_name]
			,c.name AS [column_name]
			, ROW_NUMBER() OVER (PARTITION BY ss.[name] ORDER BY C.column_id) AS RN 
		FROM        sys.schemas s
		JOIN        sys.tables t                    ON      t.[schema_id]  = s.[schema_id]
		JOIN		sys.stats ss					ON		ss.[object_id] = t.[object_id] AND ss.user_created = 1
		JOIN		sys.stats_columns sc			ON		sc.[object_id] = t.[object_id] AND ss.stats_id = sc.stats_id
		JOIN        sys.columns c                   ON      t.[object_id]  = c.[object_id] AND sc.column_id  = c.column_id
		WHERE  t.[name] = @TABLE
	)
	, CTE_JOINT AS 
	(
		SELECT 
			CTE1.schemaName
			,CTE1.table_name
			,CTE1.stats_name
			, '[' + CTE1.column_name + ']'
			+ ISNULL(', ['+ CTE2.column_name + ']', '')
			+ ISNULL(', ['+ CTE3.column_name + ']', '')
			+ ISNULL(', ['+ CTE4.column_name + ']', '')
			+ ISNULL(', ['+ CTE5.column_name + ']', '')
			+ ISNULL(', ['+ CTE6.column_name + ']', '')
			+ ISNULL(', ['+ CTE7.column_name + ']', '')
			+ ISNULL(', ['+ CTE8.column_name + ']', '')
			+ ISNULL(', ['+ CTE9.column_name + ']', '')
			+ ISNULL(', ['+ CTE10.column_name + ']', '') AS stats_col 
		FROM CTE AS CTE1
		LEFT JOIN CTE AS CTE2 ON CTE2.stats_name = CTE1.stats_name AND CTE2.RN = 2
		LEFT JOIN CTE AS CTE3 ON CTE3.stats_name = CTE1.stats_name AND CTE3.RN = 3
		LEFT JOIN CTE AS CTE4 ON CTE4.stats_name = CTE1.stats_name AND CTE4.RN = 4
		LEFT JOIN CTE AS CTE5 ON CTE5.stats_name = CTE1.stats_name AND CTE5.RN = 5
		LEFT JOIN CTE AS CTE6 ON CTE6.stats_name = CTE1.stats_name AND CTE6.RN = 6
		LEFT JOIN CTE AS CTE7 ON CTE7.stats_name = CTE1.stats_name AND CTE7.RN = 7
		LEFT JOIN CTE AS CTE8 ON CTE8.stats_name = CTE1.stats_name AND CTE8.RN = 8
		LEFT JOIN CTE AS CTE9 ON CTE9.stats_name = CTE1.stats_name AND CTE9.RN = 9
		LEFT JOIN CTE AS CTE10 ON CTE10.stats_name = CTE1.stats_name AND CTE10.RN = 10
		WHERE CTE1.RN = 1
	)
	SELECT 
			schemaName
			,table_name
			,stats_name
			,stats_col
			,'CREATE STATISTICS [' + stats_name + '] ON ' + @SCHEMA_NAME + '.[' + @TABLE + '] (' + stats_col + ');' AS SQL_STRING
			, ROW_NUMBER() OVER(ORDER BY stats_name) AS RN
	INTO #TABLE_STATS
	FROM CTE_JOINT

	--SELECT * FROM #TABLE_STATS

	DECLARE @NUM_OF_COLUMNS INT
	DECLARE @THIS_SQL_STRING VARCHAR(MAX) = '', @Title_SQL_String VARCHAR(MAX) = ''
	DECLARE @INDICAT SMALLINT = 1

	SET @SQL_STRING  = ''

	SELECT @NUM_OF_COLUMNS = MAX(RN) FROM #TABLE_STATS
	SET @INDICAT = 1
	-- If only 1 period (and 1 partition) - @PART_RANGES is empty
	WHILE (@INDICAT <= @NUM_OF_COLUMNS)
	BEGIN
		
		SELECT @THIS_SQL_STRING = SQL_STRING FROM #TABLE_STATS WHERE RN = @INDICAT --ORDER BY stats_name
		EXEC #uf_TitleCase @THIS_SQL_STRING, @Title_SQL_String OUTPUT

		SET @SQL_STRING = @SQL_STRING + char(13) + char(9) + REPLACE(REPLACE(@Title_SQL_String,'CREATE STATISTICS','CREATE STATISTICS'), ' ON ', ' ON ')

		SET @INDICAT += 1

	END

	--PRINT @SQL_STRING
END
go

IF OBJECT_ID('tempdb..#GET_CREATE_TABLE_SQL') IS NOT NULL DROP PROC #GET_CREATE_TABLE_SQL
GO
CREATE PROC #GET_CREATE_TABLE_SQL @SCHEMA_NAME [VARCHAR](100), @TABLE_NAME [VARCHAR](100) AS 

BEGIN

	DECLARE @SQL_STRING VARCHAR(MAX) = '';
	DECLARE @TitleTableName VARCHAR(100)
	DECLARE @TitleSchemaName VARCHAR(100)
	EXEC #uf_TitleCase @TABLE_NAME, @TitleTableName OUTPUT
	EXEC #uf_TitleCase @SCHEMA_NAME, @TitleSchemaName OUTPUT
	SELECT @TitleSchemaName = REPLACE(@TitleSchemaName,'TER','TER')

	DECLARE @NUM_OF_COLUMNS INT
	DECLARE @TABLE_DISTRIBUTION VARCHAR(100) = ''
	DECLARE @TABLE_INDEX VARCHAR(MAX) = ''
	--DECLARE @NEW_TABLE_NAME VARCHAR(100) = @TABLE_NAME + '_NEW_SET'

	--EXEC EDW_RITE.DBO.GET_DISRTIBUTION_STRING @SCHEMA_NAME, @TABLE_NAME, @TABLE_DISTRIBUTION OUTPUT 

	EXEC #GET_INDEX_STRING @SCHEMA_NAME, @TABLE_NAME, @TABLE_INDEX OUTPUT 

	IF OBJECT_ID('tempdb..#TABLE_COLUMNS') IS NOT NULL DROP TABLE #TABLE_COLUMNS;
	SELECT      s.name AS SchemaName, t.name AS TableName, CASE WHEN c.name = 'ERRORCODE' THEN 'ReplaceErrorCode' ELSE c.name END AS ColumnName, C.column_id, TYPE_NAME(c.system_type_id) AS ColumnType, c.max_length, c.PRECISION,c.scale,C.is_nullable, 
				ROW_NUMBER() OVER(ORDER BY C.column_id) AS RN
	INTO #TABLE_COLUMNS
	FROM        sys.columns c
	JOIN        sys.tables  t   ON c.object_id = t.object_id
	JOIN		sys.schemas S	ON S.schema_id = t.schema_id AND S.name = @SCHEMA_NAME
	WHERE       t.name = @TABLE_NAME

	--:: Alert check
	IF EXISTS (SELECT * FROM #TABLE_COLUMNS WHERE ColumnType IN ('IMAGE','BINARY','VARBINARY')) SELECT * FROM #TABLE_COLUMNS WHERE ColumnType IN ('IMAGE','BINARY','VARBINARY')
	IF EXISTS (SELECT * FROM #TABLE_COLUMNS WHERE ColumnType IN ('TEXT','NTEXT','NVARCHAR','MONEY')) SELECT * FROM #TABLE_COLUMNS WHERE ColumnType IN ('TEXT','NTEXT','NVARCHAR', 'NCHAR','MONEY')

	--PRINT 'GOT NEW_TABLE_COLUMNS'

	SELECT @NUM_OF_COLUMNS = MAX(RN) FROM #TABLE_COLUMNS

	DECLARE @SELECT_String VARCHAR(MAX) = '  '
	--DECLARE @THIS_SELECT_String VARCHAR(MAX) = ''
	DECLARE @Delimiter VARCHAR(3) = ''
	DECLARE @INDICAT SMALLINT = 1
	DECLARE @ColumnName Varchar(100)
	DECLARE @ColumnType Varchar(100)
	DECLARE @TitleCName Varchar(100)
	-- If only 1 period (and 1 partition) - @PART_RANGES is empty

	WHILE (@INDICAT <= @NUM_OF_COLUMNS)
	BEGIN
		
		SELECT
			@ColumnName = M.ColumnName,  
			@ColumnType = CASE 
				WHEN M.ColumnType = 'IMAGE' THEN 'VARBINARY'
				WHEN M.ColumnType = 'XML' THEN 'VARCHAR'
				WHEN M.ColumnType = 'TEXT' THEN 'VARCHAR'
				WHEN M.ColumnType = 'NTEXT' THEN 'VARCHAR'
				WHEN M.ColumnType = 'NVARCHAR' THEN 'VARCHAR'
				WHEN M.ColumnType = 'NUMERIC' THEN 'DECIMAL'
				WHEN M.ColumnType = 'Money' THEN 'DECIMAL(19,2)'
				WHEN M.ColumnType = 'DATETIME' THEN 'DATETIME2(3)'
				ELSE UPPER(M.ColumnType)
			END +
			CASE 
				WHEN M.ColumnType = 'IMAGE' THEN '(MAX)'
				WHEN M.ColumnType = 'XML' THEN '(8000)'
				WHEN M.ColumnType = 'TEXT' THEN '(8000)'
				WHEN M.ColumnType = 'NTEXT' THEN '(8000)'
				WHEN M.ColumnType = 'DATETIME2' THEN '(' + CAST(m.scale AS VARCHAR) +')'
				WHEN M.ColumnType IN ('BINARY','VARBINARY') THEN '(' + ISNULL(NULLIF(CAST(m.max_length AS VARCHAR),'-1'),'8000') +')'
				WHEN M.ColumnType IN ('DECIMAL','NUMERIC') THEN '(' + CAST(m.PRECISION AS VARCHAR) + ',' + CAST(m.scale AS VARCHAR) +')'
				WHEN M.ColumnType LIKE '%CHAR' THEN '(' + ISNULL(NULLIF(CAST(m.max_length AS VARCHAR),'-1'),'8000') +')'
				ELSE ''
			END + CHAR(9) + CASE WHEN m.is_nullable = 0 THEN ' NOT' ELSE '' END + ' NULL'
		FROM #TABLE_COLUMNS M
		WHERE M.RN = @INDICAT AND M.ColumnType NOT IN ('IMAGE','BINARY','VARBINARY') 

		EXEC #uf_TitleCase @ColumnName, @TitleCName OUTPUT
		
		IF @ColumnName IS NOT NULL
		BEGIN
			SET @SELECT_String = @SELECT_String +  + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) + @Delimiter + '[' + @TitleCName + '] ' + @ColumnType

			SET	@Delimiter = ', '
		END
		SET @INDICAT += 1

	END

	SET @SELECT_String = @SELECT_String + '
		, [LND_UpdateDate] DATETIME2(3) NULL
		, [LND_UpdateType] VARCHAR(1) NULL'

	DECLARE @TABLE_STATISTICS VARCHAR(MAX) = ''
	EXEC #GET_CREATE_STATISTICS_SQL @TitleSchemaName, @TitleTableName, @TABLE_STATISTICS OUTPUT 
	
	SET @TABLE_STATISTICS = @TABLE_STATISTICS + '
	CREATE STATISTICS [STAT_' + @TitleTableName + '_LND_UpdateDate] ON ' + @TitleSchemaName + '.[' + @TitleTableName + '] (LND_UpdateDate);'

	-- Add to statistics UpdatedDate and distribution culumn (first column fron clustered index)
	IF CHARINDEX('[UpdatedDate]',@SELECT_String) > 0 -- If this column exists - create statistics for it.
	BEGIN
		SET @TABLE_STATISTICS = @TABLE_STATISTICS + '
	CREATE STATISTICS [STAT_' + @TitleTableName + '_UpdatedDate] ON ' + @TitleSchemaName + '.[' + @TitleTableName + '] (UpdatedDate);'
	END 

	SET @SQL_STRING = '
	IF OBJECT_ID(''' + @TitleSchemaName + '.' + @TitleTableName + ''') IS NOT NULL			DROP TABLE ' + @TitleSchemaName + '.' + @TitleTableName + ';

	CREATE TABLE ' + @TitleSchemaName + '.' + @TitleTableName + ' (' + @SELECT_String + ') 
	WITH (' + @TABLE_INDEX + ')'

	IF OBJECT_ID('tempdb..#TABLE_COLUMNS') IS NOT NULL DROP TABLE #TABLE_COLUMNS;

	EXEC #PRINT_LONG_VARIABLE_VALUE @SQL_STRING
	EXEC #PRINT_LONG_VARIABLE_VALUE @TABLE_STATISTICS

END
GO


IF OBJECT_ID('tempdb..#GET_CREATE_TABLES_BY_LIST') IS NOT NULL DROP PROC #GET_CREATE_TABLES_BY_LIST
GO
CREATE PROC #GET_CREATE_TABLES_BY_LIST @TABLE_LIST VARCHAR(MAX) AS --,@SQL_STRING [VARCHAR](MAX) OUT AS
BEGIN

	DECLARE @NUM_OF_TABLES INT
	DECLARE @TABLE_NAME VARCHAR(100)
	DECLARE @SCHEMA_NAME VARCHAR(100)
	DECLARE @TitleTableName VARCHAR(100)
	DECLARE @TitleSchemaName VARCHAR(100)

	IF OBJECT_ID('tempdb..#SCHEMA_TABLES') IS NOT NULL DROP TABLE #SCHEMA_TABLES;

	SELECT SchemaName,TableName,FULL_NAME,
			ROW_NUMBER() OVER(ORDER BY SchemaName, TableName) AS RN
	INTO #SCHEMA_TABLES
	FROM
		(
			SELECT      s.name AS SchemaName, t.name AS TableName, '[' + s.name + '].[' + t.name + ']' AS FULL_NAME--, '[HISTORY].[' + H.TableName + ']' AS History_TableName, 
			FROM        sys.tables  t   
			JOIN		sys.schemas S	ON S.schema_id = t.schema_id
		) A
	WHERE CHARINDEX(A.FULL_NAME,@TABLE_LIST) > 0

	--SELECT * FROM #SCHEMA_TABLES

	SELECT @NUM_OF_TABLES = MAX(RN) FROM #SCHEMA_TABLES

	DECLARE @INDICAT SMALLINT = 1
	-- If only 1 period (and 1 partition) - @PART_RANGES is empty

	WHILE (@INDICAT <= @NUM_OF_TABLES)
	BEGIN
		
		SELECT @TABLE_NAME = TableName, @SCHEMA_NAME = SchemaName--, @FULL_NAME = FULL_NAME--, @History_TableName = History_TableName
		FROM #SCHEMA_TABLES M
		WHERE M.RN = @INDICAT --AND CHARINDEX(M.FULL_NAME,@EXCLUDE_TABLES) = 0
		
		IF @TABLE_NAME IS NOT NULL
		BEGIN

			EXEC #uf_TitleCase @TABLE_NAME, @TitleTableName OUTPUT
			EXEC #uf_TitleCase @SCHEMA_NAME, @TitleSchemaName OUTPUT
			SELECT @TitleSchemaName = REPLACE(@TitleSchemaName,'TER','TER')
			--SET @TitleFullName = '[' + @SCHEMA_NAME + '].' + '[' + @TitleTableName + ']'

			EXEC #GET_CREATE_TABLE_SQL @TitleSchemaName, @TitleTableName --, @SQL_SELECT OUTPUT, @SQL_STATS OUTPUT;

		END
		SET @INDICAT += 1
	END

END
GO


DECLARE @INCLUDE_TABLES VARCHAR(MAX)

SET @INCLUDE_TABLES = '
[COURT].[AdminHearing]
[COURT].[Counties]
[COURT].[Courts]
[COURT].[PlazaCourts]
[CASEMANAGER].[PmCase]
[CASEMANAGER].[PmCaseTypes]
[TER].[PaymentPlans]
[TER].[PaymentPlanTerms]
[TER].[PaymentPlanViolator]
[TER].[HvStatusLookup]
[TER].[HabitualViolators]
[TER].[ViolatorCollectionsOutbound]
[TER].[VehicleRegBlocks]
[TER].[VRBRequestDMV]
[TER].[DPSBanActions]
[TER].[VehicleBan]
[TER].[BanActions]
[TER].[CitationNumberSequence]
[TER].[CollectionAgencies]
[TER].[CollectionAgencyCounties]
[TER].[FailuretoPayCitations]
[TER].[HVEligibleTransactions]
[TER].[ViolatorCollectionsAgencyTracker]
[TER].[ViolatorCollectionsInbound]
[FINANCE].[ADJUSTMENT_LINEITEMS]
[FINANCE].[ADJUSTMENTS]
[FINANCE].[CustomerPayments]
[FINANCE].[PAYMENTTXN_LINEITEMS]
[FINANCE].[PAYMENTTXNS]
[FINANCE].[REFUNDREQUESTS_QUEUE]
[NOTIFICATIONS].[CustomerNotificationQueue]
[NOTIFICATIONS].[ConfigAlertTypeAlertChannels]
[NOTIFICATIONS].[ALERTCHANNELS]
[NOTIFICATIONS].[ALERTTYPES]
[DOCMGR].[TP_CUSTOMER_OUTBOUNDCOMMUNICATIONS]
[TOLLPLUS].[REF_LOOKUPTYPECODES_HIERARCHY]
[TOLLPLUS].[INVOICE_HEADER]
[TOLLPLUS].[INVOICE_LINEITEMS]
[TOLLPLUS].[ICN]
[TOLLPLUS].[TP_BANKRUPTCY_FILING]
[TOLLPLUS].[TP_VIOLATEDTRIPS]
[TOLLPLUS].[TP_CUSTOMER_VEHICLES]
[TOLLPLUS].[TP_CUSTOMER_CONTACTS]
[TOLLPLUS].[TP_CUSTOMER_ATTRIBUTES]
[TOLLPLUS].[TP_CUSTOMER_ADDRESSES]
[TOLLPLUS].[TP_CUSTOMER_PHONES]
[TOLLPLUS].[TP_CUSTOMER_EMAILS]
[TOLLPLUS].[TP_CUSTOMER_BALANCES]
[TOLLPLUS].[TP_CUSTOMER_FLAGS]
[TOLLPLUS].[TP_CUSTOMER_INTERNAL_USERS]
[TOLLPLUS].[TP_CUSTOMER_TAGS]
[TOLLPLUS].[TP_CUSTOMER_TRIP_CHARGES_TRACKER]
[TOLLPLUS].[TP_CUSTOMER_TRIP_RECEIPTS_TRACKER]
[TOLLPLUS].[TP_CUSTOMER_VEHICLE_TAGS]
[TOLLPLUS].[TP_CUSTOMERS]
[TOLLPLUS].[TP_CUSTOMERTRIPS]
[TOLLPLUS].[TP_CUSTOMERTRIPSTATUSTRACKER]
[TOLLPLUS].[TP_TRIPS]
[TOLLPLUS].[TP_VEHICLE_MODELS]
[TOLLPLUS].[TP_VIOLATED_TRIP_CHARGES_TRACKER]
[TOLLPLUS].[TP_VIOLATED_TRIP_RECEIPTS_TRACKER]
[TOLLPLUS].[TP_VIOLATEDTRIPS]
[TOLLPLUS].[TP_VIOLATEDTRIPSTATUSTRACKER]
[TOLLPLUS].[TP_IMAGE_REVIEW_RESULT_IMAGES]
[TOLLPLUS].[TP_IMAGE_REVIEW_RESULTS]
[TOLLPLUS].[TP_EXEMPTED_PLATES]
[TOLLPLUS].[CustomerFlagReferenceLookup]
[TOLLPLUS].[MbsHeader]
[TOLLPLUS].[MbsInvoices]
[TOLLPLUS].[InvoiceAttributes]
[TOLLPLUS].[BankruptcyStatuses]
[TOLLPLUS].[AddressSources]
[TOLLPLUS].[AGENCIES]
[TOLLPLUS].[CaseLinks]
[TOLLPLUS].[Dispositions]
[TOLLPLUS].[DMVExceptionDetails]
[TOLLPLUS].[DMVExceptionQueue]
[TOLLPLUS].[ESCHEATMENT_ELGIBLE_CUSTOMERS]
[TOLLPLUS].[FleetCustomerAttributes]
[TOLLPLUS].[FleetCustomersFileTracker]
[TOLLPLUS].[FleetCustomerVehiclesQueue]
[TOLLPLUS].[ICN_CASH]
[TOLLPLUS].[ICN_ITEMS]
[TOLLPLUS].[ICN_TXNS]
[TOLLPLUS].[ICN_VARIANCE]
[TOLLPLUS].[INVOICE_CHARGES_TRACKER]
[TOLLPLUS].[LANES]
[TOLLPLUS].[LOCATIONS]
[TOLLPLUS].[PLAZA_TYPES]
[TOLLPLUS].[PLAZAS]
[TOLLPLUS].[REF_INVOICE_WORKFLOW_STAGE_FEES]
[TOLLPLUS].[REF_INVOICE_WORKFLOW_STAGES]
[TOLLPLUS].[TRIPSTAGES]
[TOLLPLUS].[TRIPSTATUSES]
[TOLLPLUS].[TXNTYPE_CATEGORIES]
[TOLLPLUS].[UnMatchedTxnsQueue]
[TOLLPLUS].[VEHICLECLASSES]
[TOLLPLUS].[VIOLATION_WORKFLOW]
[TOLLPLUS].[ZipCodes]
[TOLLPLUS].[TP_EXEMPTED_PLATES]
[Court].[CourtJudges]
[Finance].[BANKPAYMENTS]
[Finance].[CHEQUEPAYMENTS]
[IOP].[AGENCIES]
[TollPlus].[REF_FEETYPES]
[Finance].[GL_TXN_LINEITEMS]
[Inventory].[ITEMINVENTORY]
[Inventory].[ITEMINVENTORYLOCATIONS]
[Inventory].[ITEMTYPES]
[IOP].[BOS_IOP_OUTBOUNDTRANSACTIONS]
[IOP].[IopPlates]
[IOP].[IopTags]
[Parking].[ParkingTrips]
[TER].[DPSTrooper]
[TollPlus].[TpFileTracker]
[TollPlus].[LaneCategories]
[Finance].[Adjustments]
[TollPlus].[PlateTypes]
[TollPlus].[TP_TRANSACTION_TYPES]
[TollPlus].[TP_TOLLTXN_REASONCODES]
[TOLLPLUS].[Channels]
[TOLLPLUS].[TP_Transaction_Types]
[TranProcessing].[HostBosFileTracker]
[TranProcessing].[IOPInboundRawTransactions]
[TranProcessing].[NTTAHostBOSFileTracker]
[TranProcessing].[NTTARawTransactions]
[TranProcessing].[TripSource]
[TranProcessing].[TSARawTransactions]
[TranProcessing].[TxnDispositions]
[Finance].[BusInessProcess_TxnTypes_Associations]
[Finance].[BusinessProcesses]
[Finance].[CharTofAccounts]
[Finance].[GL_Transactions]
[Finance].[TxnTypes]
[Finance].[GlDailySummaryByCoaIdBuId]
[TER].[HabitualViolatorStatusTracker]
[TER].[VRBRequestDallas]
[TollPlus].[MbsProcessStatus]
[TollPlus].[Merged_Customers]
[TollPlus].[OperationalLocations]
[TollPlus].[TP_AppLication_Parameters]
[TollPlus].[TP_Customer_AccStatus_Tracker]
[TollPlus].[TP_CustTxns]
[TollPlus].[TP_FileTracker]
[TollPlus].[TP_Invoice_Receipts_Tracker]
[TranProcessing].[RecordTypes]
[TollPlus].[AppTxnTypes] 
[TollPlus].[SubSystems]
[TollPlus].[TP_Customer_Business] 
[TollPlus].[TP_Customer_Plans]
[TollPlus].[Plans]
[FINANCE].[BulkPayments]
[TOLLPLUS].[BOS_IOP_INBOUNDTRANSACTIONS]
[TOLLPLUS].[COLLECTIONS_INBOUND]
[TOLLPLUS].[COLLECTIONS_OUTBOUND]
[TOLLPLUS].[TP_CUSTOMER_TAGS_HISTORY]
[TOLLPLUS].[TP_IMAGEREVIEW]
[TRANPROCESSING].[TSAImageRawTransactions]
'

EXEC #GET_CREATE_TABLES_BY_LIST @INCLUDE_TABLES


###################################################################################################################
*/








/*
###################################################################################################################
===================================================================================================================
Code Description: 
-------------------------------------------------------------------------------------------------------------------
This Code is to create a new table on APS (delete the previous version if exists. Run created script on APS
*******************************************************************************************************************
USE IPS 
GO

SET NOCOUNT ON
GO

IF OBJECT_ID('tempdb..#uf_TitleCase') IS NOT NULL DROP PROC #uf_TitleCase
GO

CREATE PROC #uf_TitleCase @Text [Varchar](8000), @Ret Varchar(8000) OUT 
AS
Begin  

	Declare @Reset Bit = 1;
	DECLARE @i Int = 2; -- Start checking from 2-nd letter - first should be title
	Declare @c Char(1);
	SET @Ret = '';

	If @Text Is Null
		Return -1;

	DECLARE @IsT BIT = 0;
	WHILE (@i <= Len(@Text))
	Begin
		Set @c = Substring(@Text, @i, 1)
		IF (ASCII(@c) BETWEEN 97 AND 122) SET @IsT = 1

		SET @i = @i + 1

		IF @IsT = 1 BREAK

	END


	IF @IsT = 0
		SET @Text = LOWER(@Text)

	SET @i = 1;

	While (@i <= Len(@Text))
	Begin
		Set @c = Substring(@Text, @i, 1)
		Set @Ret = @Ret + Case When @Reset = 1 Then Upper(@c) Else Lower(@c) End
		Set @Reset = Case When @c Like '[a-z]' Then 0 Else 1 End
		Set @i = @i + 1
	End

	SET @Ret = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@Ret,
		'By','By'),'HV','HV'),'ID','ID'),'In','In'),'Is','Is'),'No','No'),'Of','Of'),'Or','Or'),'PK','PK'),'To','To'),'Acc','Acc'),'Act','Act'),'Add','Add'),'Adj','Adj'),'AIP','AIP'),'Amt','Amt'),'And','And'),'Bad','Bad'),'Ban','Ban'),'BOS','BOS'),'Cnt','Cnt'),'CSV','CSV'),'Cut','Cut'),'Day','Day'),'DMV','DMV'),'DPS','DPS'),'Due','Due'),'EIP','EIP'),'End','End'),'Enh','Enh'),'Fee','Fee'),'FK_','FK_'),'FTP','FTP'),'Hex','Hex'),'ICN','ICN'),'IDX','IDX'),'Img','Img'),'INX','INX'),'IOP','IOP'),'IPS','IPS'),'IX_','IX_'),'Key','Key'),'Lic','Lic'),'Log','Log'),'Map','Map'),'MIR','MIR'),'New','New'),'NNP','NNP'),'Non','Non'),'Num','Num'),'OCR','OCR'),'Out','Out'),'Own','Own'),'Pay','Pay'),'PBM','PBM'),'Raw','Raw'),'Ref','Ref'),'Reg','Reg'),'Rev','Rev'),'ROI','ROI'),'Seq','Seq'),'Sig','Sig'),'SSN','SSN'),'Tag','Tag'),'Tax','Tax'),'Top','Top'),'TP_','TP_'),'TSA','TSA'),'Txn','Txn'),'UQ_','UQ_'),'UTC','UTC'),'VCF','VCF'),'VIN','VIN'),'VIP','VIP'),'VRB','VRB'),'VSR','VSR'),'Web','Web'),'Zip','Zip'),'ALPR','ALPR'),'Attr','Attr'),'Auto','Auto'),'Axle','Axle'),'Bill','Bill'),'Body','Body'),'Call','Call'),'Case','Case'),'Cash','Cash'),'City','City'),'Clos','Clos'),'Code','Code'),'Coll','Coll'),'Comm','Comm'),'Cust','Cust'),'Data','Data'),'Date','Date'),'Desc','Desc'),'Down','Down'),'Driv','Driv'),'Effe','Effe'),'Exit','Exit'),'File','File'),'Flag','Flag'),'Hist','Hist'),'Hold','Hold'),'Home','Home'),'Host','Host'),'Info','Info'),'Item','Item'),'JSON','JSON'),'Lane','Lane'),'Last','Last'),'Left','Left'),'Line','Line'),'List','List'),'Load','Load'),'Look','Look'),'Mail','Mail'),'Main','Main'),'Make','Make'),'Mark','Mark'),'Mode','Mode'),'MST_','MST_'),'Name','Name'),'NIX_','NIX_'),'Note','Note'),'NTTA','NTTA'),'Paid','Paid'),'Path','Path'),'Phon','Phon'),'Plan','Plan'),'Plus','Plus'),'Port','Port'),'Post','Post'),'Prev','Prev'),'Quer','Quer'),'Rate','Rate'),'Read','Read'),'Role','Role'),'Self','Self'),'Send','Send'),'Sent','Sent'),'Ship','Ship'),'Size','Size'),'Step','Step'),'Term','Term'),'Time','Time'),'Toll','Toll'),'Tran','Tran'),'Trip','Trip'),'Type','Type'),'User','User'),'With','With'),'Work','Work'),'Year','Year'),'Activ','Activ'),'Admin','Admin'),'Agenc','Agenc'),'Alert','Alert'),'Alias','Alias'),'Batch','Batch'),'Blind','Blind'),'Block','Block'),'Check','Check'),'Citat','Citat'),'Class','Class'),'Color','Color'),'Count','Count'),'Court','Court'),'Creat','Creat'),'Cycle','Cycle'),'Email','Email'),'Entry','Entry'),'Error','Error'),'Event','Event'),'Expir','Expir'),'First','First'),'Float','Float'),'Group','Group'),'Horiz','Horiz'),'Ident','Ident'),'Image','Image'),'Index','Index'),'Langu','Langu'),'Major','Major'),'Match','Match'),'Minor','Minor'),'Modif','Modif'),'Plate','Plate'),'Plaza','Plaza'),'Print','Print'),'Prior','Prior'),'Purch','Purch'),'Queue','Queue'),'Raise','Raise'),'Right','Right'),'Setup','Setup'),'Shift','Shift'),'Short','Short'),'Speed','Speed'),'Spons','Spons'),'Stage','Stage'),
		'Stand','Stand'),'Start','Start'),'STAT_','STAT_'),'State','State'),'Style','Style'),'Super','Super'),'Surve','Surve'),'Table','Table'),'Title','Title'),'TxDot','TxDot'),'Updat','Updat'),'Usage','Usage'),'Valid','Valid'),'Value','Value'),'Verif','Verif'),'Video','Video'),'VToll','VToll'),'Waive','Waive'),'Write','Write'),'Action','Action'),'Amount','Amount'),'Appear','Appear'),'Approv','Approv'),'Assign','Assign'),'Bottom','Bottom'),'Bright','Bright'),'Calcul','Calcul'),'Change','Change'),'Charge','Charge'),'Confid','Confid'),'Config','Config'),'Credit','Credit'),'Detail','Detail'),'Direct','Direct'),'DocMgr','DocMgr'),'Enable','Enable'),'Ground','Ground'),'Handle','Handle'),'Header','Header'),'Height','Height'),'Histor','Histor'),'Invoic','Invoic'),'Length','Length'),'Letter','Letter'),'Manual','Manual'),'Messag','Messag'),'Method','Method'),'Middle','Middle'),'Normal','Normal'),'Option','Option'),'Parent','Parent'),'Period','Period'),'Portal','Portal'),'Prefer','Prefer'),'Prefix','Prefix'),'Primar','Primar'),'Protec','Protec'),'Qualif','Qualif'),'Reason','Reason'),'Rebill','Rebill'),'Record','Record'),'Reject','Reject'),'Remain','Remain'),'Remark','Remark'),'Renter','Renter'),'Report','Report'),'Result','Result'),'Retail','Retail'),'Return','Return'),'Review','Review'),'Serial','Serial'),'Source','Source'),'Status','Status'),'Street','Street'),'Submit','Submit'),'Suffix','Suffix'),'Syntax','Syntax'),'System','System'),'Unread','Unread'),'Upload','Upload'),'Violat','Violat'),'Volume','Volume'),'Account','Account'),'Balance','Balance'),'Carrier','Carrier'),'Categor','Categor'),'Channel','Channel'),'Complet','Complet'),'Consume','Consume'),'Contact','Contact'),'Correct','Correct'),'Default','Default'),'Deliver','Deliver'),'Deposit','Deposit'),'Dismiss','Dismiss'),'Display','Display'),'Facilit','Facilit'),'Frequen','Frequen'),'Generat','Generat'),'Hearing','Hearing'),'Inbound','Inbound'),'Indicat','Indicat'),'Invalid','Invalid'),'Mailing','Mailing'),'Malform','Malform'),'Manager','Manager'),'Misread','Misread'),'Notific','Notific'),'Parking','Parking'),'Pending','Pending'),'Premium','Premium'),'Process','Process'),'Receipt','Receipt'),'Receive','Receive'),'Renewal','Renewal'),'Replace','Replace'),'Request','Request'),'Require','Require'),'Resolve','Resolve'),'Service','Service'),'Sponsor','Sponsor'),'Storage','Storage'),'Summary','Summary'),'Tracker','Tracker'),'Trigger','Trigger'),'Trooper','Trooper'),'Unmatch','Unmatch'),'Vehicle','Vehicle'),'Visible','Visible'),'Authorit','Authorit'),'Conflict','Conflict'),'Contrast','Contrast'),'Decision','Decision'),'Discount','Discount'),'Download','Download'),'Eligible','Eligible'),'Inventor','Inventor'),'Loaction','Loaction'),'Location','Location'),'Metadata','Metadata'),'Normalis','Normalis'),'Position','Position'),'Response','Response'),'Sequence','Sequence'),'Template','Template'),'Terminat','Terminat'),'Vertical','Vertical'),
		'Affidavit','Affidavit'),'Determina','Determina'),'Exception','Exception'),'Excessive','Excessive'),'Registrat','Registrat'),'Signature','Signature'),'Subscribe','Subscribe'),'Surrender','Surrender'),'Telephone','Telephone'),'Threshold','Threshold'),'Bankruptcy','Bankruptcy'),'Correspond','Correspond'),'Processing','Processing'),'Disposition','Disposition'),'Outstanding','Outstanding'),'Transaction','Transaction'),'Jurisdiction','Jurisdiction'),'Representativ','Representativ')

	Return 0

End
GO


IF OBJECT_ID('tempdb..#PRINT_LONG_VARIABLE_VALUE') IS NOT NULL DROP PROC #PRINT_LONG_VARIABLE_VALUE
GO

CREATE PROC #PRINT_LONG_VARIABLE_VALUE @sql [VARCHAR](MAX) AS
BEGIN
	DECLARE @ST_R INT = 0
	DECLARE @CUT_LEN INT = 8000
	DECLARE @CUT_R INT = @CUT_LEN
	DECLARE @SQL_PART VARCHAR(8000)
	DECLARE @LONG INT = LEN(@sql)
	DECLARE @SQL_PART_REV VARCHAR(MAX)
	DECLARE @LAST_ENTER_SYMBOL_NBR INT

	WHILE (@ST_R <= @LONG)
	BEGIN
		SET @SQL_PART = SUBSTRING(@sql, @ST_R, @CUT_LEN)
		SET @CUT_R = LEN(@SQL_PART) 
		-- Every time we print something - it prints on the next row
		-- it means, if we stopped in the middle of the row the next part of this row will be on the next row - we don't want this

		IF @ST_R + @CUT_LEN < @LONG -- it does not metter if this is the last part
		BEGIN
			SET @SQL_PART_REV = REVERSE(@SQL_PART)

			-- We are looking for the last "ENTER" symbol in our string part and cutting out everything after this - it will go to the next part
			-- To find it better to reverse the string
			SET @LAST_ENTER_SYMBOL_NBR = CHARINDEX(CHAR(13),@SQL_PART_REV)

			IF @LAST_ENTER_SYMBOL_NBR > 0
			BEGIN
				SET @SQL_PART = LEFT(@SQL_PART, @CUT_R - @LAST_ENTER_SYMBOL_NBR)
				-- Now should set a new length of the string part plus Enter symbol we don't want to have again
				SET @CUT_R = @CUT_R - @LAST_ENTER_SYMBOL_NBR + 1
			END
		END

		PRINT @SQL_PART
		-- Set beginning of the next part as the last part beginning + length of string part + next sybmol (+1) 
		SET @ST_R = @ST_R + @CUT_R + 1
	END
END
GO

IF OBJECT_ID('tempdb..#GET_INDEX_STRING') IS NOT NULL DROP PROC #GET_INDEX_STRING
GO
CREATE PROC #GET_INDEX_STRING @SCHEMA_NAME [VARCHAR](100), @TABLE [VARCHAR](100),@SQL_STRING [VARCHAR](MAX) OUT AS

BEGIN
	DECLARE @TABLE_INDEX VARCHAR(100)

	SELECT @TABLE_INDEX = I.type_desc
	FROM sys.tables as t
	JOIN sys.indexes AS I ON I.object_id = t.object_id
	WHERE t.name = @TABLE AND I.index_id <=1

	IF @TABLE_INDEX = 'CLUSTERED'
	BEGIN
		WITH CTE AS
		(
			SELECT C.column_id, u.name AS column_name, CASE WHEN C.is_descending_key = 1 THEN ' DESC' ELSE ' ASC' END AS column_Order
				, ROW_NUMBER() OVER (ORDER BY C.column_id) AS RN 
			FROM sys.tables as t
			JOIN sys.schemas as S ON S.SCHEMA_ID = t.SCHEMA_ID AND S.name = @SCHEMA_NAME
			JOIN sys.indexes AS I ON I.object_id = t.object_id AND I.index_id <=1
			JOIN sys.index_columns AS C ON C.object_id = t.object_id AND C.index_id = I.index_id
			JOIN sys.columns AS u ON u.column_id = C.column_id AND u.object_id = t.object_id
			WHERE t.name = @TABLE
		)
		, CTE_JOINT AS 
		(
			SELECT
				' [' + CTE1.column_name + ']' AS INDEX_1st_COLUMN
				, ' [' + CTE1.column_name + ']' + CTE1.column_Order
				+ ISNULL(', ['+ CTE2.column_name + ']' + CTE2.column_Order, '')
				+ ISNULL(', ['+ CTE3.column_name + ']' + CTE3.column_Order, '')
				+ ISNULL(', ['+ CTE4.column_name + ']' + CTE4.column_Order, '')
				+ ISNULL(', ['+ CTE5.column_name + ']' + CTE5.column_Order, '')
				+ ISNULL(', ['+ CTE6.column_name + ']' + CTE6.column_Order, '')
				+ ISNULL(', ['+ CTE7.column_name + ']' + CTE7.column_Order, '')
				+ ISNULL(', ['+ CTE8.column_name + ']' + CTE8.column_Order, '')
				+ ISNULL(', ['+ CTE9.column_name + ']' + CTE9.column_Order, '')
				+ ISNULL(', ['+ CTE10.column_name + ']' + CTE10.column_Order, '') + ' ' AS INDEX_COULUMNS
			FROM CTE AS CTE1
			LEFT JOIN CTE AS CTE2 ON  CTE2.RN = 2
			LEFT JOIN CTE AS CTE3 ON  CTE3.RN = 3
			LEFT JOIN CTE AS CTE4 ON  CTE4.RN = 4
			LEFT JOIN CTE AS CTE5 ON  CTE5.RN = 5
			LEFT JOIN CTE AS CTE6 ON  CTE6.RN = 6
			LEFT JOIN CTE AS CTE7 ON  CTE7.RN = 7
			LEFT JOIN CTE AS CTE8 ON  CTE8.RN = 8
			LEFT JOIN CTE AS CTE9 ON  CTE9.RN = 9
			LEFT JOIN CTE AS CTE10 ON CTE10.RN = 10
			WHERE CTE1.RN = 1
		)
		SELECT TOP 1
			@SQL_STRING = @TABLE_INDEX + ' INDEX (' + INDEX_COULUMNS + '), DISTRIBUTION = HASH(' + INDEX_1st_COLUMN + ')'
		FROM CTE_JOINT
	END
	ELSE
	BEGIN
		IF @TABLE_INDEX = 'CLUSTERED COLUMNSTORE'
		BEGIN
			SET @SQL_STRING = @TABLE_INDEX + ' INDEX, DISTRIBUTION = ROUND_ROBIN'
		END
		ELSE
		BEGIN
			SET @SQL_STRING = @TABLE_INDEX
		END
		--WITH (CLUSTERED INDEX ( [ACCT_ID] ASC , [ACCT_TAG_SEQ] ASC ), DISTRIBUTION = HASH([ACCT_ID]));
	END
END
GO

IF OBJECT_ID('tempdb..#GET_CREATE_STATISTICS_SQL') IS NOT NULL DROP PROC #GET_CREATE_STATISTICS_SQL
GO
CREATE PROC #GET_CREATE_STATISTICS_SQL @SCHEMA_NAME [VARCHAR](100), @TABLE [VARCHAR](100),@SQL_STRING [VARCHAR](MAX) OUT AS
BEGIN
	--DECLARE @SCHEMA_NAME [VARCHAR](100) = 'TollPlus', @TABLE [VARCHAR](100) = 'Tp_Customer_Balances', @SQL_STRING [VARCHAR](MAX)
	
	IF OBJECT_ID('TempDB..#TABLE_STATS') IS NOT NULL DROP TABLE #TABLE_STATS;


	WITH CTE AS
	(
		-- Statistic for foreign key
		SELECT 
			s.[name] AS schemaName, 
			OBJECT_NAME(A.PARENT_OBJECT_ID) AS [table_name], 
			'STAT_' + F.name AS [stats_name], 
			B.name AS [column_name], 
			ROW_NUMBER() OVER (PARTITION BY F.name ORDER BY b.column_id) AS RN
		FROM SYS.FOREIGN_KEY_COLUMNS A 
		JOIN sys.foreign_keys f on f.object_id = a.constraint_object_id
		JOIN sys.schemas S	ON S.schema_id = f.schema_id AND S.name = @SCHEMA_NAME
		JOIN SYS.COLUMNS B ON A.PARENT_COLUMN_ID = B.COLUMN_ID 
			AND A.PARENT_OBJECT_ID = B.OBJECT_ID 
		WHERE OBJECT_NAME(A.PARENT_OBJECT_ID) = @TABLE

		UNION ALL

		-- Statistics for nonclustered indexes - instead of create indexes
		SELECT 
			s.[name] AS schemaName, 
			t.name AS [table_name], 
			'STAT_' + I.name AS [stats_name], 
			u.name AS column_name,
			ROW_NUMBER() OVER (PARTITION BY I.name ORDER BY C.column_id) AS RN 
		FROM sys.tables as t
		JOIN sys.schemas as S ON S.SCHEMA_ID = t.SCHEMA_ID AND S.name = @SCHEMA_NAME
		JOIN sys.indexes AS I ON I.object_id = t.object_id AND I.index_id > 1
		JOIN sys.index_columns AS C ON C.object_id = t.object_id AND C.index_id = I.index_id
		JOIN sys.columns AS u ON u.column_id = C.column_id AND u.object_id = t.object_id
		WHERE t.name = @TABLE

		UNION ALL

		-- User-created stats
		SELECT
			s.[name] AS schemaName
			,t.[name] AS [table_name]
			,'STAT_' + ss.[name] AS [stats_name]
			,c.name AS [column_name]
			, ROW_NUMBER() OVER (PARTITION BY ss.[name] ORDER BY C.column_id) AS RN 
		FROM        sys.schemas s
		JOIN        sys.tables t                    ON      t.[schema_id]  = s.[schema_id]
		JOIN		sys.stats ss					ON		ss.[object_id] = t.[object_id] AND ss.user_created = 1
		JOIN		sys.stats_columns sc			ON		sc.[object_id] = t.[object_id] AND ss.stats_id = sc.stats_id
		JOIN        sys.columns c                   ON      t.[object_id]  = c.[object_id] AND sc.column_id  = c.column_id
		WHERE  t.[name] = @TABLE
	)
	, CTE_JOINT AS 
	(
		SELECT 
			CTE1.schemaName
			,CTE1.table_name
			,CTE1.stats_name
			, '[' + CTE1.column_name + ']'
			+ ISNULL(', ['+ CTE2.column_name + ']', '')
			+ ISNULL(', ['+ CTE3.column_name + ']', '')
			+ ISNULL(', ['+ CTE4.column_name + ']', '')
			+ ISNULL(', ['+ CTE5.column_name + ']', '')
			+ ISNULL(', ['+ CTE6.column_name + ']', '')
			+ ISNULL(', ['+ CTE7.column_name + ']', '')
			+ ISNULL(', ['+ CTE8.column_name + ']', '')
			+ ISNULL(', ['+ CTE9.column_name + ']', '')
			+ ISNULL(', ['+ CTE10.column_name + ']', '') AS stats_col 
		FROM CTE AS CTE1
		LEFT JOIN CTE AS CTE2 ON CTE2.stats_name = CTE1.stats_name AND CTE2.RN = 2
		LEFT JOIN CTE AS CTE3 ON CTE3.stats_name = CTE1.stats_name AND CTE3.RN = 3
		LEFT JOIN CTE AS CTE4 ON CTE4.stats_name = CTE1.stats_name AND CTE4.RN = 4
		LEFT JOIN CTE AS CTE5 ON CTE5.stats_name = CTE1.stats_name AND CTE5.RN = 5
		LEFT JOIN CTE AS CTE6 ON CTE6.stats_name = CTE1.stats_name AND CTE6.RN = 6
		LEFT JOIN CTE AS CTE7 ON CTE7.stats_name = CTE1.stats_name AND CTE7.RN = 7
		LEFT JOIN CTE AS CTE8 ON CTE8.stats_name = CTE1.stats_name AND CTE8.RN = 8
		LEFT JOIN CTE AS CTE9 ON CTE9.stats_name = CTE1.stats_name AND CTE9.RN = 9
		LEFT JOIN CTE AS CTE10 ON CTE10.stats_name = CTE1.stats_name AND CTE10.RN = 10
		WHERE CTE1.RN = 1
	)
	SELECT 
			schemaName
			,table_name
			,stats_name
			,stats_col
			,'CREATE STATISTICS [' + stats_name + '] ON ' + @SCHEMA_NAME + '.[' + @TABLE + '] (' + stats_col + ');' AS SQL_STRING
			, ROW_NUMBER() OVER(ORDER BY stats_name) AS RN
	INTO #TABLE_STATS
	FROM CTE_JOINT

	--SELECT * FROM #TABLE_STATS

	DECLARE @NUM_OF_COLUMNS INT
	DECLARE @THIS_SQL_STRING VARCHAR(MAX) = '', @Title_SQL_String VARCHAR(MAX) = ''
	DECLARE @INDICAT SMALLINT = 1

	SET @SQL_STRING  = ''

	SELECT @NUM_OF_COLUMNS = MAX(RN) FROM #TABLE_STATS
	SET @INDICAT = 1
	-- If only 1 period (and 1 partition) - @PART_RANGES is empty
	WHILE (@INDICAT <= @NUM_OF_COLUMNS)
	BEGIN
		
		SELECT @THIS_SQL_STRING = SQL_STRING FROM #TABLE_STATS WHERE RN = @INDICAT --ORDER BY stats_name
		EXEC #uf_TitleCase @THIS_SQL_STRING, @Title_SQL_String OUTPUT

		SET @SQL_STRING = @SQL_STRING + char(13) + char(9) + REPLACE(REPLACE(@Title_SQL_String,'CREATE STATISTICS','CREATE STATISTICS'), ' ON ', ' ON ')

		SET @INDICAT += 1

	END

	--PRINT @SQL_STRING
END
go

IF OBJECT_ID('tempdb..#GET_CREATE_TABLE_SQL') IS NOT NULL DROP PROC #GET_CREATE_TABLE_SQL
GO
CREATE PROC #GET_CREATE_TABLE_SQL @SCHEMA_NAME [VARCHAR](100), @TABLE_NAME [VARCHAR](100) AS 

BEGIN

	DECLARE @SQL_STRING VARCHAR(MAX) = '';
	DECLARE @TitleTableName VARCHAR(100)
	DECLARE @TitleSchemaName VARCHAR(100)
	EXEC #uf_TitleCase @TABLE_NAME, @TitleTableName OUTPUT
	EXEC #uf_TitleCase @SCHEMA_NAME, @TitleSchemaName OUTPUT
	SELECT @TitleSchemaName = REPLACE(@TitleSchemaName,'TER','TER')

	DECLARE @NUM_OF_COLUMNS INT
	DECLARE @TABLE_DISTRIBUTION VARCHAR(100) = ''
	DECLARE @TABLE_INDEX VARCHAR(MAX) = ''
	--DECLARE @NEW_TABLE_NAME VARCHAR(100) = @TABLE_NAME + '_NEW_SET'

	--EXEC EDW_RITE.DBO.GET_DISRTIBUTION_STRING @SCHEMA_NAME, @TABLE_NAME, @TABLE_DISTRIBUTION OUTPUT 

	EXEC #GET_INDEX_STRING @SCHEMA_NAME, @TABLE_NAME, @TABLE_INDEX OUTPUT 

	IF OBJECT_ID('tempdb..#TABLE_COLUMNS') IS NOT NULL DROP TABLE #TABLE_COLUMNS;
	SELECT      s.name AS SchemaName, t.name AS TableName, c.name AS ColumnName, C.column_id, TYPE_NAME(c.system_type_id) AS ColumnType, c.max_length, c.PRECISION,c.scale,C.is_nullable, 
				ROW_NUMBER() OVER(ORDER BY C.column_id) AS RN
	INTO #TABLE_COLUMNS
	FROM        sys.columns c
	JOIN        sys.tables  t   ON c.object_id = t.object_id
	JOIN		sys.schemas S	ON S.schema_id = t.schema_id AND S.name = @SCHEMA_NAME
	WHERE       t.name = @TABLE_NAME

	--:: Alert check
	IF EXISTS (SELECT * FROM #TABLE_COLUMNS WHERE ColumnType IN ('IMAGE','BINARY','VARBINARY')) SELECT * FROM #TABLE_COLUMNS WHERE ColumnType IN ('IMAGE','BINARY','VARBINARY')
	IF EXISTS (SELECT * FROM #TABLE_COLUMNS WHERE ColumnType IN ('TEXT','NTEXT','NVARCHAR','MONEY')) SELECT * FROM #TABLE_COLUMNS WHERE ColumnType IN ('TEXT','NTEXT','NVARCHAR', 'NCHAR','MONEY')

	--PRINT 'GOT NEW_TABLE_COLUMNS'

	SELECT @NUM_OF_COLUMNS = MAX(RN) FROM #TABLE_COLUMNS

	DECLARE @SELECT_String VARCHAR(MAX) = '  '
	--DECLARE @THIS_SELECT_String VARCHAR(MAX) = ''
	DECLARE @Delimiter VARCHAR(3) = ''
	DECLARE @INDICAT SMALLINT = 1
	DECLARE @ColumnName Varchar(100)
	DECLARE @ColumnType Varchar(100)
	DECLARE @TitleCName Varchar(100)
	-- If only 1 period (and 1 partition) - @PART_RANGES is empty

	WHILE (@INDICAT <= @NUM_OF_COLUMNS)
	BEGIN
		
		SELECT
			@ColumnName = M.ColumnName,  
			@ColumnType = CASE 
				WHEN M.ColumnType = 'IMAGE' THEN 'VARBINARY'
				WHEN M.ColumnType = 'XML' THEN 'VARCHAR'
				WHEN M.ColumnType = 'TEXT' THEN 'VARCHAR'
				WHEN M.ColumnType = 'NTEXT' THEN 'VARCHAR'
				WHEN M.ColumnType = 'NVARCHAR' THEN 'VARCHAR'
				WHEN M.ColumnType = 'NUMERIC' THEN 'DECIMAL'
				WHEN M.ColumnType = 'Money' THEN 'DECIMAL(19,2)'
				WHEN M.ColumnType = 'DATETIME' THEN 'DATETIME2(3)'
				ELSE UPPER(M.ColumnType)
			END +
			CASE 
				WHEN M.ColumnType = 'IMAGE' THEN '(MAX)'
				WHEN M.ColumnType = 'XML' THEN '(8000)'
				WHEN M.ColumnType = 'TEXT' THEN '(8000)'
				WHEN M.ColumnType = 'NTEXT' THEN '(8000)'
				WHEN M.ColumnType = 'DATETIME2' THEN '(' + CAST(m.scale AS VARCHAR) +')'
				WHEN M.ColumnType IN ('BINARY','VARBINARY') THEN '(' + ISNULL(NULLIF(CAST(m.max_length AS VARCHAR),'-1'),'8000') +')'
				WHEN M.ColumnType IN ('DECIMAL','NUMERIC') THEN '(' + CAST(m.PRECISION AS VARCHAR) + ',' + CAST(m.scale AS VARCHAR) +')'
				WHEN M.ColumnType LIKE '%CHAR' THEN '(' + ISNULL(NULLIF(CAST(m.max_length AS VARCHAR),'-1'),'8000') +')'
				ELSE ''
			END + CHAR(9) + CASE WHEN m.is_nullable = 0 THEN ' NOT' ELSE '' END + ' NULL'
		FROM #TABLE_COLUMNS M
		WHERE M.RN = @INDICAT AND M.ColumnType NOT IN ('IMAGE','BINARY','VARBINARY') 

		EXEC #uf_TitleCase @ColumnName, @TitleCName OUTPUT
		
		IF @ColumnName IS NOT NULL
		BEGIN
			SET @SELECT_String = @SELECT_String +  + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) + @Delimiter + '[' + @TitleCName + '] ' + @ColumnType

			SET	@Delimiter = ', '
		END
		SET @INDICAT += 1

	END

	SET @SELECT_String = @SELECT_String + '
		, [LND_UpdateDate] DATETIME2(3) NULL
		, [LND_UpdateType] VARCHAR(1) NULL'

	DECLARE @TABLE_STATISTICS VARCHAR(MAX) = ''
	EXEC #GET_CREATE_STATISTICS_SQL @TitleSchemaName, @TitleTableName, @TABLE_STATISTICS OUTPUT 
	
	SET @TABLE_STATISTICS = @TABLE_STATISTICS + '
	CREATE STATISTICS [STAT_' + @TitleTableName + '_LND_UpdateDate] ON ' + @TitleSchemaName + '.[' + @TitleTableName + '] (LND_UpdateDate);'

	-- Add to statistics UpdatedDate and distribution culumn (first column fron clustered index)
	IF CHARINDEX('[UpdatedDate]',@SELECT_String) > 0 -- If this column exists - create statistics for it.
	BEGIN
		SET @TABLE_STATISTICS = @TABLE_STATISTICS + '
	CREATE STATISTICS [STAT_' + @TitleTableName + '_UpdatedDate] ON ' + @TitleSchemaName + '.[' + @TitleTableName + '] (UpdatedDate);'
	END 

	SET @SQL_STRING = '
	IF OBJECT_ID(''' + @TitleSchemaName + '.' + @TitleTableName + ''') IS NOT NULL			DROP TABLE ' + @TitleSchemaName + '.' + @TitleTableName + ';

	CREATE TABLE ' + @TitleSchemaName + '.' + @TitleTableName + ' (' + @SELECT_String + ') 
	WITH (' + @TABLE_INDEX + ')'

	IF OBJECT_ID('tempdb..#TABLE_COLUMNS') IS NOT NULL DROP TABLE #TABLE_COLUMNS;

	EXEC #PRINT_LONG_VARIABLE_VALUE @SQL_STRING
	EXEC #PRINT_LONG_VARIABLE_VALUE @TABLE_STATISTICS


END
GO


IF OBJECT_ID('tempdb..#GET_CREATE_TABLES_BY_LIST') IS NOT NULL DROP PROC #GET_CREATE_TABLES_BY_LIST
GO
CREATE PROC #GET_CREATE_TABLES_BY_LIST @TABLE_LIST [VARCHAR](MAX) AS --,@SQL_STRING [VARCHAR](MAX) OUT AS
BEGIN

	DECLARE @NUM_OF_TABLES INT
	DECLARE @TABLE_NAME VARCHAR(100)
	DECLARE @SCHEMA_NAME VARCHAR(100)
	DECLARE @TitleTableName VARCHAR(100)
	DECLARE @TitleSchemaName VARCHAR(100)

	IF OBJECT_ID('tempdb..#SCHEMA_TABLES') IS NOT NULL DROP TABLE #SCHEMA_TABLES;

	SELECT SchemaName,TableName,FULL_NAME,
			ROW_NUMBER() OVER(ORDER BY SchemaName, TableName) AS RN
	INTO #SCHEMA_TABLES
	FROM
		(
			SELECT      s.name AS SchemaName, t.name AS TableName, '[' + s.name + '].[' + t.name + ']' AS FULL_NAME--, '[HISTORY].[' + H.TableName + ']' AS History_TableName, 
			FROM        sys.tables  t   
			JOIN		sys.schemas S	ON S.schema_id = t.schema_id
		) A
	WHERE CHARINDEX(A.FULL_NAME,@TABLE_LIST) > 0

	--SELECT * FROM #SCHEMA_TABLES

	SELECT @NUM_OF_TABLES = MAX(RN) FROM #SCHEMA_TABLES

	DECLARE @INDICAT SMALLINT = 1
	-- If only 1 period (and 1 partition) - @PART_RANGES is empty

	WHILE (@INDICAT <= @NUM_OF_TABLES)
	BEGIN
		
		SELECT @TABLE_NAME = TableName, @SCHEMA_NAME = SchemaName--, @FULL_NAME = FULL_NAME--, @History_TableName = History_TableName
		FROM #SCHEMA_TABLES M
		WHERE M.RN = @INDICAT --AND CHARINDEX(M.FULL_NAME,@EXCLUDE_TABLES) = 0
		
		IF @TABLE_NAME IS NOT NULL
		BEGIN

			EXEC #uf_TitleCase @TABLE_NAME, @TitleTableName OUTPUT
			EXEC #uf_TitleCase @SCHEMA_NAME, @TitleSchemaName OUTPUT
			SELECT @TitleSchemaName = REPLACE(@TitleSchemaName,'TER','TER')
			--SET @TitleFullName = '[' + @SCHEMA_NAME + '].' + '[' + @TitleTableName + ']'

			EXEC #GET_CREATE_TABLE_SQL @TitleSchemaName, @TitleTableName --, @SQL_SELECT OUTPUT, @SQL_STATS OUTPUT;

		END
		SET @INDICAT += 1
	END

END
GO


DECLARE @INCLUDE_TABLES VARCHAR(MAX)

SET @INCLUDE_TABLES = '
[EIP].[inboundfiletracker]
[EIP].[imagefiletracker]
[eip].[request_tracker]
[eip].[transactions]
[eip].[vehicleimages]
[eip].[ocrresults]
[mir].[mir_workqueue_stage]
[mir].[mir_transactions]
[eip].[results_log]
[mir].[txnstages]
[mir].[txnstagetypes]
[mir].[txnstatuses]
[mir].[mst_dispositioncodes]
[mir].[reasoncodes]
[mir].[mst_sourcetypes]
[mir].[mst_responsetypes]
[eip].[image_storage_paths]
[mir].[txnqueues]
[mir].[txnstageshistory]
[mir].[txnstagetypeshistory]
[mir].[txnstatuseshistory]
[mir].[reasoncodeshistory]
[EIP].[Audit_Summary]
[EIP].[AuditTracker]
[EIP].[AuditTransactions]
[EIP].[AuditTypes]
[MIR].[Transaction_InputLog]
[MIR].[MST_TransactionTypes]
'
EXEC #GET_CREATE_TABLES_BY_LIST @INCLUDE_TABLES

###################################################################################################################
*/


/*
###################################################################################################################
===================================================================================================================
Code Description: 
-------------------------------------------------------------------------------------------------------------------
This Code is to create a new table on APS (delete the previous version if exists. Run created script on APS
*******************************************************************************************************************
USE DMV 
GO

SET NOCOUNT ON
GO

IF OBJECT_ID('tempdb..#uf_TitleCase') IS NOT NULL DROP PROC #uf_TitleCase
GO

CREATE PROC #uf_TitleCase @Text [Varchar](8000), @Ret Varchar(8000) OUT 
AS
Begin  

	Declare @Reset Bit = 1;
	DECLARE @i Int = 2; -- Start checking from 2-nd letter - first should be title
	Declare @c Char(1);
	SET @Ret = '';

	If @Text Is Null
		Return -1;

	DECLARE @IsT BIT = 0;
	WHILE (@i <= Len(@Text))
	Begin
		Set @c = Substring(@Text, @i, 1)
		IF (ASCII(@c) BETWEEN 97 AND 122) SET @IsT = 1

		SET @i = @i + 1

		IF @IsT = 1 BREAK

	END


	IF @IsT = 0
		SET @Text = LOWER(@Text)

	SET @i = 1;

	While (@i <= Len(@Text))
	Begin
		Set @c = Substring(@Text, @i, 1)
		Set @Ret = @Ret + Case When @Reset = 1 Then Upper(@c) Else Lower(@c) End
		Set @Reset = Case When @c Like '[a-z]' Then 0 Else 1 End
		Set @i = @i + 1
	End

	SET @Ret = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(@Ret,
		'By','By'),'HV','HV'),'ID','ID'),'In','In'),'Is','Is'),'No','No'),'Of','Of'),'Or','Or'),'PK','PK'),'To','To'),'Acc','Acc'),'Act','Act'),'Add','Add'),'Adj','Adj'),'AIP','AIP'),'Amt','Amt'),'And','And'),'Bad','Bad'),'Ban','Ban'),'BOS','BOS'),'Cnt','Cnt'),'CSV','CSV'),'Cut','Cut'),'Day','Day'),'DMV','DMV'),'DPS','DPS'),'Due','Due'),'EIP','EIP'),'End','End'),'Enh','Enh'),'Fee','Fee'),'FK_','FK_'),'FTP','FTP'),'Hex','Hex'),'ICN','ICN'),'IDX','IDX'),'Img','Img'),'INX','INX'),'IOP','IOP'),'IPS','IPS'),'IX_','IX_'),'Key','Key'),'Lic','Lic'),'Log','Log'),'Map','Map'),'MIR','MIR'),'New','New'),'NNP','NNP'),'Non','Non'),'Num','Num'),'OCR','OCR'),'Out','Out'),'Own','Own'),'Pay','Pay'),'PBM','PBM'),'Raw','Raw'),'Ref','Ref'),'Reg','Reg'),'Rev','Rev'),'ROI','ROI'),'Seq','Seq'),'Sig','Sig'),'SSN','SSN'),'Tag','Tag'),'Tax','Tax'),'Top','Top'),'TP_','TP_'),'TSA','TSA'),'Txn','Txn'),'UQ_','UQ_'),'UTC','UTC'),'VCF','VCF'),'VIN','VIN'),'VIP','VIP'),'VRB','VRB'),'VSR','VSR'),'Web','Web'),'Zip','Zip'),'ALPR','ALPR'),'Attr','Attr'),'Auto','Auto'),'Axle','Axle'),'Bill','Bill'),'Body','Body'),'Call','Call'),'Case','Case'),'Cash','Cash'),'City','City'),'Clos','Clos'),'Code','Code'),'Coll','Coll'),'Comm','Comm'),'Cust','Cust'),'Data','Data'),'Date','Date'),'Desc','Desc'),'Down','Down'),'Driv','Driv'),'Effe','Effe'),'Exit','Exit'),'File','File'),'Flag','Flag'),'Hist','Hist'),'Hold','Hold'),'Home','Home'),'Host','Host'),'Info','Info'),'Item','Item'),'JSON','JSON'),'Lane','Lane'),'Last','Last'),'Left','Left'),'Line','Line'),'List','List'),'Load','Load'),'Look','Look'),'Mail','Mail'),'Main','Main'),'Make','Make'),'Mark','Mark'),'Mode','Mode'),'MST_','MST_'),'Name','Name'),'NIX_','NIX_'),'Note','Note'),'NTTA','NTTA'),'Paid','Paid'),'Path','Path'),'Phon','Phon'),'Plan','Plan'),'Plus','Plus'),'Port','Port'),'Post','Post'),'Prev','Prev'),'Quer','Quer'),'Rate','Rate'),'Read','Read'),'Role','Role'),'Self','Self'),'Send','Send'),'Sent','Sent'),'Ship','Ship'),'Size','Size'),'Step','Step'),'Term','Term'),'Time','Time'),'Toll','Toll'),'Tran','Tran'),'Trip','Trip'),'Type','Type'),'User','User'),'With','With'),'Work','Work'),'Year','Year'),'Activ','Activ'),'Admin','Admin'),'Agenc','Agenc'),'Alert','Alert'),'Alias','Alias'),'Batch','Batch'),'Blind','Blind'),'Block','Block'),'Check','Check'),'Citat','Citat'),'Class','Class'),'Color','Color'),'Count','Count'),'Court','Court'),'Creat','Creat'),'Cycle','Cycle'),'Email','Email'),'Entry','Entry'),'Error','Error'),'Event','Event'),'Expir','Expir'),'First','First'),'Float','Float'),'Group','Group'),'Horiz','Horiz'),'Ident','Ident'),'Image','Image'),'Index','Index'),'Langu','Langu'),'Major','Major'),'Match','Match'),'Minor','Minor'),'Modif','Modif'),'Plate','Plate'),'Plaza','Plaza'),'Print','Print'),'Prior','Prior'),'Purch','Purch'),'Queue','Queue'),'Raise','Raise'),'Right','Right'),'Setup','Setup'),'Shift','Shift'),'Short','Short'),'Speed','Speed'),'Spons','Spons'),'Stage','Stage'),
		'Stand','Stand'),'Start','Start'),'STAT_','STAT_'),'State','State'),'Style','Style'),'Super','Super'),'Surve','Surve'),'Table','Table'),'Title','Title'),'TxDot','TxDot'),'Updat','Updat'),'Usage','Usage'),'Valid','Valid'),'Value','Value'),'Verif','Verif'),'Video','Video'),'VToll','VToll'),'Waive','Waive'),'Write','Write'),'Action','Action'),'Amount','Amount'),'Appear','Appear'),'Approv','Approv'),'Assign','Assign'),'Bottom','Bottom'),'Bright','Bright'),'Calcul','Calcul'),'Change','Change'),'Charge','Charge'),'Confid','Confid'),'Config','Config'),'Credit','Credit'),'Detail','Detail'),'Direct','Direct'),'DocMgr','DocMgr'),'Enable','Enable'),'Ground','Ground'),'Handle','Handle'),'Header','Header'),'Height','Height'),'Histor','Histor'),'Invoic','Invoic'),'Length','Length'),'Letter','Letter'),'Manual','Manual'),'Messag','Messag'),'Method','Method'),'Middle','Middle'),'Normal','Normal'),'Option','Option'),'Parent','Parent'),'Period','Period'),'Portal','Portal'),'Prefer','Prefer'),'Prefix','Prefix'),'Primar','Primar'),'Protec','Protec'),'Qualif','Qualif'),'Reason','Reason'),'Rebill','Rebill'),'Record','Record'),'Reject','Reject'),'Remain','Remain'),'Remark','Remark'),'Renter','Renter'),'Report','Report'),'Result','Result'),'Retail','Retail'),'Return','Return'),'Review','Review'),'Serial','Serial'),'Source','Source'),'Status','Status'),'Street','Street'),'Submit','Submit'),'Suffix','Suffix'),'Syntax','Syntax'),'System','System'),'Unread','Unread'),'Upload','Upload'),'Violat','Violat'),'Volume','Volume'),'Account','Account'),'Balance','Balance'),'Carrier','Carrier'),'Categor','Categor'),'Channel','Channel'),'Complet','Complet'),'Consume','Consume'),'Contact','Contact'),'Correct','Correct'),'Default','Default'),'Deliver','Deliver'),'Deposit','Deposit'),'Dismiss','Dismiss'),'Display','Display'),'Facilit','Facilit'),'Frequen','Frequen'),'Generat','Generat'),'Hearing','Hearing'),'Inbound','Inbound'),'Indicat','Indicat'),'Invalid','Invalid'),'Mailing','Mailing'),'Malform','Malform'),'Manager','Manager'),'Misread','Misread'),'Notific','Notific'),'Parking','Parking'),'Pending','Pending'),'Premium','Premium'),'Process','Process'),'Receipt','Receipt'),'Receive','Receive'),'Renewal','Renewal'),'Replace','Replace'),'Request','Request'),'Require','Require'),'Resolve','Resolve'),'Service','Service'),'Sponsor','Sponsor'),'Storage','Storage'),'Summary','Summary'),'Tracker','Tracker'),'Trigger','Trigger'),'Trooper','Trooper'),'Unmatch','Unmatch'),'Vehicle','Vehicle'),'Visible','Visible'),'Authorit','Authorit'),'Conflict','Conflict'),'Contrast','Contrast'),'Decision','Decision'),'Discount','Discount'),'Download','Download'),'Eligible','Eligible'),'Inventor','Inventor'),'Loaction','Loaction'),'Location','Location'),'Metadata','Metadata'),'Normalis','Normalis'),'Position','Position'),'Response','Response'),'Sequence','Sequence'),'Template','Template'),'Terminat','Terminat'),'Vertical','Vertical'),
		'Affidavit','Affidavit'),'Determina','Determina'),'Exception','Exception'),'Excessive','Excessive'),'Registrat','Registrat'),'Signature','Signature'),'Subscribe','Subscribe'),'Surrender','Surrender'),'Telephone','Telephone'),'Threshold','Threshold'),'Bankruptcy','Bankruptcy'),'Correspond','Correspond'),'Processing','Processing'),'Disposition','Disposition'),'Outstanding','Outstanding'),'Transaction','Transaction'),'Jurisdiction','Jurisdiction'),'Representativ','Representativ')

	Return 0

End
GO


IF OBJECT_ID('tempdb..#PRINT_LONG_VARIABLE_VALUE') IS NOT NULL DROP PROC #PRINT_LONG_VARIABLE_VALUE
GO

CREATE PROC #PRINT_LONG_VARIABLE_VALUE @sql [VARCHAR](MAX) AS
BEGIN
	DECLARE @ST_R INT = 0
	DECLARE @CUT_LEN INT = 8000
	DECLARE @CUT_R INT = @CUT_LEN
	DECLARE @SQL_PART VARCHAR(8000)
	DECLARE @LONG INT = LEN(@sql)
	DECLARE @SQL_PART_REV VARCHAR(MAX)
	DECLARE @LAST_ENTER_SYMBOL_NBR INT

	WHILE (@ST_R <= @LONG)
	BEGIN
		SET @SQL_PART = SUBSTRING(@sql, @ST_R, @CUT_LEN)
		SET @CUT_R = LEN(@SQL_PART) 
		-- Every time we print something - it prints on the next row
		-- it means, if we stopped in the middle of the row the next part of this row will be on the next row - we don't want this

		IF @ST_R + @CUT_LEN < @LONG -- it does not metter if this is the last part
		BEGIN
			SET @SQL_PART_REV = REVERSE(@SQL_PART)

			-- We are looking for the last "ENTER" symbol in our string part and cutting out everything after this - it will go to the next part
			-- To find it better to reverse the string
			SET @LAST_ENTER_SYMBOL_NBR = CHARINDEX(CHAR(13),@SQL_PART_REV)

			IF @LAST_ENTER_SYMBOL_NBR > 0
			BEGIN
				SET @SQL_PART = LEFT(@SQL_PART, @CUT_R - @LAST_ENTER_SYMBOL_NBR)
				-- Now should set a new length of the string part plus Enter symbol we don't want to have again
				SET @CUT_R = @CUT_R - @LAST_ENTER_SYMBOL_NBR + 1
			END
		END

		PRINT @SQL_PART
		-- Set beginning of the next part as the last part beginning + length of string part + next sybmol (+1) 
		SET @ST_R = @ST_R + @CUT_R + 1
	END
END
GO

IF OBJECT_ID('tempdb..#GET_INDEX_STRING') IS NOT NULL DROP PROC #GET_INDEX_STRING
GO
CREATE PROC #GET_INDEX_STRING @SCHEMA_NAME [VARCHAR](100), @TABLE [VARCHAR](100),@SQL_STRING [VARCHAR](MAX) OUT AS

BEGIN
	DECLARE @TABLE_INDEX VARCHAR(100)

	SELECT @TABLE_INDEX = I.type_desc
	FROM sys.tables as t
	JOIN sys.indexes AS I ON I.object_id = t.object_id
	WHERE t.name = @TABLE AND I.index_id <=1

	IF @TABLE_INDEX = 'CLUSTERED'
	BEGIN
		WITH CTE AS
		(
			SELECT C.column_id, u.name AS column_name, CASE WHEN C.is_descending_key = 1 THEN ' DESC' ELSE ' ASC' END AS column_Order
				, ROW_NUMBER() OVER (ORDER BY C.column_id) AS RN 
			FROM sys.tables as t
			JOIN sys.schemas as S ON S.SCHEMA_ID = t.SCHEMA_ID AND S.name = @SCHEMA_NAME
			JOIN sys.indexes AS I ON I.object_id = t.object_id AND I.index_id <=1
			JOIN sys.index_columns AS C ON C.object_id = t.object_id AND C.index_id = I.index_id
			JOIN sys.columns AS u ON u.column_id = C.column_id AND u.object_id = t.object_id
			WHERE t.name = @TABLE
		)
		, CTE_JOINT AS 
		(
			SELECT
				' [' + CTE1.column_name + ']' AS INDEX_1st_COLUMN
				, ' [' + CTE1.column_name + ']' + CTE1.column_Order
				+ ISNULL(', ['+ CTE2.column_name + ']' + CTE2.column_Order, '')
				+ ISNULL(', ['+ CTE3.column_name + ']' + CTE3.column_Order, '')
				+ ISNULL(', ['+ CTE4.column_name + ']' + CTE4.column_Order, '')
				+ ISNULL(', ['+ CTE5.column_name + ']' + CTE5.column_Order, '')
				+ ISNULL(', ['+ CTE6.column_name + ']' + CTE6.column_Order, '')
				+ ISNULL(', ['+ CTE7.column_name + ']' + CTE7.column_Order, '')
				+ ISNULL(', ['+ CTE8.column_name + ']' + CTE8.column_Order, '')
				+ ISNULL(', ['+ CTE9.column_name + ']' + CTE9.column_Order, '')
				+ ISNULL(', ['+ CTE10.column_name + ']' + CTE10.column_Order, '') + ' ' AS INDEX_COULUMNS
			FROM CTE AS CTE1
			LEFT JOIN CTE AS CTE2 ON  CTE2.RN = 2
			LEFT JOIN CTE AS CTE3 ON  CTE3.RN = 3
			LEFT JOIN CTE AS CTE4 ON  CTE4.RN = 4
			LEFT JOIN CTE AS CTE5 ON  CTE5.RN = 5
			LEFT JOIN CTE AS CTE6 ON  CTE6.RN = 6
			LEFT JOIN CTE AS CTE7 ON  CTE7.RN = 7
			LEFT JOIN CTE AS CTE8 ON  CTE8.RN = 8
			LEFT JOIN CTE AS CTE9 ON  CTE9.RN = 9
			LEFT JOIN CTE AS CTE10 ON CTE10.RN = 10
			WHERE CTE1.RN = 1
		)
		SELECT TOP 1
			@SQL_STRING = @TABLE_INDEX + ' INDEX (' + INDEX_COULUMNS + '), DISTRIBUTION = HASH(' + INDEX_1st_COLUMN + ')'
		FROM CTE_JOINT
	END
	ELSE
	BEGIN
		IF @TABLE_INDEX = 'CLUSTERED COLUMNSTORE'
		BEGIN
			SET @SQL_STRING = @TABLE_INDEX + ' INDEX, DISTRIBUTION = ROUND_ROBIN'
		END
		ELSE
		BEGIN
			SET @SQL_STRING = @TABLE_INDEX
		END
		--WITH (CLUSTERED INDEX ( [ACCT_ID] ASC , [ACCT_TAG_SEQ] ASC ), DISTRIBUTION = HASH([ACCT_ID]));
	END
END
GO

IF OBJECT_ID('tempdb..#GET_CREATE_STATISTICS_SQL') IS NOT NULL DROP PROC #GET_CREATE_STATISTICS_SQL
GO
CREATE PROC #GET_CREATE_STATISTICS_SQL @SCHEMA_NAME [VARCHAR](100), @TABLE [VARCHAR](100),@SQL_STRING [VARCHAR](MAX) OUT AS
BEGIN
	--DECLARE @SCHEMA_NAME [VARCHAR](100) = 'TollPlus', @TABLE [VARCHAR](100) = 'Tp_Customer_Balances', @SQL_STRING [VARCHAR](MAX)
	
	IF OBJECT_ID('TempDB..#TABLE_STATS') IS NOT NULL DROP TABLE #TABLE_STATS;


	WITH CTE AS
	(
		-- Statistic for foreign key
		SELECT 
			s.[name] AS schemaName, 
			OBJECT_NAME(A.PARENT_OBJECT_ID) AS [table_name], 
			'STAT_' + F.name AS [stats_name], 
			B.name AS [column_name], 
			ROW_NUMBER() OVER (PARTITION BY F.name ORDER BY b.column_id) AS RN
		FROM SYS.FOREIGN_KEY_COLUMNS A 
		JOIN sys.foreign_keys f on f.object_id = a.constraint_object_id
		JOIN sys.schemas S	ON S.schema_id = f.schema_id AND S.name = @SCHEMA_NAME
		JOIN SYS.COLUMNS B ON A.PARENT_COLUMN_ID = B.COLUMN_ID 
			AND A.PARENT_OBJECT_ID = B.OBJECT_ID 
		WHERE OBJECT_NAME(A.PARENT_OBJECT_ID) = @TABLE

		UNION ALL

		-- Statistics for nonclustered indexes - instead of create indexes
		SELECT 
			s.[name] AS schemaName, 
			t.name AS [table_name], 
			'STAT_' + I.name AS [stats_name], 
			u.name AS column_name,
			ROW_NUMBER() OVER (PARTITION BY I.name ORDER BY C.column_id) AS RN 
		FROM sys.tables as t
		JOIN sys.schemas as S ON S.SCHEMA_ID = t.SCHEMA_ID AND S.name = @SCHEMA_NAME
		JOIN sys.indexes AS I ON I.object_id = t.object_id AND I.index_id > 1
		JOIN sys.index_columns AS C ON C.object_id = t.object_id AND C.index_id = I.index_id
		JOIN sys.columns AS u ON u.column_id = C.column_id AND u.object_id = t.object_id
		WHERE t.name = @TABLE

		UNION ALL

		-- User-created stats
		SELECT
			s.[name] AS schemaName
			,t.[name] AS [table_name]
			,'STAT_' + ss.[name] AS [stats_name]
			,c.name AS [column_name]
			, ROW_NUMBER() OVER (PARTITION BY ss.[name] ORDER BY C.column_id) AS RN 
		FROM        sys.schemas s
		JOIN        sys.tables t                    ON      t.[schema_id]  = s.[schema_id]
		JOIN		sys.stats ss					ON		ss.[object_id] = t.[object_id] AND ss.user_created = 1
		JOIN		sys.stats_columns sc			ON		sc.[object_id] = t.[object_id] AND ss.stats_id = sc.stats_id
		JOIN        sys.columns c                   ON      t.[object_id]  = c.[object_id] AND sc.column_id  = c.column_id
		WHERE  t.[name] = @TABLE
	)
	, CTE_JOINT AS 
	(
		SELECT 
			CTE1.schemaName
			,CTE1.table_name
			,CTE1.stats_name
			, '[' + CTE1.column_name + ']'
			+ ISNULL(', ['+ CTE2.column_name + ']', '')
			+ ISNULL(', ['+ CTE3.column_name + ']', '')
			+ ISNULL(', ['+ CTE4.column_name + ']', '')
			+ ISNULL(', ['+ CTE5.column_name + ']', '')
			+ ISNULL(', ['+ CTE6.column_name + ']', '')
			+ ISNULL(', ['+ CTE7.column_name + ']', '')
			+ ISNULL(', ['+ CTE8.column_name + ']', '')
			+ ISNULL(', ['+ CTE9.column_name + ']', '')
			+ ISNULL(', ['+ CTE10.column_name + ']', '') AS stats_col 
		FROM CTE AS CTE1
		LEFT JOIN CTE AS CTE2 ON CTE2.stats_name = CTE1.stats_name AND CTE2.RN = 2
		LEFT JOIN CTE AS CTE3 ON CTE3.stats_name = CTE1.stats_name AND CTE3.RN = 3
		LEFT JOIN CTE AS CTE4 ON CTE4.stats_name = CTE1.stats_name AND CTE4.RN = 4
		LEFT JOIN CTE AS CTE5 ON CTE5.stats_name = CTE1.stats_name AND CTE5.RN = 5
		LEFT JOIN CTE AS CTE6 ON CTE6.stats_name = CTE1.stats_name AND CTE6.RN = 6
		LEFT JOIN CTE AS CTE7 ON CTE7.stats_name = CTE1.stats_name AND CTE7.RN = 7
		LEFT JOIN CTE AS CTE8 ON CTE8.stats_name = CTE1.stats_name AND CTE8.RN = 8
		LEFT JOIN CTE AS CTE9 ON CTE9.stats_name = CTE1.stats_name AND CTE9.RN = 9
		LEFT JOIN CTE AS CTE10 ON CTE10.stats_name = CTE1.stats_name AND CTE10.RN = 10
		WHERE CTE1.RN = 1
	)
	SELECT 
			schemaName
			,table_name
			,stats_name
			,stats_col
			,'CREATE STATISTICS [' + stats_name + '] ON ' + @SCHEMA_NAME + '.[' + @TABLE + '] (' + stats_col + ');' AS SQL_STRING
			, ROW_NUMBER() OVER(ORDER BY stats_name) AS RN
	INTO #TABLE_STATS
	FROM CTE_JOINT

	--SELECT * FROM #TABLE_STATS

	DECLARE @NUM_OF_COLUMNS INT
	DECLARE @THIS_SQL_STRING VARCHAR(MAX) = '', @Title_SQL_String VARCHAR(MAX) = ''
	DECLARE @INDICAT SMALLINT = 1

	SET @SQL_STRING  = ''

	SELECT @NUM_OF_COLUMNS = MAX(RN) FROM #TABLE_STATS
	SET @INDICAT = 1
	-- If only 1 period (and 1 partition) - @PART_RANGES is empty
	WHILE (@INDICAT <= @NUM_OF_COLUMNS)
	BEGIN
		
		SELECT @THIS_SQL_STRING = SQL_STRING FROM #TABLE_STATS WHERE RN = @INDICAT --ORDER BY stats_name
		EXEC #uf_TitleCase @THIS_SQL_STRING, @Title_SQL_String OUTPUT

		SET @SQL_STRING = @SQL_STRING + char(13) + char(9) + REPLACE(REPLACE(@Title_SQL_String,'CREATE STATISTICS','CREATE STATISTICS'), ' ON ', ' ON ')

		SET @INDICAT += 1

	END

	--PRINT @SQL_STRING
END
go

IF OBJECT_ID('tempdb..#GET_CREATE_TABLE_SQL') IS NOT NULL DROP PROC #GET_CREATE_TABLE_SQL
GO
CREATE PROC #GET_CREATE_TABLE_SQL @SCHEMA_NAME [VARCHAR](100), @TABLE_NAME [VARCHAR](100) AS 

BEGIN

	DECLARE @SQL_STRING VARCHAR(MAX) = '';
	DECLARE @TitleTableName VARCHAR(100)
	DECLARE @TitleSchemaName VARCHAR(100)
	EXEC #uf_TitleCase @TABLE_NAME, @TitleTableName OUTPUT
	EXEC #uf_TitleCase @SCHEMA_NAME, @TitleSchemaName OUTPUT
	SELECT @TitleSchemaName = REPLACE(@TitleSchemaName,'TER','TER')

	DECLARE @NUM_OF_COLUMNS INT
	DECLARE @TABLE_DISTRIBUTION VARCHAR(100) = ''
	DECLARE @TABLE_INDEX VARCHAR(MAX) = ''
	--DECLARE @NEW_TABLE_NAME VARCHAR(100) = @TABLE_NAME + '_NEW_SET'

	--EXEC EDW_RITE.DBO.GET_DISRTIBUTION_STRING @SCHEMA_NAME, @TABLE_NAME, @TABLE_DISTRIBUTION OUTPUT 

	EXEC #GET_INDEX_STRING @SCHEMA_NAME, @TABLE_NAME, @TABLE_INDEX OUTPUT 

	IF OBJECT_ID('tempdb..#TABLE_COLUMNS') IS NOT NULL DROP TABLE #TABLE_COLUMNS;
	SELECT      s.name AS SchemaName, t.name AS TableName, c.name AS ColumnName, C.column_id, TYPE_NAME(c.system_type_id) AS ColumnType, c.max_length, c.PRECISION,c.scale,C.is_nullable, 
				ROW_NUMBER() OVER(ORDER BY C.column_id) AS RN
	INTO #TABLE_COLUMNS
	FROM        sys.columns c
	JOIN        sys.tables  t   ON c.object_id = t.object_id
	JOIN		sys.schemas S	ON S.schema_id = t.schema_id AND S.name = @SCHEMA_NAME
	WHERE       t.name = @TABLE_NAME

	--:: Alert check
	IF EXISTS (SELECT * FROM #TABLE_COLUMNS WHERE ColumnType IN ('IMAGE','BINARY','VARBINARY')) SELECT * FROM #TABLE_COLUMNS WHERE ColumnType IN ('IMAGE','BINARY','VARBINARY')
	IF EXISTS (SELECT * FROM #TABLE_COLUMNS WHERE ColumnType IN ('TEXT','NTEXT','NVARCHAR','MONEY')) SELECT * FROM #TABLE_COLUMNS WHERE ColumnType IN ('TEXT','NTEXT','NVARCHAR', 'NCHAR','MONEY')

	--PRINT 'GOT NEW_TABLE_COLUMNS'

	SELECT @NUM_OF_COLUMNS = MAX(RN) FROM #TABLE_COLUMNS

	DECLARE @SELECT_String VARCHAR(MAX) = '  '
	--DECLARE @THIS_SELECT_String VARCHAR(MAX) = ''
	DECLARE @Delimiter VARCHAR(3) = ''
	DECLARE @INDICAT SMALLINT = 1
	DECLARE @ColumnName Varchar(100)
	DECLARE @ColumnType Varchar(100)
	DECLARE @TitleCName Varchar(100)
	-- If only 1 period (and 1 partition) - @PART_RANGES is empty

	WHILE (@INDICAT <= @NUM_OF_COLUMNS)
	BEGIN
		
		SELECT
			@ColumnName = M.ColumnName,  
			@ColumnType = CASE 
				WHEN M.ColumnType = 'IMAGE' THEN 'VARBINARY'
				WHEN M.ColumnType = 'XML' THEN 'VARCHAR'
				WHEN M.ColumnType = 'TEXT' THEN 'VARCHAR'
				WHEN M.ColumnType = 'NTEXT' THEN 'VARCHAR'
				WHEN M.ColumnType = 'NVARCHAR' THEN 'VARCHAR'
				WHEN M.ColumnType = 'NUMERIC' THEN 'DECIMAL'
				WHEN M.ColumnType = 'Money' THEN 'DECIMAL(19,2)'
				WHEN M.ColumnType = 'DATETIME' THEN 'DATETIME2(3)'
				ELSE UPPER(M.ColumnType)
			END +
			CASE 
				WHEN M.ColumnType = 'IMAGE' THEN '(MAX)'
				WHEN M.ColumnType = 'XML' THEN '(8000)'
				WHEN M.ColumnType = 'TEXT' THEN '(8000)'
				WHEN M.ColumnType = 'NTEXT' THEN '(8000)'
				WHEN M.ColumnType = 'DATETIME2' THEN '(' + CAST(m.scale AS VARCHAR) +')'
				WHEN M.ColumnType IN ('BINARY','VARBINARY') THEN '(' + ISNULL(NULLIF(CAST(m.max_length AS VARCHAR),'-1'),'8000') +')'
				WHEN M.ColumnType IN ('DECIMAL','NUMERIC') THEN '(' + CAST(m.PRECISION AS VARCHAR) + ',' + CAST(m.scale AS VARCHAR) +')'
				WHEN M.ColumnType LIKE '%CHAR' THEN '(' + ISNULL(NULLIF(CAST(m.max_length AS VARCHAR),'-1'),'8000') +')'
				ELSE ''
			END + CHAR(9) + CASE WHEN m.is_nullable = 0 THEN ' NOT' ELSE '' END + ' NULL'
		FROM #TABLE_COLUMNS M
		WHERE M.RN = @INDICAT AND M.ColumnType NOT IN ('IMAGE','BINARY','VARBINARY') 

		EXEC #uf_TitleCase @ColumnName, @TitleCName OUTPUT
		
		IF @ColumnName IS NOT NULL
		BEGIN
			SET @SELECT_String = @SELECT_String +  + CHAR(13) + CHAR(10) + CHAR(9) + CHAR(9) + @Delimiter + '[' + @TitleCName + '] ' + @ColumnType

			SET	@Delimiter = ', '
		END
		SET @INDICAT += 1

	END

	SET @SELECT_String = @SELECT_String + '
		, [LND_UpdateDate] DATETIME2(3) NULL
		, [LND_UpdateType] VARCHAR(1) NULL'

	DECLARE @TABLE_STATISTICS VARCHAR(MAX) = ''
	EXEC #GET_CREATE_STATISTICS_SQL @TitleSchemaName, @TitleTableName, @TABLE_STATISTICS OUTPUT 
	
	SET @TABLE_STATISTICS = @TABLE_STATISTICS + '
	CREATE STATISTICS [STAT_' + @TitleTableName + '_LND_UpdateDate] ON ' + @TitleSchemaName + '.[' + @TitleTableName + '] (LND_UpdateDate);'

	-- Add to statistics UpdatedDate and distribution culumn (first column fron clustered index)
	IF CHARINDEX('[UpdatedDate]',@SELECT_String) > 0 -- If this column exists - create statistics for it.
	BEGIN
		SET @TABLE_STATISTICS = @TABLE_STATISTICS + '
	CREATE STATISTICS [STAT_' + @TitleTableName + '_UpdatedDate] ON ' + @TitleSchemaName + '.[' + @TitleTableName + '] (UpdatedDate);'
	END 

	SET @SQL_STRING = '
	IF OBJECT_ID(''' + @TitleSchemaName + '.' + @TitleTableName + ''') IS NOT NULL			DROP TABLE ' + @TitleSchemaName + '.' + @TitleTableName + ';

	CREATE TABLE ' + @TitleSchemaName + '.' + @TitleTableName + ' (' + @SELECT_String + ') 
	WITH (' + @TABLE_INDEX + ')'

	IF OBJECT_ID('tempdb..#TABLE_COLUMNS') IS NOT NULL DROP TABLE #TABLE_COLUMNS;

	EXEC #PRINT_LONG_VARIABLE_VALUE @SQL_STRING
	EXEC #PRINT_LONG_VARIABLE_VALUE @TABLE_STATISTICS

END
GO


IF OBJECT_ID('tempdb..#GET_CREATE_TABLES_BY_LIST') IS NOT NULL DROP PROC #GET_CREATE_TABLES_BY_LIST
GO
CREATE PROC #GET_CREATE_TABLES_BY_LIST @TABLE_LIST VARCHAR(MAX) AS --,@SQL_STRING [VARCHAR](MAX) OUT AS
BEGIN

	DECLARE @NUM_OF_TABLES INT
	DECLARE @TABLE_NAME VARCHAR(100)
	DECLARE @SCHEMA_NAME VARCHAR(100)
	DECLARE @TitleTableName VARCHAR(100)
	DECLARE @TitleSchemaName VARCHAR(100)

	IF OBJECT_ID('tempdb..#SCHEMA_TABLES') IS NOT NULL DROP TABLE #SCHEMA_TABLES;

	SELECT SchemaName,TableName,FULL_NAME,
			ROW_NUMBER() OVER(ORDER BY SchemaName, TableName) AS RN
	INTO #SCHEMA_TABLES
	FROM
		(
			SELECT      s.name AS SchemaName, t.name AS TableName, '[' + s.name + '].[' + t.name + ']' AS FULL_NAME--, '[HISTORY].[' + H.TableName + ']' AS History_TableName, 
			FROM        sys.tables  t   
			JOIN		sys.schemas S	ON S.schema_id = t.schema_id
		) A
	WHERE CHARINDEX(A.FULL_NAME,@TABLE_LIST) > 0

	--SELECT * FROM #SCHEMA_TABLES

	SELECT @NUM_OF_TABLES = MAX(RN) FROM #SCHEMA_TABLES

	DECLARE @INDICAT SMALLINT = 1
	-- If only 1 period (and 1 partition) - @PART_RANGES is empty

	WHILE (@INDICAT <= @NUM_OF_TABLES)
	BEGIN
		
		SELECT @TABLE_NAME = TableName, @SCHEMA_NAME = SchemaName--, @FULL_NAME = FULL_NAME--, @History_TableName = History_TableName
		FROM #SCHEMA_TABLES M
		WHERE M.RN = @INDICAT --AND CHARINDEX(M.FULL_NAME,@EXCLUDE_TABLES) = 0
		
		IF @TABLE_NAME IS NOT NULL
		BEGIN

			EXEC #uf_TitleCase @TABLE_NAME, @TitleTableName OUTPUT
			EXEC #uf_TitleCase @SCHEMA_NAME, @TitleSchemaName OUTPUT
			SELECT @TitleSchemaName = REPLACE(@TitleSchemaName,'TER','TER')
			--SET @TitleFullName = '[' + @SCHEMA_NAME + '].' + '[' + @TitleTableName + ']'

			EXEC #GET_CREATE_TABLE_SQL @TitleSchemaName, @TitleTableName --, @SQL_SELECT OUTPUT, @SQL_STATS OUTPUT;

		END
		SET @INDICAT += 1
	END

END
GO

DECLARE @INCLUDE_TABLES VARCHAR(MAX)

SET @INCLUDE_TABLES = '
[Dmv].[eTagPlatesA]
[Dmv].[HardLicensePlatesA]'
EXEC #GET_CREATE_TABLES_BY_LIST @INCLUDE_TABLES


###################################################################################################################
*/


/*
###################################################################################################################
===================================================================================================================
Code Description: 
-------------------------------------------------------------------------------------------------------------------
This for call from Data Manager on TBOS database
Move Data from Source (TBOS) to Destination (APS LND_TBOS) to table Utility.TBOS_TableMetadata_Source
3 Processes should be there - first one use flag "Cleen the table", for next - do not cleen table.
*******************************************************************************************************************

###################################################################################################################

DECLARE @INCLUDE_TABLES VARCHAR(MAX)
SET @INCLUDE_TABLES = '
[COURT].[AdminHearing]
[COURT].[Counties]
[COURT].[Courts]
[COURT].[PlazaCourts]
[CASEMANAGER].[PmCase]
[CASEMANAGER].[PmCaseTypes]
[TER].[PaymentPlans]
[TER].[PaymentPlanTerms]
[TER].[PaymentPlanViolator]
[TER].[HvStatusLookup]
[TER].[HabitualViolators]
[TER].[ViolatorCollectionsOutbound]
[TER].[VehicleRegBlocks]
[TER].[VRBRequestDMV]
[TER].[DPSBanActions]
[TER].[VehicleBan]
[TER].[BanActions]
[TER].[CitationNumberSequence]
[TER].[CollectionAgencies]
[TER].[CollectionAgencyCounties]
[TER].[FailuretoPayCitations]
[TER].[HVEligibleTransactions]
[TER].[ViolatorCollectionsAgencyTracker]
[TER].[ViolatorCollectionsInbound]
[FINANCE].[ADJUSTMENT_LINEITEMS]
[FINANCE].[ADJUSTMENTS]
[FINANCE].[CustomerPayments]
[FINANCE].[PAYMENTTXN_LINEITEMS]
[FINANCE].[PAYMENTTXNS]
[NOTIFICATIONS].[CustomerNotificationQueue]
[NOTIFICATIONS].[ConfigAlertTypeAlertChannels]
[NOTIFICATIONS].[ALERTCHANNELS]
[NOTIFICATIONS].[ALERTTYPES]
[DOCMGR].[TP_CUSTOMER_OUTBOUNDCOMMUNICATIONS]
[TOLLPLUS].[REF_LOOKUPTYPECODES_HIERARCHY]
[TOLLPLUS].[INVOICE_HEADER]
[TOLLPLUS].[INVOICE_LINEITEMS]
[TOLLPLUS].[ICN]
[TOLLPLUS].[TP_BANKRUPTCY_FILING]
[TOLLPLUS].[TP_VIOLATEDTRIPS]
[TOLLPLUS].[TP_CUSTOMER_VEHICLES]
[TOLLPLUS].[TP_CUSTOMER_CONTACTS]
[TOLLPLUS].[TP_CUSTOMER_ATTRIBUTES]
[TOLLPLUS].[TP_CUSTOMER_ADDRESSES]
[TOLLPLUS].[TP_CUSTOMER_PHONES]
[TOLLPLUS].[TP_CUSTOMER_EMAILS]
[TOLLPLUS].[TP_CUSTOMER_BALANCES]
[TOLLPLUS].[TP_CUSTOMER_FLAGS]
[TOLLPLUS].[TP_CUSTOMER_INTERNAL_USERS]
[TOLLPLUS].[TP_CUSTOMER_TAGS]
[TOLLPLUS].[TP_CUSTOMER_TRIP_CHARGES_TRACKER]
[TOLLPLUS].[TP_CUSTOMER_TRIP_RECEIPTS_TRACKER]
[TOLLPLUS].[TP_CUSTOMER_VEHICLE_TAGS]
[TOLLPLUS].[TP_CUSTOMERS]
[TOLLPLUS].[TP_CUSTOMERTRIPS]
[TOLLPLUS].[TP_CUSTOMERTRIPSTATUSTRACKER]
[TOLLPLUS].[TP_TRIPS]
[TOLLPLUS].[TP_VEHICLE_MODELS]
[TOLLPLUS].[TP_VIOLATED_TRIP_CHARGES_TRACKER]
[TOLLPLUS].[TP_VIOLATED_TRIP_RECEIPTS_TRACKER]
[TOLLPLUS].[TP_VIOLATEDTRIPS]
[TOLLPLUS].[TP_VIOLATEDTRIPSTATUSTRACKER]
[TOLLPLUS].[TP_IMAGE_REVIEW_RESULT_IMAGES]
[TOLLPLUS].[TP_IMAGE_REVIEW_RESULTS]
[TOLLPLUS].[TP_EXEMPTED_PLATES]
[TOLLPLUS].[CustomerFlagReferenceLookup]
[TOLLPLUS].[MbsHeader]
[TOLLPLUS].[MbsInvoices]
[TOLLPLUS].[InvoiceAttributes]
[TOLLPLUS].[BankruptcyStatuses]
[TOLLPLUS].[AddressSources]
[TOLLPLUS].[AGENCIES]
[TOLLPLUS].[CaseLinks]
[TOLLPLUS].[Dispositions]
[TOLLPLUS].[DMVExceptionDetails]
[TOLLPLUS].[DMVExceptionQueue]
[TOLLPLUS].[ESCHEATMENT_ELGIBLE_CUSTOMERS]
[TOLLPLUS].[FleetCustomerAttributes]
[TOLLPLUS].[FleetCustomersFileTracker]
[TOLLPLUS].[FleetCustomerVehiclesQueue]
[TOLLPLUS].[ICN_CASH]
[TOLLPLUS].[ICN_ITEMS]
[TOLLPLUS].[ICN_TXNS]
[TOLLPLUS].[ICN_VARIANCE]
[TOLLPLUS].[INVOICE_CHARGES_TRACKER]
[TOLLPLUS].[LANES]
[TOLLPLUS].[LOCATIONS]
[TOLLPLUS].[PLAZA_TYPES]
[TOLLPLUS].[PLAZAS]
[TOLLPLUS].[REF_INVOICE_WORKFLOW_STAGE_FEES]
[TOLLPLUS].[REF_INVOICE_WORKFLOW_STAGES]
[TOLLPLUS].[TRIPSTAGES]
[TOLLPLUS].[TRIPSTATUSES]
[TOLLPLUS].[TXNTYPE_CATEGORIES]
[TOLLPLUS].[UnMatchedTxnsQueue]
[TOLLPLUS].[VEHICLECLASSES]
[TOLLPLUS].[VIOLATION_WORKFLOW]
[TOLLPLUS].[ZipCodes]
[TOLLPLUS].[TP_EXEMPTED_PLATES]
[Court].[CourtJudges]
[Finance].[BANKPAYMENTS]
[Finance].[CHEQUEPAYMENTS]
[IOP].[AGENCIES]
[TollPlus].[REF_FEETYPES]
[Finance].[GL_TXN_LINEITEMS]
[Inventory].[ITEMINVENTORY]
[Inventory].[ITEMINVENTORYLOCATIONS]
[Inventory].[ITEMTYPES]
[IOP].[BOS_IOP_OUTBOUNDTRANSACTIONS]
[IOP].[IopPlates]
[IOP].[IopTags]
[Parking].[ParkingTrips]
[TER].[DPSTrooper]
[TollPlus].[TpFileTracker]
[TollPlus].[LaneCategories]
[Finance].[Adjustments]
[TollPlus].[PlateTypes]
[TollPlus].[TP_TRANSACTION_TYPES]
[TollPlus].[TP_TOLLTXN_REASONCODES]
[TOLLPLUS].[Channels]
[TOLLPLUS].[TP_Transaction_Types]
[TranProcessing].[HostBosFileTracker]
[TranProcessing].[IOPInboundRawTransactions]
[TranProcessing].[NTTAHostBOSFileTracker]
[TranProcessing].[NTTARawTransactions]
[TranProcessing].[TripSource]
[TranProcessing].[TSARawTransactions]
[TranProcessing].[TxnDispositions]
[Finance].[BusInessProcess_TxnTypes_Associations]
[Finance].[BusinessProcesses]
[Finance].[CharTofAccounts]
[Finance].[GL_Transactions]
[Finance].[TxnTypes]
[Finance].[GlDailySummaryByCoaIdBuId]
[TER].[HabitualViolatorStatusTracker]
[TER].[VRBRequestDallas]
[TollPlus].[MbsProcessStatus]
[TollPlus].[Merged_Customers]
[TollPlus].[OperationalLocations]
[TollPlus].[TP_AppLication_Parameters]
[TollPlus].[TP_Customer_AccStatus_Tracker]
[TollPlus].[TP_CustTxns]
[TollPlus].[TP_FileTracker]
[TollPlus].[TP_Invoice_Receipts_Tracker]
[TranProcessing].[RecordTypes]
[TollPlus].[AppTxnTypes] 
[TollPlus].[SubSystems]
[TollPlus].[TP_Customer_Business] 
[TollPlus].[TP_Customer_Plans]
[TollPlus].[Plans]
[FINANCE].[BulkPayments]
[TOLLPLUS].[BOS_IOP_INBOUNDTRANSACTIONS]
[TOLLPLUS].[COLLECTIONS_INBOUND]
[TOLLPLUS].[COLLECTIONS_OUTBOUND]
[TOLLPLUS].[TP_CUSTOMER_TAGS_HISTORY]
[TOLLPLUS].[TP_IMAGEREVIEW]
[TRANPROCESSING].[TSAImageRawTransactions]
'

	;WITH CTE_TABLE_LIST AS
	(
		SELECT      s.name AS SchemaName, t.name AS TableName, '[' + s.name + '].[' + t.name + ']' AS FULL_NAME, t.object_id, 
					ROW_NUMBER() OVER( ORDER BY s.name, t.name) AS RN
		FROM        sys.tables  t   
		JOIN		sys.schemas S	ON S.schema_id = t.schema_id
		WHERE CHARINDEX('[' + s.name + '].[' + t.name + ']',@INCLUDE_TABLES) > 0
	)
	, CTE_Ind_Columns AS
	(
		SELECT 
				T.object_id, C.column_id, u.name AS column_name, CASE WHEN C.is_descending_key = 1 THEN ' DESC' ELSE ' ASC' END AS column_Order, I.type_desc AS TABLE_INDEX
				, ROW_NUMBER() OVER (PARTITION BY T.object_id ORDER BY C.key_ordinal) AS RN 
		FROM CTE_TABLE_LIST as t
		JOIN sys.indexes AS I ON I.object_id = t.object_id AND I.index_id <=1
		JOIN sys.index_columns AS C ON C.object_id = t.object_id AND C.index_id = I.index_id AND C.key_ordinal > 0
		JOIN sys.columns AS u ON u.column_id = C.column_id AND u.object_id = t.object_id
	)
	, CTE_Ind_JOINT AS 
	(
		SELECT
			CTE1.object_id
			, ' [' + CTE1.column_name + ']' AS INDEX_1st_COULUMN
			, ' [' + CTE1.column_name + ']' + CTE1.column_Order
			+ ISNULL(', ['+ CTE2.column_name + ']' + CTE2.column_Order, '')
			+ ISNULL(', ['+ CTE3.column_name + ']' + CTE3.column_Order, '')
			+ ISNULL(', ['+ CTE4.column_name + ']' + CTE4.column_Order, '')
			+ ISNULL(', ['+ CTE5.column_name + ']' + CTE5.column_Order, '')
			+ ISNULL(', ['+ CTE6.column_name + ']' + CTE6.column_Order, '')
			+ ISNULL(', ['+ CTE7.column_name + ']' + CTE7.column_Order, '')
			+ ISNULL(', ['+ CTE8.column_name + ']' + CTE8.column_Order, '')
			+ ISNULL(', ['+ CTE9.column_name + ']' + CTE9.column_Order, '')
			+ ISNULL(', ['+ CTE10.column_name + ']' + CTE10.column_Order, '') + ' ' AS INDEX_COULUMNS
		FROM CTE_Ind_Columns AS CTE1
		LEFT JOIN CTE_Ind_Columns AS CTE2 ON  CTE2.RN = 2   AND CTE2.object_id = CTE1.object_id
		LEFT JOIN CTE_Ind_Columns AS CTE3 ON  CTE3.RN = 3   AND CTE3.object_id = CTE1.object_id
		LEFT JOIN CTE_Ind_Columns AS CTE4 ON  CTE4.RN = 4   AND CTE4.object_id = CTE1.object_id
		LEFT JOIN CTE_Ind_Columns AS CTE5 ON  CTE5.RN = 5   AND CTE5.object_id = CTE1.object_id
		LEFT JOIN CTE_Ind_Columns AS CTE6 ON  CTE6.RN = 6   AND CTE6.object_id = CTE1.object_id
		LEFT JOIN CTE_Ind_Columns AS CTE7 ON  CTE7.RN = 7   AND CTE7.object_id = CTE1.object_id
		LEFT JOIN CTE_Ind_Columns AS CTE8 ON  CTE8.RN = 8   AND CTE8.object_id = CTE1.object_id
		LEFT JOIN CTE_Ind_Columns AS CTE9 ON  CTE9.RN = 9   AND CTE9.object_id = CTE1.object_id
		LEFT JOIN CTE_Ind_Columns AS CTE10 ON CTE10.RN = 10 AND CTE10.object_id = CTE1.object_id
		WHERE CTE1.RN = 1
	)
	, CTE_INDEX AS
	(
		SELECT object_id, INDEX_1st_COULUMN, INDEX_COULUMNS
		FROM CTE_Ind_JOINT
	)
	, CTE_TABLE_COLUMNS AS
	(
		SELECT      
			T.object_id, 
			c.name AS ColumnName, C.column_id AS ColumnID, TYPE_NAME(c.system_type_id) AS ColumnType, c.max_length, c.PRECISION, c.scale, C.is_nullable AS nullable, 
			ROW_NUMBER() OVER(PARTITION BY T.object_id ORDER BY C.column_id) AS RN
		FROM        sys.columns c
		JOIN        CTE_TABLE_LIST  t   ON c.object_id = t.object_id
	)
	, CTE_COLUMNS AS
	(
		SELECT
			M.object_id, ColumnName, ColumnID,nullable,
			CASE 
				WHEN M.ColumnType = 'IMAGE' THEN 'VARBINARY'
				WHEN M.ColumnType = 'XML' THEN 'nvarchar'
				WHEN M.ColumnType = 'TEXT' THEN 'varchar'
				WHEN M.ColumnType = 'NTEXT' THEN 'nvarchar'
				ELSE M.ColumnType
			END +
			CASE 
				WHEN M.ColumnType = 'IMAGE' THEN '(MAX)'
				WHEN M.ColumnType = 'XML' THEN '(MAX)'
				WHEN M.ColumnType = 'TEXT' THEN '(MAX)'
				WHEN M.ColumnType = 'NTEXT' THEN '(MAX)'
				WHEN M.ColumnType = 'DATETIME2' THEN '(' + CAST(m.scale AS VARCHAR) +')'
				WHEN M.ColumnType IN ('BINARY','VARBINARY') THEN '(' + ISNULL(NULLIF(CAST(m.max_length AS VARCHAR),'-1'),'MAX') +')'
				WHEN M.ColumnType IN ('DECIMAL','NUMERIC') THEN '(' + CAST(m.PRECISION AS VARCHAR) + ',' + CAST(m.scale AS VARCHAR) +')'
				WHEN M.ColumnType LIKE '%CHAR' THEN '(' + ISNULL(NULLIF(CAST(m.max_length AS VARCHAR),'-1'),'MAX') +')'
				ELSE '' 
			END AS ColumnType
		FROM CTE_TABLE_COLUMNS M
	)
	SELECT
		RN AS TableID, 'TBOS' AS DataBaseName, SchemaName, TableName, FULL_NAME AS FullName,
		INDEX_1st_COULUMN AS DisrtibutionColumn, INDEX_COULUMNS AS IndexColumns,
		ColumnName, ColumnID, nullable AS ColumnNullable,ColumnType
	FROM CTE_TABLE_LIST T
	LEFT JOIN CTE_INDEX I ON I.object_id = T.object_id
	LEFT JOIN CTE_COLUMNS C ON C.object_id = T.object_id
	ORDER BY TableID,ColumnID

*/

/*
###################################################################################################################
*/


/*
###################################################################################################################
===================================================================================================================
Code Description: 
-------------------------------------------------------------------------------------------------------------------
This Code is  . Run created script on APS
To use it on another database (IPS or DMV) - replace all 'TBOS' to 'IPS' or 'DMV' in the text
Make sure the table list is up to date
*******************************************************************************************************************

###################################################################################################################
*/


PRINT '!'

