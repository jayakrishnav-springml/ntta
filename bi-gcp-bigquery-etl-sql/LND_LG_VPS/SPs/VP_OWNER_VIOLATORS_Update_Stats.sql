CREATE PROC [VP_OWNER].[VIOLATORS_Update_Stats] AS

EXEC DropStats 'VP_OWNER','VIOLATORS'
CREATE STATISTICS STATS_VIOLATORS_001 ON VP_OWNER.VIOLATORS (VIOLATOR_ID)
CREATE STATISTICS STATS_VIOLATORS_002 ON VP_OWNER.VIOLATORS (VIOLATOR_ID, LAST_UPDATE_DATE)
CREATE STATISTICS STATS_VIOLATORS_003 ON VP_OWNER.VIOLATORS (LAST_UPDATE_DATE)
