CREATE PROC [Utility].[Compare_SRC_vs_APS_RowCount] AS

/*
###################################################################################################################
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
Perform TBOS vs Landing Daily Row Counts Comparison for CDC tables and save results in Utility.CompareDailyRowCount. 
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0038211		Shankar		2021-01-18	New!

===================================================================================================================
Example:
-------------------------------------------------------------------------------------------------------------------
EXEC Utility.Compare_SRC_vs_APS_RowCount 
EXEC Utility.FromLog 'Compare_SRC_vs_APS_RowCount', 1

DECLARE @CompareRunID INT
SELECT @CompareRunID = MAX(CompareRunID) FROM Utility.CompareDailyRowCount
SELECT TOP 1000 * FROM Utility.CompareDailyRowCount WHERE CompareRunID = @CompareRunID ORDER BY 2,3,4 DESC
###################################################################################################################
*/

BEGIN

	BEGIN TRY

		DECLARE @Log_Source VARCHAR(100) = 'Utility.Compare_SRC_vs_APS_RowCount', @Log_Start_Date DATETIME2 (3) = SYSDATETIME() 
		DECLARE @Log_Message VARCHAR(1000), @Row_Count BIGINT, @Trace_Flag BIT = 0 -- Testing
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Started TBOS vs Landing Daily Row Counts Comparison for CDC tables', 'I', NULL, NULL

		DECLARE @CompareRunID INT
		SELECT @CompareRunID = ISNULL(MAX(CompareRunID) + 1, 1) FROM Utility.CompareDailyRowCount
		
		--::==================================================================================================
		--:: TP_Trips in APS has Trips in IopOutBoundAndViolationLinking marked as D for ignoring. Show them in APS counts for comparison against TBOS source.
		--::==================================================================================================
		IF OBJECT_ID('Stage.APS_DailyRowCount_TP_Trips','U') IS NOT NULL	DROP TABLE Stage.APS_DailyRowCount_TP_Trips;
		CREATE TABLE Stage.APS_DailyRowCount_TP_Trips WITH (HEAP, DISTRIBUTION = ROUND_ROBIN) AS
		WITH CTAS_APS_DUP
		AS
		(
			SELECT 'TBOS' DataBaseName,'TollPlus.TP_Trips' TableName, CAST(TT.CreatedDate AS DATE) AS CreatedDate, COUNT_BIG(1) DupRowCount, CAST(SYSDATETIME() AS DATETIME2(3)) AS LND_UpdateDate  
			FROM	LND_TBOS.dbo.IopOutBoundAndViolationLinking DUP
			JOIN	LND_TBOS.TollPlus.TP_Trips TT
					ON 	TT.TPTripID = DUP.OutboundTpTripId
			GROUP BY CAST(TT.CreatedDate AS DATE)
		)
		SELECT DRC.DataBaseName, DRC.TableName, DRC.CreatedDate, DRC.Row_Count AS DRC_Row_Count, ISNULL(DUP.DupRowCount,0) DUP_Row_Count,  DRC.Row_Count + ISNULL(DUP.DupRowCount,0) AS Row_Count, DRC.LND_UpdateDate
		FROM LND_TBOS.Stage.APS_DailyRowCount DRC
		LEFT JOIN CTAS_APS_DUP DUP ON DUP.CreatedDate = DRC.CreatedDate
		WHERE DRC.TableName = 'TollPlus.TP_Trips'  

		UPDATE Stage.APS_DailyRowCount
		SET Row_Count = APS_DailyRowCount_TP_Trips.Row_Count
		FROM Stage.APS_DailyRowCount_TP_Trips 
		WHERE APS_DailyRowCount.TableName = APS_DailyRowCount_TP_Trips.TableName
		AND APS_DailyRowCount.CreatedDate = APS_DailyRowCount_TP_Trips.CreatedDate

		--::==================================================================================================
		--:: Compare Daily row counts by CreatedDate for each CDC table 
		--::==================================================================================================

		INSERT Utility.CompareDailyRowCount (CompareRunID, DataBaseName, TableName, CreatedDate, SRC_RowCount, APS_RowCount, RowCountDiff, DiffPercent, SRC_RowCountDate, APS_RowCountDate, LND_UpdateDate)
		SELECT @CompareRunID CompareRunID, ISNULL(SRC.DataBaseName,APS.DataBaseName) DataBaseName, ISNULL(SRC.TableName,APS.TableName) TableName,  ISNULL(SRC.CreatedDate,APS.CreatedDate ) CreatedDate,
			   ISNULL(SRC.Row_Count,0) AS SRC_RowCount, ISNULL(APS.Row_Count,0) AS APS_RowCount, ISNULL(SRC.Row_Count,0) - ISNULL(APS.Row_Count,0) RowCountDiff,
			   (ISNULL(SRC.Row_Count,0) - ISNULL(APS.Row_Count,0))/(ISNULL(SRC.Row_Count,APS.Row_Count)*1.0)*100 DiffPercent,
			   SRC.LND_UpdateDate SRC_RowCountDate, APS.LND_UpdateDate APS_RowCountDate, CONVERT(DATETIME2(3),SYSDATETIME()) LND_UpdateDate 
		FROM LND_TBOS.Stage.SRC_DailyRowCount SRC
		FULL JOIN LND_TBOS.Stage.APS_DailyRowCount APS ON SRC.TableName = APS.TableName AND SRC.CreatedDate = APS.CreatedDate
		--ORDER BY 1,2,3

		SET  @Log_Message = 'Compared Daily Row Counts between SRC and APS tables being refreshed by Attunity CDC'
		EXEC Utility.ToLog @Log_Source, @Log_Start_Date, @Log_Message, 'I', -1, NULL

		--:: Purge old rows
		DELETE Utility.CompareDailyRowCount WHERE APS_RowCountDate < GETDATE()-90

		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, 'Completed TBOS vs Landing Daily Row Counts Comparison for CDC tables', 'I', NULL, NULL
		
		-- Show results
		IF @Trace_Flag = 1 
		BEGIN
			EXEC Utility.FromLog @Log_Source, @Log_Start_Date
			SELECT TOP 1000 'Stage.SRC_DailyRowCount' CompareTableName, * FROM Stage.SRC_DailyRowCount ORDER BY DataBaseName DESC, TableName, CreatedDate DESC
			SELECT TOP 1000 'Stage.APS_DailyRowCount' CompareTableName, * FROM Stage.APS_DailyRowCount ORDER BY DataBaseName DESC, TableName, CreatedDate DESC
			SELECT TOP 1000 'Utility.CompareDailyRowCount' CompareTableName, * FROM Utility.CompareDailyRowCount WHERE CompareRunID = (SELECT MAX(CompareRunID) FROM LND_TBOS.Utility.CompareDailyRowCount) ORDER BY DataBaseName DESC, TableName, CreatedDate DESC 
		END
	END	TRY
	
	BEGIN CATCH
		
		DECLARE @Error_Message VARCHAR(MAX) = ERROR_MESSAGE();
		EXEC    Utility.ToLog @Log_Source, @Log_Start_Date, @Error_Message, 'E', NULL, NULL;
		EXEC	Utility.FromLog @Log_Source, @Log_Start_Date;
		THROW;  -- Rethrow the error!
	
	END CATCH

