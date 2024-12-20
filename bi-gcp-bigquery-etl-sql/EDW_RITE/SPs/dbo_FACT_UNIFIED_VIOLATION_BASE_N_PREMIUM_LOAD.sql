CREATE PROC [DBO].[FACT_UNIFIED_VIOLATION_BASE_N_PREMIUM_LOAD] AS 
/*

USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.FACT_UNIFIED_VIOLATION_BASE_N_PREMIUM_LOAD') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.FACT_UNIFIED_VIOLATION_BASE_N_PREMIUM_LOAD
GO

EXEC EDW_RITE.DBO.FACT_UNIFIED_VIOLATION_BASE_N_PREMIUM_LOAD
EXEC EDW_RITE_DEV.DBO.FACT_UNIFIED_VIOLATION_BASE_N_PREMIUM_LOAD



*/

IF OBJECT_ID('dbo.FACT_UNIFIED_VIOLATION_BASE_N_PREMIUM_NEW_STAGE') IS NOT NULL  DROP TABLE dbo.FACT_UNIFIED_VIOLATION_BASE_N_PREMIUM_NEW_STAGE
CREATE TABLE dbo.FACT_UNIFIED_VIOLATION_BASE_N_PREMIUM_NEW_STAGE WITH (CLUSTERED INDEX (TART_ID), DISTRIBUTION = HASH(TART_ID)) AS 
	-- EXPLAIN
