CREATE PROC [Utility].[Get_Index_String] @Table_Name [VARCHAR](200),@Params_In_SQL_Out [VARCHAR](MAX) OUT AS
/*

USE LND_TBOS
GO
IF OBJECT_ID ('Utility.Get_Index_String', 'P') IS NOT NULL DROP PROCEDURE Utility.Get_Index_String
GO
###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
DECLARE @Params_In_SQL_Out VARCHAR(MAX) = 'No[]'
EXEC Utility.Get_Index_String 'TollPlus.TP_Customer_Trip_Receipts_Tracker', @Params_In_SQL_Out OUTPUT 
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc creating and returning Index string for Create table statement, looks like 'CLUSTERED COLUMNSTORE INDEX' or 'CLUSTERED INDEX (Column1 ASC, Column2 DESC)'

@Table_Name - Name of the table to pick column from
@Params_In_SQL_Out - Param to return string. 
	-- can be: 	'No[],NoPrint'
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837			Andy		01/10/2020	New!
CHG0040994			Shankar		05/26/2022	Fixed index/heap type identification
###################################################################################################################
*/

BEGIN
	 
	DECLARE @Error VARCHAR(MAX) = ''
	DECLARE @Params VARCHAR(100) = ISNULL(@Params_In_SQL_Out,'')

	IF @Table_Name IS NULL SET @Error = @Error + 'Table name cannot be NULL'

	SET @Params_In_SQL_Out = '';

	IF LEN(@Error) > 0
	BEGIN
		PRINT @Error
	END
	ELSE
	BEGIN

		DECLARE @Schema VARCHAR(100), @Table VARCHAR(200), @Table_INDEX VARCHAR(100)
		DECLARE @Dot INT = CHARINDEX('.',@Table_Name)

		SELECT 
			@Schema = CASE WHEN @Dot = 0 THEN 'dbo' ELSE REPLACE(REPLACE(REPLACE(LEFT(@Table_Name,@Dot),'[',''),']',''),'.','') END,
			@Table = CASE WHEN @Dot = 0 THEN REPLACE(REPLACE(@Table_Name,'[',''),']','') ELSE REPLACE(REPLACE(SUBSTRING(@Table_Name,@Dot + 1,200),'[',''),']','') END

		SELECT @TABLE_INDEX = type_desc
		FROM
		(
			SELECT I.type_desc, ROW_NUMBER() OVER (ORDER BY CASE WHEN I.type_desc = 'CLUSTERED' OR is_primary_key = 1 OR is_unique_constraint = 1 THEN 1 ELSE 2 END) RN
			FROM sys.tables as t
			JOIN sys.schemas AS s ON t.schema_id = s.schema_id AND s.name = @Schema
			JOIN sys.indexes AS I ON I.object_id = t.object_id
			WHERE t.name = @TABLE AND I.index_id <=1
		) T
		WHERE RN = 1

		PRINT @Table_Name + ' index ' + @Table_INDEX

		IF @Table_INDEX = 'CLUSTERED'
		BEGIN
			WITH CTE AS
			(
				SELECT C.column_id, u.name AS column_name, CASE WHEN C.is_descending_key = 1 THEN ' DESC' ELSE ' ASC' END AS column_Order
					, ROW_NUMBER() OVER (ORDER BY C.key_ordinal) AS RN 
				FROM sys.Tables as t
				JOIN sys.schemas s ON t.schema_id = s.schema_id AND s.name = @Schema
				JOIN sys.indexes AS I ON I.object_id = t.object_id AND I.index_id <= 1
				JOIN sys.index_columns AS C ON C.object_id = t.object_id AND C.index_id = I.index_id AND C.key_ordinal > 0
				JOIN sys.columns AS u ON u.column_id = C.column_id AND u.object_id = t.object_id
				WHERE t.name = @Table
			)
			, CTE_JOINT AS 
			(
				SELECT 
					' [' + CTE1.column_name + ']' + CTE1.column_Order
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
				@Params_In_SQL_Out = @Table_INDEX + ' INDEX (' + INDEX_COULUMNS + ')'
			FROM CTE_JOINT
		END
		ELSE
		BEGIN
			IF @Table_INDEX = 'CLUSTERED COLUMNSTORE'
			BEGIN
				SET @Params_In_SQL_Out = @Table_INDEX + ' INDEX'
			END
			ELSE
			BEGIN
				SET @Params_In_SQL_Out = @Table_INDEX
			END
		END

		IF CHARINDEX('No[]',@Params) > 0
			SET @Params_In_SQL_Out = REPLACE(REPLACE(@Params_In_SQL_Out,'[',''),']','')

		IF CHARINDEX('NoPrint',@Params) = 0
			EXEC Utility.LongPrint @Params_In_SQL_Out

	END
END



