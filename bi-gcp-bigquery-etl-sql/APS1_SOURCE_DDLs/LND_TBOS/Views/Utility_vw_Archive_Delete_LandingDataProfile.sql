CREATE VIEW [Utility].[vw_Archive_Delete_LandingDataProfile] AS SELECT	CASE WHEN tlp.CDCFlag = 1 THEN 'CDC' ELSE 'Full' END CDC_or_Full, 
		tlp.DataBaseName, 
		tlp.FullName AS TableName,
		REPLACE(REPLACE(tlp.UID_Columns,'[',''),']','') UID_Columns,
		COALESCE(cc.APS_RowCount, full_rc.Row_Count, tlp.RowCnt) TotalRowCount, 
		ISNULL(arch.ArchiveRowCount,0) ArchiveRowCount,
		CASE WHEN atl.tablename IS NOT NULL THEN 1 ELSE 0 END ArchiveTablesMasterListFlag,
		tlp.ArchiveFlag ArchiveEnabledFlag,
		CASE WHEN hd.TableName IS NOT NULL THEN 1 ELSE 0 END HardDeleteTableFlag, 
		ISNULL(del.DeleteRowCount,0) DeleteRowCount,
		CONVERT(DATE,SYSDATETIME()) AsOfDate
FROM Utility.TableLoadParameters tlp 
LEFT JOIN Utility.ArchiveMasterTableList atl ON tlp.FullName = atl.TableName --WHERE tlp.FullName = 'TollPlus.TP_CustTxns'
LEFT JOIN Utility.HardDeleteTable hd ON tlp.FullName = hd.TableName
LEFT JOIN Utility.vw_CDCCompareSummary cc ON tlp.FullName = cc.TableName 
LEFT JOIN (SELECT TableName, SUM(Row_Count) ArchiveRowCount FROM Utility.ArchiveDeleteRowCount WHERE LND_UpdateType = 'A' GROUP BY TableName) arch ON tlp.FullName = arch.TableName 
LEFT JOIN (SELECT TableName, SUM(Row_Count) DeleteRowCount FROM Utility.ArchiveDeleteRowCount WHERE LND_UpdateType = 'D' GROUP BY TableName) del ON tlp.FullName = del.TableName 
LEFT JOIN (SELECT TableName, Row_Count FROM (SELECT LogSource AS TableName, Row_Count, ROW_NUMBER() OVER (PARTITION BY LogSource ORDER BY LogDate DESC) RN FROM Utility.ProcessLog WHERE LogDate > GETDATE()-31 AND LogMessage = 'Step 2: SSIS load finished') RC WHERE RN = 1) full_rc ON tlp.FullName = full_rc.TableName 
WHERE Active = 1;
