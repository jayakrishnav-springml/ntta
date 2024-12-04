CREATE PROC [DMVLD].[TITLES_Update_Stats] AS

EXEC DropStats 'DMVLD','TITLES'
CREATE STATISTICS STATS_TITLES_001 ON DMVLD.TITLES (ID)
CREATE STATISTICS STATS_TITLES_002 ON DMVLD.TITLES (ID, LAST_UPDATE_DATE)
CREATE STATISTICS STATS_TITLES_003 ON DMVLD.TITLES (LAST_UPDATE_DATE)
