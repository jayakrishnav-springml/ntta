CREATE PROC [VP_OWNER].[PAYMENTS_Update_Stats] AS

EXEC DropStats 'VP_OWNER','PAYMENTS'
CREATE STATISTICS STATS_PAYMENTS_001 ON VP_OWNER.PAYMENTS (PAYMENT_TXN_ID)
CREATE STATISTICS STATS_PAYMENTS_002 ON VP_OWNER.PAYMENTS (PAYMENT_TXN_ID, VIOLATOR_ID)
CREATE STATISTICS STATS_PAYMENTS_003 ON VP_OWNER.PAYMENTS (PAYMENT_TXN_ID, LAST_UPDATE_DATE)
CREATE STATISTICS STATS_PAYMENTS_004 ON VP_OWNER.PAYMENTS (LAST_UPDATE_DATE)
