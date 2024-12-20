CREATE VIEW [Utility].[vw_FullLoadTracker] AS SELECT P.DataBaseName, LogSource AS TableName,  Row_Count, ProcTime AS FullLoadRunTime, ProcStartDate AS LoadStartDate, LogDate AS LoadFinishDate 
FROM	Utility.ProcessLog L
JOIN	Utility.TableLoadParameters P 
		ON L.LogSource = P.FullName
WHERE	LogMessage = 'Step 2: SSIS load Finished'
		AND EXISTS (SELECT 1 FROM Utility.TableLoadParameters P WHERE P.FullName = L.LogSource AND P.CDCFlag = 1 AND P.Active = 1);
