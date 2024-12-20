CREATE PROC [DBO].[FACT_VIOLATOR_TRANSACTION_LOAD] AS 

/*

USE EDW_TER
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.FACT_VIOLATOR_TRANSACTION_LOAD') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.FACT_VIOLATOR_TRANSACTION_LOAD
GO


*/

IF (SELECT COUNT_BIG(1) FROM EDW_RITE.dbo.VIOLATIONS)>0 --AND (SELECT COUNT_BIG(1) FROM EDW_RITE.dbo.FACT_TOLL_TRANSACTIONS)>0
BEGIN 


              IF OBJECT_ID('dbo.FACT_VIOLATOR_TRANSACTION_VIOLATOR_ACCOUNT_TAG_STAGE')>0
              DROP TABLE dbo.FACT_VIOLATOR_TRANSACTION_VIOLATOR_ACCOUNT_TAG_STAGE

              CREATE TABLE dbo.FACT_VIOLATOR_TRANSACTION_VIOLATOR_ACCOUNT_TAG_STAGE WITH (DISTRIBUTION = HASH(ACCT_ID), CLUSTERED INDEX (ACCT_ID, TAG_ID, ViolatorId))
              AS 
              SELECT vs.ViolatorID, vs.VidSeq
                             , vs.hvflag, v.LicPlateNbr
                             , sl.StateCode AS LIC_PLATE_STATE
                             , LatestHvTranDate AS last_qualified_tran_date
                             , HvDate AS hv_designation_start_date
                             , TermDate AS hv_designation_end_date
                             , lp.LICENSE_PLATE_ID
                             , ATH.TAG_ID
                             , ATH.ACCT_ID
                             , ATH.ASSIGNED_DATE
                             , ATH.EXPIRED_DATE
                             , ATH.DATE_CREATED
              -- SELECT COUNT(*)--SELECT top 1000 *
              FROM EDW_TER.dbo.ViolatorStatus vs
              INNER JOIN EDW_TER.dbo.Violator v ON vs.ViolatorID = v.ViolatorID AND vs.VidSeq = v.VidSeq
              INNER JOIN EDW_TER.dbo.StateLookup sl ON v.LicPlateStateLookupID = sl.StateLookupID
              INNER JOIN EDW_RITE.dbo.DIM_LICENSE_PLATE lp on v.LicPlateNbr = lp.LICENSE_PLATE_NBR AND sl.StateCode = lp.LICENSE_PLATE_STATE
              INNER JOIN EDW_RITE.dbo.ACCOUNT_TAG_HISTORY ATH on lp.LICENSE_PLATE_ID = ATH.LICENSE_PLATE_ID

              IF OBJECT_ID('dbo.FACT_VIOLATOR_TRANSACTION_NEW')>0
                             DROP TABLE dbo.FACT_VIOLATOR_TRANSACTION_NEW


              --CREATE TABLE dbo.FACT_VIOLATOR_TRANSACTION_NEW WITH (DISTRIBUTION = REPLICATE, CLUSTERED COLUMNSTORE INDEX) 
              CREATE TABLE dbo.FACT_VIOLATOR_TRANSACTION_NEW WITH (DISTRIBUTION = HASH(ViolatorID), CLUSTERED COLUMNSTORE INDEX) 
              AS 
              --- EXPLAIN
              SELECT  DISTINCT
                
                               B.ViolatorID
                             , B.VidSeq
                             , VIOLATION_ID AS TRANSACTION_ID
                             , 'V' AS VIOL_OR_TOLL_TRANSACTION
                             , LANE_ID
                             , LICENSE_PLATE_ID
                             , VIOL_STATUS
                             , -1 AS TRANS_TYPE_ID
                             , '-1' AS SOURCE_CODE
                             , VIOL_DATE AS TRANSACTION_DATE
                             , VIOL_TIME_ID AS TRANSACTION_TIME_ID
                             , TOLL_DUE
                             , TOLL_PAID
                             , POST_DATE
                             , POST_TIME_ID
                             , 0 As ZC_INVOICE_COUNT
                             , 0 As VIOL_INVOICE_COUNT
                             , STATUS_DATE
                             , DATE_EXCUSED
                             , -1  AS TOLL_TRANSACTION_CREDITED_FLAG
                             , GETDATE() AS INSERT_DATE
              FROM EDW_RITE.dbo.VIOLATIONS A
              INNER JOIN Violator B ON A.VIOLATOR_ID = B.ViolatorId
              WHERE B.CURRENT_IND = 1

              UNION ALL

              SELECT 
                               violator_id
                             , vid_seq
                             , TTXN_ID AS TRANSACTION_ID
                             , 'T' AS TRANSACTION_TYPE
                             , LANE_ID
                             , LICENSE_PLATE_ID
                             , '-1' AS VIOL_STATUS
                             , ISNULL(TRANS_TYPE_ID,-1) AS TRANS_TYPE_ID
                             , SOURCE_CODE
                             , TRANSACTION_DATE
                             , TRANSACTION_TIME_ID
                             , AMOUNT AS TOLL_DUE
                             , CASE WHEN CREDITED_FLAG = 'Y' THEN null ELSE AMOUNT END AS TOLL_PAID
                             , POSTED_DATE AS POST_DATE
                             , POSTED_TIME_ID AS POST_TIME_ID
                             , null AS ZC_INVOICE_COUNT
                             , null AS VIOL_INVOICE_COUNT
                             , '1/1/1900' AS STATUS_DATE
                             , '1/1/1900' AS DATE_EXCUSED
                             , CASE WHEN CREDITED_FLAG = 'Y' THEN 1 ELSE 0 END AS TOLL_TRANSACTION_CREDITED_FLAG
                             , GETDATE() AS INSERT_DATE                   
              from 
                             (
                                           SELECT a.ViolatorID AS violator_id, a.VidSeq AS vid_seq
                                                          ---, a.hvflag
                                                          , a.LicPlateNbr AS lic_plate_nbr
                                                          , a.LIC_PLATE_STATE
                                                          , a.last_qualified_tran_date
                                                          , a.hv_designation_start_date
                                                          , a.hv_designation_end_date
                                                          , a.LICENSE_PLATE_ID
                                                          , a.TAG_ID
                                                          , a.ACCT_ID
                                                          , a.EXPIRED_DATE
                                                          , tt.ttxn_id
                                                          , tt.posted_date
                                                          , tt.POSTED_TIME_ID
                                                          , RIGHT('00'+CONVERT(varchar(2),DATEPART(MM,tt.posted_date)),2)  + CONVERT(varchar(4),DATEPART(YYYY,tt.posted_date))  as tt_trans_mmyyyy 
                                                          , tt.amount
                                                          , tt.LANE_ID
                                                          , tt.SOURCE_CODE
                                                          , tt.TRANS_TYPE_ID
                                                          , tt.CREDITED_FLAG
                                                          , tt.TRANSACTION_DATE
                                                          , tt.TRANSACTION_TIME_ID
                                                          , ROW_NUMBER()OVER( partition by tt.ttxn_id ORDER BY (SELECT 1)) as rn
                                           -- SELECT COUNT(*)  
                                           FROM FACT_VIOLATOR_TRANSACTION_VIOLATOR_ACCOUNT_TAG_STAGE a
                                           INNER JOIN EDW_RITE.dbo.FACT_TOLL_TRANSACTIONS tt ON a.ACCT_ID = tt.ACCT_ID AND a.TAG_ID = tt.TAG_ID
                                           WHERE               a.last_qualified_tran_date <= ISNULL(a.expired_date, GETDATE())
                                                                        AND a.tag_id = tt.tag_id
                                                                        AND a.ACCT_ID = tt.ACCT_ID
                                                                        AND tt.posted_date BETWEEN hv_designation_start_date and CASE WHEN a.hv_designation_end_date = '1/1/1900' THEN GETDATE() ELSE a.hv_designation_end_date END 
                                                                        AND tt.CREDITED_FLAG <> 'Y'
                                                                        AND tt.transaction_date >= a.hv_designation_start_date
                             ) theData
              where rn = 1
              
              OPTION (LABEL = 'FACT_VIOLATOR_TRANSACTION: CTAS FACT_VIOLATOR_TRANSACTION');

              IF OBJECT_ID('dbo.FACT_VIOLATOR_TRANSACTION')>0
                             RENAME OBJECT::dbo.FACT_VIOLATOR_TRANSACTION TO FACT_VIOLATOR_TRANSACTION_OLD;

              RENAME OBJECT::dbo.FACT_VIOLATOR_TRANSACTION_NEW TO FACT_VIOLATOR_TRANSACTION;

              IF OBJECT_ID('dbo.FACT_VIOLATOR_TRANSACTION_OLD')>0
                             DROP TABLE dbo.FACT_VIOLATOR_TRANSACTION_OLD

              
              exec DropStats 'FACT_VIOLATOR_TRANSACTION' 
              -- exec CreateStats 'FACT_VIOLATOR_TRANSACTION'
              CREATE STATISTICS STATS_FACT_VIOLATOR_TRANSACTION_001 ON DBO.FACT_VIOLATOR_TRANSACTION (ViolatorId)
              CREATE STATISTICS STATS_FACT_VIOLATOR_TRANSACTION_002 ON DBO.FACT_VIOLATOR_TRANSACTION (ViolatorId, VidSeq, TRANSACTION_ID)
              CREATE STATISTICS STATS_FACT_VIOLATOR_TRANSACTION_003 ON DBO.FACT_VIOLATOR_TRANSACTION (ViolatorId, VidSeq, LICENSE_PLATE_ID)
              CREATE STATISTICS STATS_FACT_VIOLATOR_TRANSACTION_004 ON [dbo].FACT_VIOLATOR_TRANSACTION (VIOL_OR_TOLL_TRANSACTION)
              CREATE STATISTICS STATS_FACT_VIOLATOR_TRANSACTION_005 ON [dbo].FACT_VIOLATOR_TRANSACTION (ViolatorID, VidSeq, LANE_ID, LICENSE_PLATE_ID)
              CREATE STATISTICS STATS_FACT_VIOLATOR_TRANSACTION_006 ON [dbo].FACT_VIOLATOR_TRANSACTION (LANE_ID)
              CREATE STATISTICS STATS_FACT_VIOLATOR_TRANSACTION_007 ON [dbo].FACT_VIOLATOR_TRANSACTION (ViolatorID, VidSeq, LANE_ID)
              CREATE STATISTICS STATS_FACT_VIOLATOR_TRANSACTION_008 ON [dbo].FACT_VIOLATOR_TRANSACTION (LICENSE_PLATE_ID)
              --CREATE STATISTICS STATS_FACT_VIOLATOR_TRANSACTION_006 ON [dbo].FACT_VIOLATOR_TRANSACTION (VIOL_STATUS)
              --CREATE STATISTICS STATS_FACT_VIOLATOR_TRANSACTION_008 ON [dbo].FACT_VIOLATOR_TRANSACTION (TRANS_TYPE_ID)
              --CREATE STATISTICS STATS_FACT_VIOLATOR_TRANSACTION_009 ON [dbo].FACT_VIOLATOR_TRANSACTION (SOURCE_CODE)
              CREATE STATISTICS STATS_FACT_VIOLATOR_TRANSACTION_010 ON [dbo].FACT_VIOLATOR_TRANSACTION (TRANSACTION_DATE, TRANSACTION_TIME_ID)
              --CREATE STATISTICS STATS_FACT_VIOLATOR_TRANSACTION_012 ON [dbo].FACT_VIOLATOR_TRANSACTION (TOLL_DUE)
              --CREATE STATISTICS STATS_FACT_VIOLATOR_TRANSACTION_013 ON [dbo].FACT_VIOLATOR_TRANSACTION (TOLL_PAID)
              CREATE STATISTICS STATS_FACT_VIOLATOR_TRANSACTION_014 ON [dbo].FACT_VIOLATOR_TRANSACTION (POST_DATE, POST_TIME_ID)
              --CREATE STATISTICS STATS_FACT_VIOLATOR_TRANSACTION_016 ON [dbo].FACT_VIOLATOR_TRANSACTION (ZC_INVOICE_COUNT)
              --CREATE STATISTICS STATS_FACT_VIOLATOR_TRANSACTION_017 ON [dbo].FACT_VIOLATOR_TRANSACTION (VIOL_INVOICE_COUNT)
              --CREATE STATISTICS STATS_FACT_VIOLATOR_TRANSACTION_018 ON [dbo].FACT_VIOLATOR_TRANSACTION (STATUS_DATE)
              --CREATE STATISTICS STATS_FACT_VIOLATOR_TRANSACTION_019 ON [dbo].FACT_VIOLATOR_TRANSACTION (DATE_EXCUSED)
              --CREATE STATISTICS STATS_FACT_VIOLATOR_TRANSACTION_020 ON [dbo].FACT_VIOLATOR_TRANSACTION (INSERT_DATE)

              
              IF OBJECT_ID('dbo.FACT_VIOLATOR_TRANSACTION_ViolatorStatus_TollTransactionCount_STAGE')>0
                             DROP TABLE dbo.FACT_VIOLATOR_TRANSACTION_ViolatorStatus_TollTransactionCount_STAGE

              CREATE TABLE dbo.FACT_VIOLATOR_TRANSACTION_ViolatorStatus_TollTransactionCount_STAGE WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (ViolatorID, VidSeq))
              AS 
                             SELECT A.ViolatorID, A.VidSeq, COUNT(*) AS TollTransactionCount
                             FROM dbo.FACT_VIOLATOR_TRANSACTION A
                             WHERE VIOL_OR_TOLL_TRANSACTION = 'T'
                             GROUP BY A.ViolatorID, A.VidSeq


              UPDATE dbo.ViolatorStatus
              SET 
                              TollTransactionCount = B.TollTransactionCount
              FROM FACT_VIOLATOR_TRANSACTION_ViolatorStatus_TollTransactionCount_STAGE B
              WHERE dbo.ViolatorStatus.ViolatorID = B.ViolatorID AND dbo.ViolatorStatus.VidSeq = B.VidSeq


              IF OBJECT_ID('dbo.FACT_VIOLATOR_TRANSACTION_ViolatorStatus_TollTagAccount_STAGE')>0
                             DROP TABLE dbo.FACT_VIOLATOR_TRANSACTION_ViolatorStatus_TollTagAccount_STAGE

              CREATE TABLE dbo.FACT_VIOLATOR_TRANSACTION_ViolatorStatus_TollTagAccount_STAGE WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (ViolatorID, VidSeq))
              AS 
              
                             SELECT DISTINCT A.ViolatorID, A.VidSeq, A.ACCT_ID, ISNULL(B.ACCT_STATUS_CODE, '-1') AS ACCT_STATUS_CODE, B.BALANCE_AMT
                                           , ISNULL(B.PMT_TYPE_CODE,'-1') AS PMT_TYPE_CODE, B.REBILL_AMT, B.REBILL_DATE, B.BAL_LAST_UPDATED, Sub.DATE_CREATED
                             FROM dbo.FACT_VIOLATOR_TRANSACTION_VIOLATOR_ACCOUNT_TAG_STAGE A
                             INNER JOIN 
                                           (
                                                          SELECT DISTINCT AA.ViolatorID, AA.VidSeq, MAX(AA.ACCT_ID) AS ACCT_ID, MAX(DATE_CREATED) DATE_CREATED
                                                          FROM dbo.FACT_VIOLATOR_TRANSACTION_VIOLATOR_ACCOUNT_TAG_STAGE AA
                                                          GROUP BY AA.ViolatorID, AA.VidSeq
                                           ) Sub ON A.ViolatorID = Sub.ViolatorID AND A.VidSeq = Sub.VidSeq AND A.ACCT_ID = Sub.ACCT_ID 
                             INNER JOIN edw_rite.dbo.ACCOUNTS B ON A.ACCT_ID = B.ACCT_ID



                             /*
                                           SELECT ViolatorID, VidSeq
                                           FROM FACT_VIOLATOR_TRANSACTION_ViolatorStatus_TollTagAccount_STAGE
                                           GROUP BY ViolatorID, VidSeq
                                           HAVING COUNT(*)>1

              
                                           SELECT ViolatorID, VidSeq, TAG_ID
                                           FROM FACT_VIOLATOR_TRANSACTION_VIOLATOR_ACCOUNT_TAG_STAGE
                                           GROUP BY ViolatorID, VidSeq, TAG_ID
                                           HAVING COUNT(*)>1

                                           SELECT COUNT(*) 
                                           FROM FACT_VIOLATOR_TRANSACTION_VIOLATOR_ACCOUNT_TAG_STAGE
                                           WHERE ViolatorID  =      745146790

              
                                           SELECT * 
                                           FROM FACT_VIOLATOR_TRANSACTION_ViolatorStatus_TollTagAccount_STAGE
                                           WHERE ViolatorID  =      745146790

                             */
              



              UPDATE dbo.ViolatorStatus
              SET HAS_TOLL_TAG_ACCOUNT = 0
                             , ACCT_STATUS_CODE = '-1'
                             , BALANCE_AMOUNT = 0 
                             , PMT_TYPE_CODE = '-1'
                             , REBILL_AMT = null
                             , REBILL_DATE = null
                             , BAL_LAST_UPDATED = null
                             , TAG_DATE_CREATED = null

              UPDATE dbo.ViolatorStatus
              SET 
                              ACCT_ID = B.ACCT_ID 
                             ,ACCT_STATUS_CODE = ISNULL(B.ACCT_STATUS_CODE,'-1')
                             ,HAS_TOLL_TAG_ACCOUNT = 1
                             ,BALANCE_AMOUNT = B.BALANCE_AMT
                             , PMT_TYPE_CODE = ISNULL(B.PMT_TYPE_CODE,'-1')
                             , REBILL_AMT = B.REBILL_AMT
                             , REBILL_DATE = B.REBILL_DATE
                             , BAL_LAST_UPDATED = B.BAL_LAST_UPDATED
                             , TAG_DATE_CREATED = B.DATE_CREATED

              FROM FACT_VIOLATOR_TRANSACTION_ViolatorStatus_TollTagAccount_STAGE B
              WHERE dbo.ViolatorStatus.ViolatorID = B.ViolatorID AND dbo.ViolatorStatus.VidSeq = B.VidSeq

              -- TODO FIX THIS: Not Sure why ACCT_STATUS_CODE was not getting set
              UPDATE dbo.ViolatorStatus
              SET 
                              ACCT_ID = B.ACCT_ID 
                             ,ACCT_STATUS_CODE = ISNULL(B.ACCT_STATUS_CODE,'-1')
                             ,PMT_TYPE_CODE = ISNULL(B.PMT_TYPE_CODE,'-1')
                             ,BALANCE_AMOUNT = B.BALANCE_AMT
                             ,REBILL_AMT = B.REBILL_AMT
                             , REBILL_DATE = B.REBILL_DATE
                             , BAL_LAST_UPDATED = B.BAL_LAST_UPDATED
              FROM EDW_RITE.dbo.ACCOUNTS B
              WHERE dbo.ViolatorStatus.ACCT_ID = B.ACCT_ID 
                             --AND 
                             --(dbo.ViolatorStatus.ACCT_STATUS_CODE = '-1' OR dbo.ViolatorStatus.PMT_TYPE_CODE = '-1')




              --IF OBJECT_ID('dbo.FACT_VIOLATOR_TRANSACTION_VIOLATOR_ACCOUNT_TAG_STAGE')>0
              --            DROP TABLE dbo.FACT_VIOLATOR_TRANSACTION_VIOLATOR_ACCOUNT_TAG_STAGE

              
              IF OBJECT_ID('dbo.FACT_VIOLATOR_TRANSACTION_ViolatorStatus_TollTransactionCount_STAGE')>0
                             DROP TABLE dbo.FACT_VIOLATOR_TRANSACTION_ViolatorStatus_TollTransactionCount_STAGE


              IF OBJECT_ID('dbo.FACT_VIOLATOR_TRANSACTION_ViolatorStatus_TollTagAccount_STAGE')>0
                             DROP TABLE dbo.FACT_VIOLATOR_TRANSACTION_ViolatorStatus_TollTagAccount_STAGE

END

/*

              SELECT * FROM ViolatorStatus ORDER BY BALANCE_AMOUNT DESC

              select A.*, B.*
              FROM Violator A
              INNER JOIN ViolatorStatus B ON A.ViolatorID = B.ViolatorID AND A.VidSeq = B.VidSeq
              where ACCT_ID = 2707860

              SELECT ViolatorID, VidSeq, TRANSACTION_ID, VIOL_OR_TOLL_TRANSACTION, COUNT(*)
              FROM dbo.FACT_VIOLATOR_TRANSACTION
              GROUP BY ViolatorID, VidSeq, TRANSACTION_ID, VIOL_OR_TOLL_TRANSACTION
              HAVING COUNT(*)>1

              SELECT COUNT(*)
              FROM dbo.FACT_VIOLATOR_TRANSACTION
              

*/


