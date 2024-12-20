CREATE VIEW [Utility].[vw_CDCCompareSummary] AS WITH LastFullLoad_CTE AS 
(
	SELECT TableName, MAX(LoadFinishDate) LastFullLoadDate FROM Utility.vw_FullLoadTracker GROUP BY TableName
)
SELECT 
		MAX(CompareRunID) CompareRunID,
		DataBaseName,
		CDR.TableName,
		--:: Daily Matching or NonMatching Row Counts numbers
		SUM(SRC_RowCount) AS [SRC_RowCount],
		SUM(APS_RowCount) AS [APS_RowCount],
		SUM(   CASE
					WHEN RowCountDiff = 0 THEN
						SRC_RowCount
					ELSE
						0
				END
			) Matching_RowCount,
		SUM(   CASE
					WHEN RowCountDiff <> 0 THEN
						RowCountDiff
					ELSE
						0
				END
			) NonMatching_RowCount,
		CONVERT(DECIMAL(9,4),
		SUM(   CASE
					WHEN RowCountDiff <> 0 THEN
						RowCountDiff
					ELSE
						0
				END
			)/ (CASE WHEN SUM(SRC_RowCount) = 0 THEN SUM(APS_RowCount) ELSE SUM(SRC_RowCount) END  * 1.0) * 100  
		) NonMatching_RowPercent,

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
			) NonMatching_MaxDate,
		MIN(CONVERT(DATE,LFL.LastFullLoadDate)) LastFullLoadDate,
		MIN(LND_UpdateDate) CompareDate 
	   
--SELECT TOP 100 *  
FROM	LND_TBOS.Utility.CompareDailyRowCount CDR
		LEFT JOIN LastFullLoad_CTE LFL
		ON CDR.TableName = LFL.TableName
WHERE	CompareRunID =
		(
			SELECT MAX(CompareRunID) FROM LND_TBOS.Utility.CompareDailyRowCount
		)
		AND CreatedDate < CONVERT(DATE, LND_UpdateDate)
GROUP BY DataBaseName,
		 CDR.TableName;
