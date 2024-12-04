CREATE OR REPLACE PROCEDURE `LND_TBOS_SUPPORT.Compare_SRC_vs_APS_RowCount`()

BEGIN
/*
###################################################################################################################
Proc Description: 
##################################################################################################################-
Perform TBOS vs Landing Daily Row Counts Comparison for CDC tables and save results in Utility.CompareDailyRowCount. 
===================================================================================================================
Change Log:
##################################################################################################################-
CHG0038211		Shankar		2021-01-18	New!

===================================================================================================================
Example:
##################################################################################################################-
EXEC Utility.Compare_SRC_vs_APS_RowCount 
EXEC Utility.FromLog 'Compare_SRC_vs_APS_RowCount', 1

DECLARE @CompareRunID INT
SELECT @CompareRunID = MAX(CompareRunID) FROM Utility.CompareDailyRowCount
SELECT TOP 1000 * FROM Utility.CompareDailyRowCount WHERE CompareRunID = @CompareRunID ORDER BY 2,3,4 DESC
###################################################################################################################
*/
    DECLARE log_source STRING DEFAULT 'LND_TBOS_SUPPORT.Compare_SRC_vs_APS_RowCount';
    DECLARE log_start_date DATETIME;
    DECLARE log_message STRING;
    DECLARE trace_flag INT64 DEFAULT 0;
    BEGIN
      DECLARE comparerunid INT64;
      DECLARE row_count INT64;
      SET log_start_date = current_datetime();
      ##CALL utility.tolog(log_source, log_start_date, 'Started TBOS vs Landing Daily Row Counts Comparison for CDC tables', 'I', NULL, NULL);
	  SELECT log_source, log_start_date, 'Started TBOS vs Landing Daily Row Counts Comparison for CDC tables', 'I', NULL, NULL;
      SET comparerunid = (
        SELECT
            coalesce(any_value(subselect.__comparerunid), comparerunid) AS __comparerunid
          FROM
            (
              SELECT
                  coalesce(max(comparerunid) + 1, 1) AS __comparerunid
                FROM
                  LND_TBOS_SUPPORT.CompareDailyRowCount
              LIMIT 1
            ) AS subselect
      );
      ##::==================================================================================================
		##:: TP_Trips in APS has Trips in IopOutBoundAndViolationLinking marked as D for ignoring. Show them in APS counts for comparison against TBOS source.
		##::==================================================================================================
		
      ##DROP TABLE IF EXISTS stage.aps_dailyrowcount_tp_trips;
      CREATE OR REPLACE TABLE LND_TBOS_STAGE_FULL.APS_DailyRowCount_TP_Trips
        AS
          WITH ctas_aps_dup AS (
            SELECT
                'TBOS' AS databasename,
                'TollPlus_TP_Trips' AS tablename,
                CAST(tt.createddate as DATE) AS createddate,
                count(1) AS duprowcount,
                current_datetime() AS lnd_updatedate
              FROM
                LND_TBOS.dbo_IopOutBoundAndViolationLinking AS dup
                INNER JOIN LND_TBOS.TollPlus_TP_Trips AS tt ON tt.tptripid = dup.outboundtptripid
              GROUP BY 3
          )
          SELECT
              drc.databasename,
              drc.tablename,
              drc.createddate,
              drc.row_count AS drc_row_count,
              coalesce(dup.duprowcount, 0) AS dup_row_count,
              drc.row_count + coalesce(dup.duprowcount, 0) AS row_count,
              drc.lnd_updatedate
            FROM
              LND_TBOS_STAGE_FULL.APS_DailyRowCount AS drc
              LEFT OUTER JOIN ctas_aps_dup AS dup ON dup.createddate = drc.createddate
            WHERE drc.tablename = 'TollPlus_TP_Trips'
      ;
      UPDATE LND_TBOS_STAGE_FULL.APS_DailyRowCount SET row_count = APS_DailyRowCount_TP_Trips.row_count FROM LND_TBOS_STAGE_FULL.APS_DailyRowCount_TP_Trips WHERE APS_DailyRowCount.tablename = APS_DailyRowCount_TP_Trips.tablename
       AND APS_DailyRowCount.createddate = APS_DailyRowCount_TP_Trips.createddate;
      ##::==================================================================================================
		##:: Compare Daily row counts by CreatedDate for each CDC table 
		##::==================================================================================================