WITH CTE_TRANSACTION_FEES AS
(
	SELECT 
		CASE WHEN IS_PERCENTAGE = 'Y' THEN FEE_AMOUNT / 100 ELSE 0 END AS PERC,
		CASE WHEN IS_PERCENTAGE = 'N' THEN FEE_AMOUNT ELSE 0 END AS NUMB,
		CASE WHEN FEE_TYPE_ID IN (5) THEN 1 WHEN FEE_TYPE_ID IN (4) THEN 0 ELSE NULL END AS VIDEO,
		CASE WHEN FEE_TYPE_ID IN (3) THEN 1 WHEN FEE_TYPE_ID IN (2,5) THEN 0 ELSE NULL END AS IOP,
		FACILITY_ID * 10 + 200 AS FACILITY_ID,
		EFFECTIVE_DATE,
		EXPIRY_DATE,
		FEE_TYPE_ID
	FROM  LND_LG_HOST.[TSA_OWNER].[TRANSACTION_FEES] WHERE FEE_AMOUNT > 0
)
, CTE_TART_TRANS AS
(
	SELECT   
		S.TART_ID, S.DAY_ID, S.Local_Time, S.TOLL_DUE,S.EAR_REV, S.AMOUNT, S.LANE_VIOL_STATUS,S.DISPOSITION, S.TAG_ID, l.FACILITY_ID,
		t.TRANSACTION_FILE_DETAIL_ID,t.TRANSPONDER_TOLL_AMT,t.VIDEO_TOLL_AMT_W_PREM, T.DISC_TRANSPONDER_TOLL_AMT,
		CASE WHEN LEVEL_1 = 'IOP' THEN 1 ELSE 0 END AS IOP,	CASE WHEN LEVEL_0 = 'VIDEO' THEN 1 ELSE 0 END AS VIDEO,
		CASE
			WHEN T.TRANSPONDER_DISCOUNT_TYPE IS NOT NULL AND ISNUMERIC(T.DISC_TRANSPONDER_TOLL_AMT) > 0 THEN CAST(T.DISC_TRANSPONDER_TOLL_AMT AS MONEY)
			WHEN ISNUMERIC(T.TRANSPONDER_TOLL_AMT) > 0 THEN CAST(T.TRANSPONDER_TOLL_AMT AS MONEY)
			ELSE 0
		END AS avi_rate
	FROM LND_LG_HOST.[TSA_OWNER].[TRANSACTION_FILE_DETAILS] t
	JOIN dbo.FACT_UNIFIED_VIOLATION_SNAPSHOT S ON S.TRANSACTION_FILE_DETAIL_ID = t.TRANSACTION_FILE_DETAIL_ID 
	JOIN dbo.DIM_LANE l ON l.LANE_ID = S.LANE_ID
	WHERE t.FACILITY IN ('006','007','009')
	AND t.RECEIVED_DATE >= '2016-01-01'
)
, CTE AS
(
	SELECT
		T.TART_ID,T.DAY_ID,T.LANE_VIOL_STATUS,T.DISPOSITION,T.TAG_ID,T.FACILITY_ID,T.TRANSACTION_FILE_DETAIL_ID,T.IOP,T.VIDEO,T.Local_Time,T.TOLL_DUE,T.EAR_REV,T.AMOUNT,
		CASE WHEN F.NUMB > 0 THEN F.FEE_TYPE_ID ELSE -1 END AS BASE_FEE_TYPE_ID,
		CASE WHEN F.PERC > 0 THEN F.FEE_TYPE_ID ELSE -1 END AS VARIABLE_FEE_TYPE_ID,
		D.IOP_FEE_TYPE_ID,
		T.avi_rate AS BASE_AMOUNT,
		F.NUMB AS BASE_FEE,
		CAST(ROUND(F.PERC * T.avi_rate,4) AS MONEY) AS VARIABLE_FEE,
		ISNULL(D.BASE_TRANSACTION_FEE,0)		BASE_TRANSACTION_FEE,
		ISNULL(D.VARIABLE_TRANSACTION_FEE,0)	VARIABLE_TRANSACTION_FEE,
		ISNULL(D.IOP_TRANSACTION_FEE,0)			IOP_TRANSACTION_FEE
	FROM CTE_TART_TRANS AS T
	LEFT JOIN CTE_TRANSACTION_FEES AS F ON F.FACILITY_ID = T.FACILITY_ID 
		AND T.Local_Time BETWEEN F.EFFECTIVE_DATE AND F.EXPIRY_DATE
		AND ISNULL(F.IOP, T.IOP) = T.IOP
		AND ISNULL(F.VIDEO, T.VIDEO) = T.VIDEO
	LEFT JOIN LND_LG_HOST.TSA_OWNER.DISPOSITION_FILE_DETAILS D ON D.TRANSACTION_FILE_DETAIL_ID = t.TRANSACTION_FILE_DETAIL_ID 
		AND D.DISPOSITION_TYPE_CODE = 'D' 
		AND CASE WHEN F.PERC > 0 THEN ISNULL(D.VARIABLE_TRANSACTION_FEE,0) + ISNULL(D.IOP_TRANSACTION_FEE,0) ELSE ISNULL(D.BASE_TRANSACTION_FEE,0) END > 0
)
SELECT
	TART_ID,DAY_ID,LANE_VIOL_STATUS,DISPOSITION,TAG_ID,FACILITY_ID,TRANSACTION_FILE_DETAIL_ID,IOP,VIDEO,
	MAX(Local_Time) AS	TRANSACTION_DATE,
	MAX(TOLL_DUE) AS	TOLL_DUE,
	MAX(EAR_REV) AS		EAR_REV,
	MAX(AMOUNT) AS		AMOUNT,
	MAX(BASE_FEE_TYPE_ID) AS BASE_FEE_TYPE_ID,
	MAX(VARIABLE_FEE_TYPE_ID) AS VARIABLE_FEE_TYPE_ID,
	MAX(IOP_FEE_TYPE_ID) AS IOP_FEE_TYPE_ID,
	MAX(BASE_AMOUNT) AS BASE_AMOUNT,
	MAX(BASE_FEE) AS BASE_FEE,
	MAX(VARIABLE_FEE) AS VARIABLE_FEE,
	MAX(BASE_TRANSACTION_FEE) AS BASE_TRANSACTION_FEE,
	MAX(VARIABLE_TRANSACTION_FEE) AS VARIABLE_TRANSACTION_FEE,
	MAX(IOP_TRANSACTION_FEE) AS IOP_TRANSACTION_FEE
