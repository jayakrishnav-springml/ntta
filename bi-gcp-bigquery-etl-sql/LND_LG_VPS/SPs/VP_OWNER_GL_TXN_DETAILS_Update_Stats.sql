CREATE PROC [VP_OWNER].[GL_TXN_DETAILS_Update_Stats] AS

EXEC DropStats 'VP_OWNER','GL_TXN_DETAILS'
CREATE STATISTICS STATS_GL_TXN_DETAILS_001 ON VP_OWNER.GL_TXN_DETAILS (GL_DET_ID)
CREATE STATISTICS STATS_GL_TXN_DETAILS_002 ON VP_OWNER.GL_TXN_DETAILS (GL_DET_ID, LAST_UPDATE_DATE)
CREATE STATISTICS STATS_GL_TXN_DETAILS_003 ON VP_OWNER.GL_TXN_DETAILS (LAST_UPDATE_DATE)