END

/*
--===============================================================================================================
-- DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
--===============================================================================================================
EXEC Utility.Compare_SRC_vs_APS_RowCount
EXEC Utility.FromLog 'Compare_SRC_vs_APS_RowCount', 1

DECLARE @CompareRunID INT
SELECT @CompareRunID = MAX(CompareRunID) FROM Utility.CompareDailyRowCount
SELECT DISTINCT DataBaseName,TableName FROM Utility.CompareDailyRowCount WHERE CompareRunID = @CompareRunID ORDER BY 1,2

SELECT DataBaseName,TableName, COUNT(1) RC FROM Utility.CompareDailyRowCount WHERE RowCountDiff = 0 GROUP BY DataBaseName,TableName ORDER BY 1,2
SELECT DataBaseName,TableName, COUNT(1) RC FROM Utility.CompareDailyRowCount WHERE RowCountDiff <> 0 GROUP BY DataBaseName,TableName ORDER BY 1,2

SELECT TOP 300000 CompareRunID,DataBaseName,TableName,CreatedDate,SRC_RowCount,APS_RowCount,RowCountDiff,DiffPercent 
FROM Utility.CompareDailyRowCount 
WHERE RowCountDiff = 0 
AND CompareRunID = (SELECT MAX(CompareRunID) FROM Utility.CompareDailyRowCount)
ORDER BY 1 DESC,2,3 DESC

SELECT TOP 300000 CompareRunID,DataBaseName,TableName,CreatedDate,SRC_RowCount,APS_RowCount,RowCountDiff,DiffPercent 
FROM Utility.CompareDailyRowCount 
WHERE RowCountDiff <> 0 
AND CompareRunID = (SELECT MAX(CompareRunID) FROM Utility.CompareDailyRowCount)
ORDER BY 1 DESC,2,ABS(RowCountDiff) DESC,3 DESC

SELECT * FROM LND_TBOS.Stage.SRC_DailyRowCount WHERE TABLENAME = 'Finance.Adjustment_LineItems' ORDER BY CREATEDDATE
SELECT * FROM LND_TBOS.Stage.APS_DailyRowCount WHERE TABLENAME = 'Finance.Adjustment_LineItems' ORDER BY CREATEDDATE
SELECT * FROM Utility.CompareDailyRowCount WHERE TABLENAME = 'Finance.Adjustment_LineItems' ORDER BY CREATEDDATE


--:: CDC Monitor. TBOS vs Landing Comparison.
IF EXISTS 
(
	SELECT 1
	FROM LND_TBOS.Utility.CompareDailyRowCount
	WHERE CompareRunID =
	(
		SELECT MAX(CompareRunID) FROM LND_TBOS.Utility.CompareDailyRowCount
	)
	AND RowCountDiff <> 0
	AND CreatedDate < CONVERT(DATE, GETDATE())
)

SELECT 
	   (SELECT MAX(CompareRunID) FROM LND_TBOS.Utility.CompareDailyRowCount) CompareRunID,
	   DataBaseName,
       TableName,
	   --:: Daily Matching or NonMatching Row Counts numbers
	   SUM(SRC_RowCount) AS [SRC_RowCount],
	   SUM(APS_RowCount) AS [APS_RowCount],
       SUM(   CASE
                  WHEN RowCountDiff = 0 THEN
                      SRC_RowCount
                  ELSE
                      0
              END
          ) MatchingDay_RowCount,
       SUM(   CASE
                  WHEN RowCountDiff <> 0 THEN
                      RowCountDiff
                  ELSE
                      0
              END
          ) NonMatchingDay_RowCount,
       CONVERT(DECIMAL(9,4),
       SUM(   CASE
                  WHEN RowCountDiff <> 0 THEN
                      RowCountDiff
                  ELSE
                      0
              END
          )/ (CASE WHEN SUM(SRC_RowCount) = 0 THEN SUM(APS_RowCount) ELSE SUM(SRC_RowCount) END  * 1.0) * 100  
	   ) NonMatchingDay_RowPercent,

	   --:: Matching or NonMatching Row Create Day Counts numbers
       COUNT_BIG(1) DayCount,
       SUM(   CASE
                  WHEN RowCountDiff = 0 THEN
                      1
                  ELSE
                      0
              END
          ) Matching_DayCount,
       SUM(   CASE
                  WHEN RowCountDiff <> 0 THEN
                      1
                  ELSE
                      0
              END
          ) NonMatching_DayCount,
       CONVERT(DECIMAL(9,4),
			   SUM(   CASE
						  WHEN RowCountDiff <> 0 THEN
							  1
						  ELSE
							  0
					  END
				  ) / (COUNT(1) * 1.0) * 100  
			) NonMatching_DayPercent,

       MIN(   CASE
                  WHEN RowCountDiff <> 0 THEN
                      CreatedDate
              END
          ) NonMatching_MinDate,
       MAX(   CASE
                  WHEN RowCountDiff <> 0 THEN
                      CreatedDate
              END
          ) NonMatching_MaxDate
	   
--SELECT TOP 100 *  
FROM LND_TBOS.Utility.CompareDailyRowCount
WHERE CompareRunID =
(
    SELECT MAX(CompareRunID) FROM LND_TBOS.Utility.CompareDailyRowCount
)
GROUP BY DataBaseName,
         TableName
ORDER BY DataBaseName DESC,
         TableName
  
*/