FROM CTE
GROUP BY TART_ID,DAY_ID,LANE_VIOL_STATUS,DISPOSITION,TAG_ID,FACILITY_ID,TRANSACTION_FILE_DETAIL_ID,IOP,VIDEO


CREATE STATISTICS [STATS_FACT_UNIFIED_VIOLATION_BASE_N_PREMIUM_001] ON dbo.FACT_UNIFIED_VIOLATION_BASE_N_PREMIUM_NEW_STAGE (DAY_ID);
CREATE STATISTICS [STATS_FACT_UNIFIED_VIOLATION_BASE_N_PREMIUM_002] ON dbo.FACT_UNIFIED_VIOLATION_BASE_N_PREMIUM_NEW_STAGE ([FACILITY_ID]);
CREATE STATISTICS [STATS_FACT_UNIFIED_VIOLATION_BASE_N_PREMIUM_003] ON dbo.FACT_UNIFIED_VIOLATION_BASE_N_PREMIUM_NEW_STAGE (TRANSACTION_DATE);
CREATE STATISTICS [STATS_FACT_UNIFIED_VIOLATION_BASE_N_PREMIUM_004] ON dbo.FACT_UNIFIED_VIOLATION_BASE_N_PREMIUM_NEW_STAGE (TRANSACTION_FILE_DETAIL_ID);
CREATE STATISTICS [STATS_FACT_UNIFIED_VIOLATION_BASE_N_PREMIUM_005] ON dbo.FACT_UNIFIED_VIOLATION_BASE_N_PREMIUM_NEW_STAGE (IOP);
CREATE STATISTICS [STATS_FACT_UNIFIED_VIOLATION_BASE_N_PREMIUM_006] ON dbo.FACT_UNIFIED_VIOLATION_BASE_N_PREMIUM_NEW_STAGE (VIDEO);
CREATE STATISTICS [STATS_FACT_UNIFIED_VIOLATION_BASE_N_PREMIUM_007] ON dbo.FACT_UNIFIED_VIOLATION_BASE_N_PREMIUM_NEW_STAGE (TAG_ID);
CREATE STATISTICS [STATS_FACT_UNIFIED_VIOLATION_BASE_N_PREMIUM_008] ON dbo.FACT_UNIFIED_VIOLATION_BASE_N_PREMIUM_NEW_STAGE (LANE_VIOL_STATUS);


IF OBJECT_ID('DBO.FACT_UNIFIED_VIOLATION_BASE_N_PREMIUM_OLD') IS NOT NULL      DROP TABLE DBO.FACT_UNIFIED_VIOLATION_BASE_N_PREMIUM_OLD;
IF OBJECT_ID('DBO.FACT_UNIFIED_VIOLATION_BASE_N_PREMIUM') IS NOT NULL          RENAME OBJECT::DBO.FACT_UNIFIED_VIOLATION_BASE_N_PREMIUM TO FACT_UNIFIED_VIOLATION_BASE_N_PREMIUM_OLD;
RENAME OBJECT::DBO.FACT_UNIFIED_VIOLATION_BASE_N_PREMIUM_NEW_STAGE TO FACT_UNIFIED_VIOLATION_BASE_N_PREMIUM; 
IF OBJECT_ID('DBO.FACT_UNIFIED_VIOLATION_BASE_N_PREMIUM_OLD') IS NOT NULL      DROP TABLE DBO.FACT_UNIFIED_VIOLATION_BASE_N_PREMIUM_OLD;





--SELECT TOP 1000 * FROM dbo.FACT_UNIFIED_VIOLATION_BASE_N_PREMIUM
--WHERE DAY_ID > 20190100 AND FACILITY_ID = 270-- AND VIDEO = 0
--ORDER BY TART_ID, FEE_TYPE_ID