INSERT INTO LND_TBOS_SUPPORT.CompareDailyRowCount (comparerunid, databasename, tablename, createddate, src_rowcount, aps_rowcount, rowcountdiff, diffpercent, src_rowcountdate, aps_rowcountdate, lnd_updatedate)
        SELECT
            comparerunid AS comparerunid,
            coalesce(src.databasename, aps.databasename) AS databasename,
            coalesce(src.tablename, aps.tablename) AS tablename,
            coalesce(src.createddate, aps.createddate) AS createddate,
            coalesce(src.row_count, 0) AS src_rowcount,
            coalesce(aps.row_count, 0) AS aps_rowcount,
            coalesce(src.row_count, 0) - coalesce(aps.row_count, 0) AS rowcountdiff,
            (coalesce(src.row_count, 0) - coalesce(aps.row_count, 0)) / (coalesce(src.row_count, aps.row_count) * NUMERIC '1.0') * 100 AS diffpercent,
            src.lnd_updatedate AS src_rowcountdate,
            aps.lnd_updatedate AS aps_rowcountdate,
            current_datetime() AS lnd_updatedate
          FROM
            LND_TBOS_STAGE_FULL.SRC_DailyRowCount AS src
            FULL OUTER JOIN LND_TBOS_STAGE_FULL.APS_DailyRowCount AS aps ON src.tablename = aps.tablename
             AND src.createddate = aps.createddate
      ;
      SET log_message = 'Compared Daily Row Counts between SRC and APS tables being refreshed by Attunity CDC';
      ##CALL utility.tolog(log_source, log_start_date, log_message, 'I', -1, NULL);
      SELECT log_source, log_start_date, log_message, 'I', -1, NULL;
      DELETE FROM LND_TBOS_SUPPORT.CompareDailyRowCount WHERE CompareDailyRowCount.aps_rowcountdate < datetime(TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 90 DAY));
      ##CALL utility.tolog(log_source, log_start_date, 'Completed TBOS vs Landing Daily Row Counts Comparison for CDC tables', 'I', NULL, NULL);
      SELECT log_source, log_start_date, 'Completed TBOS vs Landing Daily Row Counts Comparison for CDC tables', 'I', NULL, NULL;
      IF trace_flag = 1 THEN
        ##CALL utility.fromlog(log_source, log_start_date);
        SELECT log_source, log_start_date;
        SELECT
            'LND_TBOS_STAGE_FULL.SRC_DailyRowCount' AS comparetablename,
            src_dailyrowcount.*
          FROM
            LND_TBOS_STAGE_FULL.SRC_DailyRowCount
       ORDER BY
          databasename DESC,
          tablename,
          createddate DESC  LIMIT 1000
        ;
        SELECT
            'LND_TBOS_STAGE_FULL.APS_DailyRowCount' AS comparetablename,
            aps_dailyrowcount.*
          FROM
            LND_TBOS_STAGE_FULL.APS_DailyRowCount
        ORDER BY
          databasename DESC,
          tablename,
          createddate DESC LIMIT 1000
        ;
        SELECT
            'LND_TBOS_SUPPORT.CompareDailyRowCount' AS comparetablename,
            comparedailyrowcount.*
          FROM
            LND_TBOS_SUPPORT.CompareDailyRowCount
          WHERE comparerunid = (
            SELECT
                max(comparerunid)
              FROM
                LND_TBOS_SUPPORT.CompareDailyRowCount AS comparedailyrowcount_0
          )
        ORDER BY
          databasename DESC,
          tablename,
          createddate DESC LIMIT 1000
        ;
      END IF;
    EXCEPTION WHEN ERROR THEN
      BEGIN
        DECLARE error_message STRING DEFAULT @@error.message;
        ##CALL utility.tolog(log_source, log_start_date, error_message, 'E', NULL, NULL);
        SELECT log_source, log_start_date, error_message, 'E', NULL, NULL;
        ##CALL utility.fromlog(log_source, log_start_date);
        SELECT log_source, log_start_date;
        RAISE USING MESSAGE = error_message;
      END;
    END;
/*
##===============================================================================================================
## DEVELOPER TESTING ZONE to thoroughly test the code for various scenarios
##===============================================================================================================
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


##:: CDC Monitor. TBOS vs Landing Comparison.
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
	   ##:: Daily Matching or NonMatching Row Counts numbers
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

	   ##:: Matching or NonMatching Row Create Day Counts numbers
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
	   
##SELECT TOP 100 *  
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


  END