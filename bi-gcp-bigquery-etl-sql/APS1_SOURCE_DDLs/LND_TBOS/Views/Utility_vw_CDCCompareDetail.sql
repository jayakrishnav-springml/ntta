CREATE VIEW [Utility].[vw_CDCCompareDetail] AS WITH LastFullLoad_CTE AS 
(
	SELECT TableName, MAX(LoadFinishDate) LastFullLoadDate FROM Utility.vw_FullLoadTracker GROUP BY TableName
)
SELECT	CompareRunID, DataBaseName, CDR.TableName, CreatedDate, SRC_RowCount, APS_RowCount, RowCountDiff, DiffPercent, LND_UpdateDate AS CompareDate, CONVERT(DATE,LFL.LastFullLoadDate) LastFullLoadDate
FROM	LND_TBOS.Utility.CompareDailyRowCount CDR
		LEFT JOIN LastFullLoad_CTE LFL
		ON CDR.TableName = LFL.TableName
WHERE	CompareRunID =
		(
			SELECT MAX(CompareRunID) FROM LND_TBOS.Utility.CompareDailyRowCount
		)
		AND RowCountDiff <> 0
		AND CreatedDate < CONVERT(DATE, LND_UpdateDate);