--SELECT TOP 1000 * FROM dbo.FACT_UNIFIED_VIOLATION_BASE_N_PREMIUM
--WHERE DAY_ID > 20190100 AND FACILITY_ID = 290 --AND VIDEO = 1 AND IOP = 1
--ORDER BY DAY_ID,TART_ID


/*
SELECT TOP 100  
t.TRANSACTION_FILE_DETAIL_ID,t.RECEIVED_DATE,t.FACILITY,t.EXIT_TRANSACTION_DATE,t.TRANSPONDER_TOLL_AMT,t.VIDEO_TOLL_AMT_W_PREM,t.EXIT_TAG_ID,t.transponder_discount_type, T.DISC_TRANSPONDER_TOLL_AMT,
s.TART_ID, S.DAY_ID, S.VIOL_DATE, S.TOLL_DUE,S.EAR_REV, S.AMOUNT, S.LANE_VIOL_STATUS,s.DISPOSITION, S.TAG_ID, l.FACILITY_ID, S.LEVEL_1
FROM LND_LG_HOST.[TSA_OWNER].[TRANSACTION_FILE_DETAILS] t
JOIN EDW_RITE.dbo.FACT_UNIFIED_VIOLATION_SNAPSHOT S ON S.TRANSACTION_FILE_DETAIL_ID = t.TRANSACTION_FILE_DETAIL_ID 
JOIN EDW_RITE.dbo.FACT_UNIFIED_VIOLATION_BASE_N_PREMIUM l ON l.LANE_ID = S.LANE_ID
WHERE t.FACILITY IN ('006','007','009')
AND t.RECEIVED_DATE > '2016-01-01'

SELECT DISTINCT LEVEL_0 FROM EDW_RITE.dbo.FACT_UNIFIED_VIOLATION_SNAPSHOT WHERE DAY_ID > 20190601
SELECT DISTINCT LEVEL_1 FROM EDW_RITE.dbo.FACT_UNIFIED_VIOLATION_SNAPSHOT WHERE DAY_ID > 20190601
SELECT DISTINCT LEVEL_2 FROM EDW_RITE.dbo.FACT_UNIFIED_VIOLATION_SNAPSHOT WHERE DAY_ID > 20190601


CASE WHEN LEVEL_1 = 'IOP' THEN 1 ELSE 0 END AS IOP
CASE WHEN LEVEL_0 = 'VIDEO' THEN 1 ELSE 0 END AS VIDEO


SELECT TOP 100 * FROM LND_LG_HOST.TSA_OWNER.DISPOSITION_FILE_DETAILS WHERE variable_transaction_fee > 0
TRANSACTION_FILE_DETAIL_ID, DISPOSITION_FILE_DETAIL_ID, DISPOSITION_TOLL_AMT, BASE_TRANSACTION_FEE, VARIABLE_TRANSACTION_FEE, IOP_TRANSACTION_FEE, NET_PAYMENT_AMOUNT


SELECT COUNT_BIG(1) FROM LND_LG_HOST.[TSA_OWNER].[TRANSACTION_FILE_DETAILS] -- 452 439 270
WHERE FACILITY IN ('006','007','009')  -- 313 748 566
AND RECEIVED_DATE > '2016-01-01' -- 273 267 528


SELECT TOP 1000 * FROM LND_LG_HOST.[TSA_OWNER].[TRANSACTION_FILE_DETAILS] -- 452 439 270
WHERE FACILITY IN ('006','007','009')  -- 313 748 566
AND RECEIVED_DATE > '2019-01-01' -- 273 267 528
TRANSACTION_FILE_DETAIL_ID,FACILITY,TRANSPONDER_TOLL_AMT,DISC_TRANSPONDER_TOLL_AMT,transponder_discount_type
VIDEO_TOLL_AMT_WO_PREM,VIDEO_TOLL_AMT_W_PREM,DISC_VIDEO_TOLL_AMT_WO_PREM,DISC_VIDEO_TOLL_AMT_W_PREM

CASE
    WHEN TRANSACTION_FILE_DETAILS.transponder_discount_type IS NOT NULL THEN
        TRANSACTION_FILE_DETAILS.disc_transponder_toll_amt
    ELSE
        TRANSACTION_FILE_DETAILS.transponder_toll_amt
    END
end AS avi_rate
ISNULL(FEE_TYPES.fee_amount / 100, 0) AS variable_avi_percentage
variable_avi_percentage * avi_rate  variable_avi_fee
DISPOSITION_FILE_DETAILS.variable_transaction_fee  AS variable_fee


SELECT * FROM   LND_LG_HOST.[TSA_OWNER].[FEE_TYPES]
FEE_TYPE_ID		FEE_TYPE_CODE	SHORT_DESC						LONG_DESCRIPTION					IS_ACTIVE	CREATED_BY		DATE_CREATED			MODIFIED_BY		DATE_MODIFIED			LAST_UPDATE_DATE			LAST_UPDATE_TYPE
1				B				Base Transaction Fee			Base Transaction Fee				Y			TSA_OWNER		2013-11-17 00:01:44		TSA_OWNER		2013-11-17 00:01:44		2019-07-08 11:53:56.000000	I
2				V				Variable Transaction Fee		Variable Transaction Fee			Y			TSA_OWNER		2013-11-17 00:01:44		TSA_OWNER		2013-11-17 00:01:44		2019-07-08 11:53:56.000000	I
3				I				IOP Transaction Fee				IOP Transaction Fee					Y			TSA_OWNER		2013-11-17 00:01:44		TSA_OWNER		2013-11-17 00:01:44		2019-07-08 11:53:56.000000	I
4				BT				Transponder Base Trans Fee		Transponder Base Transaction Fee	Y			TSA_OWNER		2016-01-22 21:51:06		TSA_OWNER		2016-01-22 21:51:06		2019-07-08 11:53:56.000000	I
5				BV				Video Base Trans Fee			Video Base Transaction Fee			Y			TSA_OWNER		2016-01-22 21:51:06		TSA_OWNER		2016-01-22 21:51:06		2019-07-08 11:53:56.000000	I

1 - FOR ALL trans
2 - FOR non IOP
3 - FOR IOP
4 - FOR Non Video  
5 - FOR non IOP video trans

SELECT 
	CASE WHEN IS_PERCENTAGE = 'Y' THEN FEE_AMOUNT ELSE 0 END AS PERC,
	CASE WHEN IS_PERCENTAGE = 'N' THEN FEE_AMOUNT ELSE 0 END AS NUMB,
	CASE WHEN FEE_TYPE_ID IN (5) THEN 1 ELSE NULL END AS VIDEO,
	CASE WHEN FEE_TYPE_ID IN (3) THEN 1 WHEN FEE_TYPE_ID IN (2,5) THEN 0 ELSE NULL END AS IOP,
	FACILITY_ID * 10 + 200 AS FACILITY_ID,
	EFFECTIVE_DATE,
	EXPIRY_DATE
FROM  LND_LG_HOST.[TSA_OWNER].[TRANSACTION_FEES] WHERE FEE_AMOUNT > 0

SELECT *
FROM  LND_LG_HOST.[TSA_OWNER].[TRANSACTION_FEES] WHERE GETDATE() BETWEEN EFFECTIVE_DATE AND EXPIRY_DATE AND FEE_AMOUNT > 0
    
    [FEE_TYPE_ID] -  FROM  LND_LG_HOST.[TSA_OWNER].[FEE_TYPES]
    [FACILITY_ID] decimal(12, 0) values (6,7,9)  - co compare WITH (260,270,290) IN EDW_RITE.dbo.FACT_UNIFIED_VIOLATION_SNAPSHOT OR WITH ('006','007','009') IN LND_LG_HOST.[TSA_OWNER].[TRANSACTION_FILE_DETAILS]
    [FEE_AMOUNT] decimal(9, 4)  
    [IS_PERCENTAGE] varchar(1)  - 'Y' OR 'N' - IF NO - [FEE_AMOUNT] IN Dollars, IF yes - PERCENT OF avi_rate (?)
    [EFFECTIVE_DATE] datetime2(0)   - USE FOR filter
    [EXPIRY_DATE] datetime2(0)  - USE FOR filter

SELECT TOP 100 * FROM  LND_LG_HOST.[TSA_OWNER].[SUBSCRIBER_LIST]

*/

