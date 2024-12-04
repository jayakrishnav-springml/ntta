CREATE PROC [TXNOWNER].[VIOL_TRANSACTIONS_UPDATE] AS  /*   Use this proc to help write the code    GetUpdateFields 'TXNOWNER','VIOL_TRANSACTIONS'    You will have to remove the Distribution key from what it generates  */    /*   Update Stats on CT_UPD table to help with de-dupping and update steps  */    EXEC DropStats 'TXNOWNER','VIOL_TRANSACTIONS_CT_UPD'  CREATE STATISTICS STATS_VIOL_TRANSACTIONS_CT_UPD_001 ON TXNOWNER.VIOL_TRANSACTIONS_CT_UPD (TRANS_REC_ID)  CREATE STATISTICS STATS_VIOL_TRANSACTIONS_CT_UPD_002 ON TXNOWNER.VIOL_TRANSACTIONS_CT_UPD (TRANS_REC_ID, INSERT_DATETIME)      /*   Get Duplicate Records with the INSERT_DATETIME from the CDC Staging   */    IF OBJECT_ID('tempdb..#VIOL_TRANSACTIONS_CT_UPD_Dups')<>0   DROP TABLE #VIOL_TRANSACTIONS_CT_UPD_Dups    CREATE TABLE #VIOL_TRANSACTIONS_CT_UPD_Dups WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (TRANS_REC_ID, INSERT_DATETIME), LOCATION = USER_DB)  AS   SELECT A.TRANS_REC_ID, A.INSERT_DATETIME   FROM TXNOWNER.VIOL_TRANSACTIONS_CT_UPD A   INNER JOIN     (     SELECT TRANS_REC_ID     FROM TXNOWNER.VIOL_TRANSACTIONS_CT_UPD     GROUP BY TRANS_REC_ID     HAVING COUNT(*)>1    ) Dups ON A.TRANS_REC_ID = Dups.TRANS_REC_ID    /*   Create temp table with Last Update   */    IF OBJECT_ID('tempdb..#VIOL_TRANSACTIONS_CT_UPD_DuplicateLastRowToReInsert')<>0   DROP TABLE #VIOL_TRANSACTIONS_CT_UPD_DuplicateLastRowToReInsert    CREATE TABLE #VIOL_TRANSACTIONS_CT_UPD_DuplicateLastRowToReInsert WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (TRANS_REC_ID), LOCATION = USER_DB)  AS   SELECT  A.TRANS_REC_ID, A.HOST_TRANSACTION_ID, A.VIOL_DATE, A.PROCESS_FLAG, A.VIOL_SERIAL_NBR, A.ISF_SERIAL_NBR, A.LC_FLG, A.VIOLATION_ID, A.AGENCY_CODE, A.TAG_ID, A.REASON_CODE, A.EARNED_CLASS, A.EARNED_REVENUE, A.POSTED_DATE, A.POSTED_CLASS, A.POSTED_REVENUE, A.TAG_STATUS, A.COIN_JAM, A.ACM_OK, A.AVI_OK, A.TAG_CLASS, A.LANE_ID, A.VES_TIMESTAMP, A.CREATION_DATE, A.CREATED_BY, A.UPDATED_DATE, A.UPDATED_BY, A.DISPOSITION, A.HIA_AGCY_ID, A.VIOL_STATUS, A.INSERT_DATETIME   FROM TXNOWNER.VIOL_TRANSACTIONS_CT_UPD A   INNER JOIN     (     SELECT TRANS_REC_ID, MAX(INSERT_DATETIME) AS LAST_INSERT_DATETIME     FROM #VIOL_TRANSACTIONS_CT_UPD_Dups     GROUP BY TRANS_REC_ID    ) LastRcrd ON A.TRANS_REC_ID = LastRcrd.TRANS_REC_ID AND A.INSERT_DATETIME = LastRcrd.LAST_INSERT_DATETIME    /*   DELETE all the duplicate rows from the target  */    DELETE FROM TXNOWNER.VIOL_TRANSACTIONS_CT_UPD   WHERE EXISTS(SELECT * FROM #VIOL_TRANSACTIONS_CT_UPD_Dups B WHERE TXNOWNER.VIOL_TRANSACTIONS_CT_UPD.TRANS_REC_ID = B.TRANS_REC_ID);      /*   Re-insert the LAST ROW for Duplicates  */  INSERT INTO TXNOWNER.VIOL_TRANSACTIONS_CT_UPD    (TRANS_REC_ID, HOST_TRANSACTION_ID, VIOL_DATE, PROCESS_FLAG, VIOL_SERIAL_NBR, ISF_SERIAL_NBR, LC_FLG, VIOLATION_ID, AGENCY_CODE, TAG_ID, REASON_CODE, EARNED_CLASS, EARNED_REVENUE, POSTED_DATE, POSTED_CLASS, POSTED_REVENUE, TAG_STATUS, COIN_JAM, ACM_OK, AVI_OK, TAG_CLASS, LANE_ID, VES_TIMESTAMP, CREATION_DATE, CREATED_BY, UPDATED_DATE, UPDATED_BY, DISPOSITION, HIA_AGCY_ID, VIOL_STATUS, INSERT_DATETIME)  SELECT TRANS_REC_ID, HOST_TRANSACTION_ID, VIOL_DATE, PROCESS_FLAG, VIOL_SERIAL_NBR, ISF_SERIAL_NBR, LC_FLG, VIOLATION_ID, AGENCY_CODE, TAG_ID, REASON_CODE, EARNED_CLASS, EARNED_REVENUE, POSTED_DATE, POSTED_CLASS, POSTED_REVENUE, TAG_STATUS, COIN_JAM, ACM_OK, AVI_OK, TAG_CLASS, LANE_ID, VES_TIMESTAMP, CREATION_DATE, CREATED_BY, UPDATED_DATE, UPDATED_BY, DISPOSITION, HIA_AGCY_ID, VIOL_STATUS, INSERT_DATETIME  FROM #VIOL_TRANSACTIONS_CT_UPD_DuplicateLastRowToReInsert       UPDATE  TXNOWNER.VIOL_TRANSACTIONS   SET             TXNOWNER.VIOL_TRANSACTIONS.HOST_TRANSACTION_ID = B.HOST_TRANSACTION_ID    , TXNOWNER.VIOL_TRANSACTIONS.VIOL_DATE = B.VIOL_DATE    , TXNOWNER.VIOL_TRANSACTIONS.PROCESS_FLAG = B.PROCESS_FLAG    , TXNOWNER.VIOL_TRANSACTIONS.VIOL_SERIAL_NBR = B.VIOL_SERIAL_NBR    , TXNOWNER.VIOL_TRANSACTIONS.ISF_SERIAL_NBR = B.ISF_SERIAL_NBR    , TXNOWNER.VIOL_TRANSACTIONS.LC_FLG = B.LC_FLG    , TXNOWNER.VIOL_TRANSACTIONS.VIOLATION_ID = B.VIOLATION_ID    , TXNOWNER.VIOL_TRANSACTIONS.AGENCY_CODE = B.AGENCY_CODE    , TXNOWNER.VIOL_TRANSACTIONS.TAG_ID = B.TAG_ID    , TXNOWNER.VIOL_TRANSACTIONS.REASON_CODE = B.REASON_CODE    , TXNOWNER.VIOL_TRANSACTIONS.EARNED_CLASS = B.EARNED_CLASS    , TXNOWNER.VIOL_TRANSACTIONS.EARNED_REVENUE = B.EARNED_REVENUE    , TXNOWNER.VIOL_TRANSACTIONS.POSTED_DATE = B.POSTED_DATE    , TXNOWNER.VIOL_TRANSACTIONS.POSTED_CLASS = B.POSTED_CLASS    , TXNOWNER.VIOL_TRANSACTIONS.POSTED_REVENUE = B.POSTED_REVENUE    , TXNOWNER.VIOL_TRANSACTIONS.TAG_STATUS = B.TAG_STATUS    , TXNOWNER.VIOL_TRANSACTIONS.COIN_JAM = B.COIN_JAM    , TXNOWNER.VIOL_TRANSACTIONS.ACM_OK = B.ACM_OK    , TXNOWNER.VIOL_TRANSACTIONS.AVI_OK = B.AVI_OK    , TXNOWNER.VIOL_TRANSACTIONS.TAG_CLASS = B.TAG_CLASS    , TXNOWNER.VIOL_TRANSACTIONS.LANE_ID = B.LANE_ID    , TXNOWNER.VIOL_TRANSACTIONS.VES_TIMESTAMP = B.VES_TIMESTAMP    , TXNOWNER.VIOL_TRANSACTIONS.CREATION_DATE = B.CREATION_DATE    , TXNOWNER.VIOL_TRANSACTIONS.CREATED_BY = B.CREATED_BY    , TXNOWNER.VIOL_TRANSACTIONS.UPDATED_DATE = B.UPDATED_DATE    , TXNOWNER.VIOL_TRANSACTIONS.UPDATED_BY = B.UPDATED_BY    , TXNOWNER.VIOL_TRANSACTIONS.DISPOSITION = B.DISPOSITION    , TXNOWNER.VIOL_TRANSACTIONS.HIA_AGCY_ID = B.HIA_AGCY_ID    , TXNOWNER.VIOL_TRANSACTIONS.VIOL_STATUS = B.VIOL_STATUS    , TXNOWNER.VIOL_TRANSACTIONS.LAST_UPDATE_TYPE = 'U'    , TXNOWNER.VIOL_TRANSACTIONS.LAST_UPDATE_DATE = B.INSERT_DATETIME   FROM TXNOWNER.VIOL_TRANSACTIONS_CT_UPD B   WHERE TXNOWNER.VIOL_TRANSACTIONS.TRANS_REC_ID = B.TRANS_REC_ID  
--CREATE PROC [TXNOWNER].[VIOL_TRANSACTIONS_Update_Stats] AS    EXEC DropStats 'TXNOWNER','VIOL_TRANSACTIONS'  CREATE STATISTICS STATS_VIOL_TRANSACTIONS_001 ON TXNOWNER.VIOL_TRANSACTIONS (TRANS_REC_ID)  CREATE STATISTICS STATS_VIOL_TRANSACTIONS_002 ON TXNOWNER.VIOL_TRANSACTIONS (TRANS_REC_ID, LAST_UPDATE_DATE)  CREATE STATISTICS STATS_VIOL_TRANSACTIONS_003 ON TXNOWNER.VIOL_TRANSACTIONS (LAST_UPDATE_DATE)