/*
select *
             from (
           select nvl(fleet_agency, 'Grand Total')                                                                                        AS "Agency Abbreviation",
           facility                                                                                                                       AS "Facility",
           to_char(NVL(avi_rate, 0), '$999,999,999,990.00')                                                                               AS "Amt (AVI Rate)",
           to_char(NVL(toll_amount_paid_by_customer, 0), '$999,999,999,990.00')                                                           AS "Amt paid by DCB (Video Rate)",
           CASE WHEN NVL(avi_rate, 0) - NVL(toll_amount_paid_by_customer, 0) < 0 then '(' else null end
           || trim(CASE
                      WHEN NVL(avi_rate, 0) - NVL(toll_amount_paid_by_customer, 0) < 0
                         THEN to_char((NVL(avi_rate, 0) - NVL(toll_amount_paid_by_customer, 0)) * -1, '$999,999,999,990.00')
                      ELSE to_char(NVL(avi_rate, 0) - NVL(toll_amount_paid_by_customer, 0), '$999,999,999,990.00')
                    END)
           || CASE WHEN NVL(avi_rate, 0) - NVL(toll_amount_paid_by_customer, 0) < 0 then ')' else null end                                AS "Difference (A-B)",
           to_char(NVL(toll_amount_paid_to_subscriber, 0), '$999,999,999,990.00')                                                         AS "Amt paid to Subscriber",
           to_char(ROUND(NVL(variable_avi_fee, 0), 4), '$999,999,999,990.0000')                                                             AS "Variable Fee (AVI Rate)",
           to_char(ROUND(NVL(variable_fee, 0), 4), '$999,999,999,990.0000')                                                                 AS "Variable Fee (Video Rate)",
           CASE WHEN ROUND(NVL(variable_fee, 0), 4) - ROUND(NVL(variable_avi_fee, 0), 4) < 0 then '(' else null end
                                     
           || trim(CASE
                      WHEN ROUND(NVL(variable_fee, 0), 4) - ROUND(NVL(variable_avi_fee, 0), 4) < 0 THEN
                           to_char((ROUND(NVL(variable_fee, 0), 4) - ROUND(NVL(variable_avi_fee, 0), 4)) * -1, '$999,999,999,990.0000')
                      ELSE to_char(ROUND(NVL(variable_fee, 0), 4) - ROUND(NVL(variable_avi_fee, 0), 4), '$999,999,999,990.0000')
                   END)
           || CASE WHEN (ROUND(NVL(variable_fee, 0), 4) - ROUND(NVL(variable_avi_fee, 0), 4) < 0) then ')' else null end AS "Difference (F-E)"
     from (select fleet_agency,
                  RPAD(facility, 10) AS facility,
                  sum(avi_rate) AS avi_rate,
                  sum(variable_avi_percentage * avi_rate) variable_avi_fee,
                  sum(toll_amount_paid_by_customer) AS toll_amount_paid_by_customer,
                  sum(toll_amount_paid_to_subscriber) AS toll_amount_paid_to_subscriber,
                  sum(variable_fee) AS variable_fee
             FROM (select fleet_agency,
                          facility,
                          variable_avi_percentage,
                          violation_id,
                          avi_rate,
                          toll_amount_paid_by_customer,
                          toll_amount_paid_to_subscriber,
                          sum(NVL(variable_fee, 0)) AS variable_fee
                     FROM (
                           select fa.abbrev AS fleet_agency,
                                   NVL(s.short_description, f.abbrev) AS facility,
                                   NVL(tf.fee_amount / 100, 0) variable_avi_percentage,
                                   vi.violation_id,
                                   case
                                     when vi.transaction_file_detail_id is null then
                                      (select ctr.tag_toll
                                         from curr_toll_rate ctr, lanes l
                                        where ctr.vehicle_class = vi.vehicle_class
                                          and vi.viol_date between
                                              ctr.TOLL_START_TIME and
                                              nvl(ctr.TOLL_END_TIME, sysdate)
                                          and vi.lane_id = l.lane_id
                                          and l.plaz_id = ctr.plaza_id)
                                     else
                                     
                                       CASE
                                        WHEN tfd.transponder_discount_type IS NOT NULL THEN
                                         to_number(tfd.disc_transponder_toll_amt)
                                        ELSE
                                         to_number(tfd.transponder_toll_amt)
                                      END
                                   end AS avi_rate,
                                   vi.toll_due AS toll_amount_paid_by_customer,
                                   CASE
                                     WHEN TFD.VIDEO_DISCOUNT_TYPE IS NULL THEN
                                      CASE
                                        WHEN S.INCLUDE_PREMIUM = 'Y' THEN
                                         TFD.VIDEO_TOLL_AMT_W_PREM
                                        ELSE
                                         TFD.VIDEO_TOLL_AMT_WO_PREM
                                      END
                                     ELSE
                                      CASE
                                        WHEN S.INCLUDE_PREMIUM = 'Y' THEN
                                         TFD.DISC_VIDEO_TOLL_AMT_W_PREM
                                        ELSE
                                         TFD.DISC_VIDEO_TOLL_AMT_WO_PREM
                                      END
                                   END AS toll_amount_paid_to_subscriber,
                                   dfd.variable_transaction_fee variable_fee
                            from violations vi
                             LEFT JOIN transaction_file_details@tsa_host.world tfd
                               ON vi.transaction_file_detail_id =
                                  tfd.transaction_file_detail_id
                             LEFT JOIN disposition_file_details@tsa_host.world dfd
                               ON dfd.transaction_file_detail_id =
                                  tfd.transaction_file_detail_id
                             LEFT JOIN subscriber_list@tsa_host.world s
                               ON s.subscriber_id = tfd.subscriber_id
                                     
                             LEFT JOIN transaction_fees@tsa_host.world tf
                               ON tf.facility_id = to_number(tfd.facility)
                              AND tf.fee_type_id = 2
                              AND tf.is_percentage = 'Y'
                             JOIN fa_fleet_transactions fft
                               ON fft.violation_id = vi.violation_id
                             JOIN fa_txn_batches ftb
                               ON fft.batch_id = ftb.batch_id
                              --AND ftb.batch_id = :1
                             join fa_charge_attempts faca
                               on faca.batch_id = ftb.batch_id
                              and faca.chg_succeeded = 'Y'
                             join fa_agencies fa
                               ON fa.agency_id = ftb.agency_id
                             JOIN lanes l
                               ON fft.lane_name = l.name
                             JOIN plazas p
                               ON p.plaz_id = l.plaz_id
                              AND p.plaz_id IN (2108)
                             JOIN facilities f
                               ON f.facs_id = p.facs_id
                              AND TFD.RECEIVED_DATE >= SYSDATE-10)  
                    GROUP BY fleet_agency,
                             facility,
                             variable_avi_percentage,
                             violation_id,
                             avi_rate,
                             toll_amount_paid_by_customer,
                             toll_amount_paid_to_subscriber)
                             group by grouping sets((),(fleet_agency, facility)))
   union all
   (SELECT null fleet_agency, null short_description, 'A', 'B', 'C', 'D', 'E', 'F', 'G' from dual))

*/












