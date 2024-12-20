CREATE PROC [DBO].[zzzFACT_UNIFIED_VIOLATION_LOAD] AS --DROP PROC [DBO].[FACT_UNIFIED_VIOLATION_LOAD]  
/*	SELECT TOP 100 * FROM FACT_UNIFIED_VIOLATION where viol_type = 'm' is not null; SELECT MIN(DAY_ID), max(DAY_ID) FROM FACT_UNIFIED_VIOLATION_STAGE; SELECT TOP 100 * FROM FACT_UNIFIED_VIOLATION_STAGE  */  
--#1	RANJITH NAIR	2018-02-09	CREATED 905,167,274 --SELECT DISTINCT LEVEL_1,LEVEL_2,LEVEL_3,LEVEL_4,LEVEL_5,LEVEL_6,LEVEL_7--,LANE_VIOL_STATUS_DESCR,LANE_STATUS_DESCR,LANE_REV_STATUS_DESCR,VIOL_REJECT_TYPE_DESCR, VIOL_STATUS_DESCR,VIOL_TYPE,REV_STATUS_DESCR,SC_DESCR,SOURCE_CODE_GROUP --FROM FACT_UNIFIED_VIOLATION   --where LEVEL_6 like 'Converted to%'--ORDER BY 1,2,3,4,5,6,7
 --#2	RANJITH NAIR	2018-07-25	Upaded Hierarchy 
 --#3	RANJITH NAIR	2018-09-07	Split the TSA query using UNION ALL 
 --#4   RANJITH NAIR	2018-09-08	Uncommented DMV.DMV_STS,BR.TXN_NAME,NP.REVIEW_STATUS_ABBREV NOT_TRANS_REVIEW_STATUS_ABBREV
 --#5   RANJITH NAIR	2018-09-20	CONVERTED TO CTE
 --#6   RANJITH NAIR	2018-09-27	Added IOP.Source_code IN ('H') --for TART_ID AND	VIOP.Source_code IN ('V') --for TRANSACTION_ID 
 --#7   RANJITH NAIR	2018-11-08	Added UnInvoiced Statuses  
 --#8   RANJITH NAIR	2018-11-11	ADDED INV BAD ADDRESS  
 --#9   RANJITH NAIR	2018-11-17	ADDED INVOICE_STAGE_ID, No Image, Not Transferred to VPS, Manually Entered Violations

DECLARE @FROM_DAY_ID  INT = 20160101; 
DECLARE @FROM_DATE DATETIME = (SELECT CAST(CAST(@FROM_DAY_ID as VARCHAR) AS DATETIME)); --PRINT @FROM_DATE;
DECLARE @TO_DAY_ID  INT = 20161231
DECLARE @TO_DATE DATETIME = (SELECT DATEADD(SECOND, 86399, CAST(CAST(@TO_DAY_ID as VARCHAR) AS DATETIME)) );-- PRINT @TO_DATE;


	--STEP #0: --DROP table IF EXISTS  
	IF OBJECT_ID('dbo.FACT_UNIFIED_VIOLATION_STAGE')>0 	DROP TABLE dbo.FACT_UNIFIED_VIOLATION_STAGE;	--DECLARE @FROM_DAY_ID  INT = 20180101, @TO_DAY_ID  INT = 20180101;
	CREATE TABLE dbo.FACT_UNIFIED_VIOLATION_STAGE WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH([DAY_ID])) AS --DECLARE @FROM_DAY_ID  INT = 20180101, @TO_DAY_ID  INT = 20180101; DECLARE @FROM_DATE DATETIME = (SELECT CAST(CAST(@FROM_DAY_ID as VARCHAR) AS DATETIME)); DECLARE @TO_DATE DATETIME = (SELECT DATEADD(SECOND, 86399, CAST(CAST(@TO_DAY_ID as VARCHAR) AS DATETIME)) );EXPLAIN
	WITH DMV AS 
	( SELECT DMV.VIOLATION_ID, ISNULL(DMV.DMV_STS,'-1') DMV_STS FROM EDW_RITE.[dbo].FACT_VIOLATIONS_DMV_STATUS_DETAIL DMV WHERE DMV.[DAY_ID] BETWEEN @FROM_DAY_ID AND @TO_DAY_ID AND DMV.DMV_STS NOT IN ('VIOL-TX')
	),-- SELECT COUNT_BIG(1) FROM DMV
	 NP AS 
	( SELECT NP.LANE_VIOL_ID, ISNULL(NP.REVIEW_STATUS_ABBREV,'-1') NOT_TRANS_REVIEW_STATUS_ABBREV FROM EDW_RITE.[dbo].FACT_NOT_TRANSFERRED_TO_VPS_DETAIL NP  WHERE NP.[DAY_ID] BETWEEN @FROM_DAY_ID AND @TO_DAY_ID
	),-- SELECT COUNT_BIG(1) FROM NP
	 BR AS 
	( SELECT BR.VIOLATION_ID, ISNULL(BR.TXN_NAME,'-1') TXN_NAME FROM EDW_RITE.[dbo].FACT_VIOLATIONS_BR_DETAIL BR WHERE BR.[DAY_ID] BETWEEN @FROM_DAY_ID AND @TO_DAY_ID
	),-- SELECT COUNT_BIG(1) FROM BR
	 HT AS 
	( SELECT TTXN_ID, TRANSACTION_FILE_DETAIL_ID, HT.AMOUNT, HT.POSTED_DATE, HT.SOURCE_CODE, HT.ACCT_ID, HT.TAG_ID,AGENCY_ID,LIC_PLATE,LIC_STATE FROM EDW_RITE.[dbo].FACT_TOLL_TRANSACTIONS HT WHERE HT.[DAY_ID] BETWEEN @FROM_DAY_ID AND @TO_DAY_ID
	),-- SELECT COUNT_BIG(1) FROM HT
	IOP  AS 
	( SELECT SOURCE_TXN_ID, TRANSACTION_FILE_DETAIL_ID, POSTED_REVENUE, POSTED_DATE, SOURCE_CODE, TAG_ID,ITA.TAG_IDENTIFIER AS TAG_AGENCY_ID FROM EDW_RITE.[dbo].FACT_IOP_TGS TGS LEFT JOIN LND_LG_IOP.IOP_OWNER.IOP_TAG_AUTHORITIES ITA ON TGS.TAG_AGENCY_ID = ITA.TAG_AGENCY_ID WHERE [DAY_ID] BETWEEN @FROM_DAY_ID AND @TO_DAY_ID AND DISPOSITION = 'P'
	),-- SELECT COUNT_BIG(1) FROM IOP
	L  AS 
	( SELECT LANE_VIOL_ID,VIOLATION_ID, TRANSACTION_FILE_DETAIL_ID, VIOL_DATE, AXLE_COUNT, ISNULL(CAST(LANE_VIOL_STATUS AS VARCHAR(2)),'-1') LANE_VIOL_STATUS,ISNULL(CAST(REVIEW_STATUS AS VARCHAR(2)),'-1') LANE_REVIEW_STATUS,
			 VIOLATION_CODE,VIOL_CREATED,LIC_PLATE_NBR,LIC_PLATE_STATE,REVIEW_DATE,ISNULL(VIOL_REJECT_TYPE,'-1') VIOL_REJECT_TYPE,
			 TOLL_DUE, TOLL_PAID
	  FROM EDW_RITE.[dbo].FACT_LANE_VIOLATIONS_DETAIL L WHERE [DAY_ID] BETWEEN @FROM_DAY_ID AND @TO_DAY_ID
	),-- SELECT COUNT_BIG(1) FROM L
	V  AS 
	( SELECT VIOLATION_ID,TRANSACTION_FILE_DETAIL_ID,ISNULL(V.VIOL_STATUS,'-1') VIOL_STATUS,VIOL_DATE,STATUS_DATE,VIOL_TYPE,DRIVER_LIC_STATE,VIOLATOR_ID,LIC_PLATE_NBR,LIC_PLATE_STATE,TOLL_DUE,TOLL_PAID
	  FROM EDW_RITE.[dbo].FACT_VIOLATIONS_DETAIL V WHERE [DAY_ID] BETWEEN @FROM_DAY_ID AND @TO_DAY_ID
	),-- SELECT COUNT_BIG(1) FROM V
	I AS 
	( SELECT V.VIOLATION_ID,VBI_INVOICE_ID,VIOL_INVOICE_ID,PAYMENT_DATE,SPLIT_AMOUNT,FEES_PAID,I.TOLL_PAID,VBI_INVOICE_DATE,VBI_STATUS,VI_INVOICE_DATE,VIOL_INV_STATUS,INVOICE_STAGE_ID
		FROM V JOIN FACT_UNIFIED_VIOLATION_INVOICE I ON V.VIOLATION_ID = I.VIOLATION_ID
	),-- SELECT COUNT_BIG(1) FROM I
	VHT AS 
	( SELECT TRANSACTION_ID,ISNULL(CAST(DISPOSITION AS VARCHAR(2)),'-1') [DISPOSITION],VTOLL_SEND_DATE FROM LND_LG_VPS.[VP_OWNER].[VPS_HOST_TRANSACTIONS] WHERE VIOL_DATE BETWEEN @FROM_DATE AND @TO_DATE AND [DISPOSITION] = 'P'
	),-- SELECT COUNT_BIG(1) FROM VHT
	F AS 
	( SELECT TART_ID,DAY_ID,ISNULL(F.PMTY_ID,-1) PMTY_ID,VES_SERIAL_NO,F.LANE_ID,F.Local_Time,F.VCLY_ID,AVI_TAG_STATUS,F.EAR_REV,COALESCE(AVIT_POSTED_REVENUE, ACT_REV) POS_REV,F.TXID_ID,F.TRANSACTION_FILE_DETAIL_ID FROM FACT_NET_REV_TFC_EVTS F WHERE [DAY_ID] BETWEEN @FROM_DAY_ID AND @TO_DAY_ID AND TART_ID IS NOT NULL
	),-- SELECT COUNT_BIG(1) FROM F
	HIX AS 
	( SELECT F.TART_ID,LANE_VIOL_ID FROM F JOIN EDW_RITE.[dbo].[HOST_ICRS_XREF] HIX ON F.TART_ID = HIX.TART_ID 
	),-- SELECT COUNT_BIG(1) FROM HIX
	IVX AS 
	( SELECT L.LANE_VIOL_ID,TRANSACTION_ID FROM L JOIN EDW_RITE.[dbo].ICRS_VPS_XREF IVX ON L.LANE_VIOL_ID = IVX.LANE_VIOL_ID	
	),-- SELECT COUNT_BIG(1) FROM IVX
	VTX AS 
	( SELECT IVX.TRANSACTION_ID,TTXN_ID FROM IVX JOIN EDW_RITE.[dbo].VPS_TGS_XREF VTX ON VTX.TRANSACTION_ID = IVX.TRANSACTION_ID	
	),-- SELECT COUNT_BIG(1) FROM IVX
	HTX AS 
	( SELECT F.TART_ID,TTXN_ID FROM F JOIN EDW_RITE.[dbo].HOST_TGS_XREF HTX ON HTX.TART_ID = F.TART_ID	
	)-- SELECT COUNT_BIG(1) FROM IVX
	SELECT  CASE 
               WHEN TXID_ID = - 14800
                       THEN 'AUTO FLUSHES'
               WHEN PMTY_ID NOT IN (
                               3
                               ,7
                               ,8
                               )
                       THEN 'CASH/UNPAID/NON-REV'
               WHEN PMTY_ID = 3
                       AND TXID_ID = - 13800
                       THEN 'TAGFLUSH'
               WHEN PMTY_ID = 3
                       THEN 'AVI'
               WHEN PMTY_ID IN (
                               7
                               ,8
                               )
                       THEN 'VIDEO'
               ELSE 'NOT POSTED'
               END AS LEVEL_0
			,CASE 
               WHEN PMTY_ID = 6
                       THEN 'NON-REV'
               WHEN PMTY_ID = 3
                       AND TXID_ID = - 13800
                       THEN 'TAGFLUSH'
               WHEN PMTY_ID = 3
                       AND ISNULL(COALESCE(TT.ACCT_ID,HT.ACCT_ID),'-1') = '-1'						-- ACCT_ID
                       AND ISNULL(COALESCE(TT.TAG_ID,HT.TAG_ID,IOP.TAG_ID,VIOP.TAG_ID),'-1') <> '-1'--TAG_ID
                       THEN 'IOP'
               WHEN PMTY_ID = 3
                       THEN 'TOLLTAG'
				WHEN PMTY_ID IN (7, 8) AND VES_SERIAL_NO = 0
						THEN 'No Image'
               WHEN LANE_REVIEW_STATUS IN (
                               'D'
                               ,'R'
                               ,'E'
                               ,'F'
                               ,'O'
                               ,'N'
                               )
                       THEN 'IMAGES ENTERING ICRS'
               ELSE 'IMAGES NOT ENTERING ICRS'
               END AS LEVEL_1
			,CASE 
               WHEN LANE_REVIEW_STATUS IN ('O')
                       THEN 'Auto OCR Pass'
               WHEN LANE_REVIEW_STATUS IN (
                               'D'
                               ,'R'
                               ,'E'
                               )
                       THEN 'Manual Review'
               WHEN LANE_REVIEW_STATUS IN ('N')
                       THEN 'Pending Review'
                ELSE '-1'
              END  AS LEVEL_2
           ,CASE 
               WHEN LANE_REVIEW_STATUS IN ('D')
                       THEN 'Images Discarded'
               WHEN LANE_REVIEW_STATUS IN (
                               'R'
                               ,'E'
                               )
                       THEN 'Images Kept'
               WHEN LANE_REVIEW_STATUS IN ('N')
                       THEN 'Not Transferred to VPS'
                ELSE '-1'
              END  AS LEVEL_3
			,CASE 
               WHEN VIOL_REJECT_TYPE = 'NR'
                       THEN 'Variance Pool'
               WHEN VIOL_REJECT_TYPE = 'RO'
                       THEN 'OCR Rejects'
                ELSE ISNULL(VIOL_REJECT_TYPE,'-1')
               END AS LEVEL_4
			,ISNULL(LANE_VIOL_STATUS,'-1') LEVEL_5
			,CASE 
               WHEN VIOL_STATUS IN (
                               'ZH'
                               ,'WJ'
                               )
                       THEN 'DMV Match Processing'
               WHEN VIOL_STATUS = 'ZI'
                       THEN 'Aged To Violation Invoices'
               ELSE ISNULL(VIOL_STATUS,'-1')
               END  AS LEVEL_6
			,CASE 
               WHEN VIOL_STATUS = 'P'
                       AND VBI_INVOICE_ID IS NULL
                       AND VIOL_INVOICE_ID IS NULL
                       THEN 'UNINVD'
               WHEN VIOL_STATUS = 'P'
                       AND (
                               VBI_INVOICE_ID IS NOT NULL
                               OR VIOL_INVOICE_ID IS NOT NULL
                               )
                       THEN 'INVD'
               WHEN  VBI_STATUS  = 'B' OR VIOL_INV_STATUS IN ('A', 'B')
                       THEN 'INV-BAD-ADD'
                 ELSE '-1'
              END AS LEVEL_7
			,CASE 
               WHEN DMV_STS IN (
                               'VIOL-NTX'
                               ,'VIOL-TX'
                               ,'LP-M-VLTR'
                               ,'LP-NDMV'
                               ,'LP-NV-TIME'
                               ,'LP-OTHER'
                               )
                       THEN 'VIOL-UM-DMV'
               WHEN DMV_STS = 'VIOL-M-DMV'
                       THEN 'VIOL-M-DMV'
               ELSE '-1'
               END  AS LEVEL_8
			,CASE 
               WHEN TXN_NAME IN (
                               'VIOL-UBR-C'
                               ,'VIOL-UBR-N'
                               )
                       THEN 'VIOL-UBR'
               WHEN DMV_STS IN (
                               'LP-M-VLTR'
                               ,'LP-NDMV'
                               ,'LP-NV-TIME'
                               ,'LP-OTHER'
                               )
                       THEN 'VIOL-TX'
               WHEN DMV_STS = 'VIOL-NTX'
                       THEN 'VIOL-NTX'
               ELSE ISNULL(TXN_NAME,'-1')
               END AS LEVEL_9
			,CASE 
               WHEN TXN_NAME IN (
                               'VIOL-UBR-C'
                               ,'VIOL-UBR-N'
                               )
                       THEN TXN_NAME
               WHEN DMV_STS IN (
                               'LP-M-VLTR'
                               ,'LP-NDMV'
                               ,'LP-NV-TIME'
                               ,'LP-OTHER'
                               )
                       THEN DMV_STS
               ELSE '-1'
               END AS LEVEL_10,
			F.TART_ID,F.DAY_ID,ISNULL(F.PMTY_ID,-1) PMTY_ID,VCLY_ID,AVI_TAG_STATUS,F.LANE_ID,F.Local_Time,F.EAR_REV,COALESCE(IOP.POSTED_REVENUE, POS_REV) POS_REV
			,F.TXID_ID,F.TRANSACTION_FILE_DETAIL_ID--F.VES_DATE_TIME,F.VES_SERIAL_NO,L.LANE_ABBREV,
			,L.LANE_VIOL_ID,COALESCE(V.VIOL_DATE, L.VIOL_DATE) VIOL_DATE,L.AXLE_COUNT,--L.LANE_VIOL_STATUS_DESCR,
			LANE_VIOL_STATUS,LANE_REVIEW_STATUS,--L.REVIEW_STATUS_ABBREV LANE_REVIEW_STATUS_ABBREV,L.STATUS_DESCR LANE_STATUS_DESCR,--L.VEHICLE_CLASS,L.REV_STATUS_DESCR LANE_REV_STATUS_DESCR,
			L.VIOLATION_CODE,--L.VIOL_REJECT_TYPE_DESCR,  
			L.VIOL_CREATED,COALESCE(L.LIC_PLATE_NBR,V.LIC_PLATE_NBR,HT.LIC_PLATE,TT.LIC_PLATE)LIC_PLATE_NBR,
			COALESCE(L.LIC_PLATE_STATE,V.LIC_PLATE_STATE,HT.LIC_STATE,TT.LIC_STATE)LIC_PLATE_STATE,L.REVIEW_DATE,VIOL_REJECT_TYPE,
			COALESCE(L.TOLL_DUE,V.TOLL_DUE)TOLL_DUE, COALESCE(L.TOLL_PAID,V.TOLL_PAID)TOLL_PAID,
			COALESCE(V.VIOLATION_ID,L.VIOLATION_ID) VIOLATION_ID,--V.STATUS_DESCR VIOL_STATUS_DESCR,
			V.STATUS_DATE,V.VIOL_TYPE,V.DRIVER_LIC_STATE,V.VIOLATOR_ID,--V.REV_STATUS_DESCR,--V.LANE_VIOL_ID,V.TRANSACTION_ID,
			VIOL_STATUS,--V.REVIEW_STATUS,
			VHT.TRANSACTION_ID,DISPOSITION,VHT.VTOLL_SEND_DATE,	
			COALESCE(TT.TTXN_ID,HT.TTXN_ID,IOP.SOURCE_TXN_ID,VIOP.SOURCE_TXN_ID) TTXN_ID,
			COALESCE(TT.AMOUNT,HT.AMOUNT,IOP.POSTED_REVENUE,VIOP.POSTED_REVENUE) AMOUNT,
			COALESCE(TT.POSTED_DATE,HT.POSTED_DATE,IOP.POSTED_DATE,VIOP.POSTED_DATE) POSTED_DATE,CAST(CONVERT(VARCHAR, COALESCE(TT.POSTED_DATE,HT.POSTED_DATE,IOP.POSTED_DATE,VIOP.POSTED_DATE) ,112) AS INT) POSTED_DAY_ID,
			ISNULL(CAST(COALESCE(TT.SOURCE_CODE,HT.SOURCE_CODE,IOP.SOURCE_CODE,VIOP.SOURCE_CODE)AS VARCHAR(2)),'-1') SOURCE_CODE,--			SC_DESCR,SOURCE_CODE_GROUP,
			ISNULL(COALESCE(TT.ACCT_ID,HT.ACCT_ID),'-1') ACCT_ID, ISNULL(COALESCE(TT.TAG_ID,HT.TAG_ID,IOP.TAG_ID,VIOP.TAG_ID),'-1') TAG_ID, 
			ISNULL(COALESCE(TT.AGENCY_ID,HT.AGENCY_ID,IOP.TAG_AGENCY_ID,VIOP.TAG_AGENCY_ID),'-1') TAG_AGENCY_ID,DMV_STS,TXN_NAME, NOT_TRANS_REVIEW_STATUS_ABBREV,
			VBI_INVOICE_ID,VIOL_INVOICE_ID,PAYMENT_DATE,SPLIT_AMOUNT,I.FEES_PAID,I.TOLL_PAID AS AMT_PAID,VBI_INVOICE_DATE,VBI_STATUS,VI_INVOICE_DATE,VIOL_INV_STATUS,INVOICE_STAGE_ID
			--SELECT COUNT_BIG(1)
	FROM		F																									--EDW_RITE.[dbo].[FACT_NET_REV_TFC_EVTS]
	LEFT JOIN  HIX ON F.TART_ID = HIX.TART_ID																		--EDW_RITE.[dbo].[HOST_ICRS_XREF]
	LEFT JOIN  L	ON L.LANE_VIOL_ID = HIX.LANE_VIOL_ID AND L.TRANSACTION_FILE_DETAIL_ID IS NULL					--EDW_RITE.[dbo].FACT_LANE_VIOLATIONS_DETAIL 
	LEFT JOIN  V	ON V.VIOLATION_ID = L.VIOLATION_ID AND V.TRANSACTION_FILE_DETAIL_ID IS NULL						--EDW_RITE.[dbo].FACT_VIOLATIONS_DETAIL 
	LEFT JOIN  I	ON V.VIOLATION_ID = I.VIOLATION_ID																--EDW_RITE.[dbo].FACT_UNIFIED_VIOLATION_INVOICE
	LEFT JOIN  IVX	ON L.LANE_VIOL_ID = IVX.LANE_VIOL_ID															--EDW_RITE.[dbo].ICRS_VPS_XREF
	LEFT JOIN  IOP	ON IOP.SOURCE_TXN_ID = F.TART_ID  AND IOP.TRANSACTION_FILE_DETAIL_ID IS NULL					--EDW_RITE.[dbo].FACT_IOP_TGS
		 AND	IOP.Source_code IN ('H') --for TART_ID
	LEFT JOIN  VHT	ON VHT.TRANSACTION_ID = IVX.TRANSACTION_ID														--LND_LG_VPS.[VP_OWNER].[VPS_HOST_TRANSACTIONS]
	LEFT JOIN  IOP AS VIOP ON VIOP.SOURCE_TXN_ID = VHT.TRANSACTION_ID AND VIOP.TRANSACTION_FILE_DETAIL_ID IS NULL	--EDW_RITE.[dbo].FACT_IOP_TGS
		 AND	VIOP.Source_code IN ('V') --for TRANSACTION_ID 
	LEFT JOIN  VTX	ON VTX.TRANSACTION_ID = IVX.TRANSACTION_ID														--EDW_RITE.[dbo].VPS_TGS_XREF
	LEFT JOIN  HT AS TT ON TT.TTXN_ID = VTX.TTXN_ID  AND TT.TRANSACTION_FILE_DETAIL_ID IS NULL						--EDW_RITE.[dbo].FACT_TOLL_TRANSACTIONS
	LEFT JOIN  HTX ON HTX.TART_ID = F.TART_ID																		--EDW_RITE.[dbo].HOST_TGS_XREF
	LEFT JOIN  HT	ON HT.TTXN_ID = HTX.TTXN_ID  AND HT.TRANSACTION_FILE_DETAIL_ID IS NULL							--EDW_RITE.[dbo].FACT_TOLL_TRANSACTIONS
	LEFT JOIN  BR	ON BR.VIOLATION_ID = V.VIOLATION_ID																--EDW_RITE.[dbo].FACT_VIOLATIONS_BR_DETAIL
	LEFT JOIN  NP	 ON NP.LANE_VIOL_ID = L.LANE_VIOL_ID															--EDW_RITE.[dbo].FACT_NOT_TRANSFERRED_TO_VPS_DETAIL 
	LEFT JOIN  DMV	ON DMV.VIOLATION_ID = V.VIOLATION_ID															--EDW_RITE.[dbo].FACT_VIOLATIONS_DMV_STATUS_DETAIL
	WHERE 	  F.TRANSACTION_FILE_DETAIL_ID IS NULL
	UNION ALL
	SELECT CASE 
               WHEN TXID_ID = - 14800
                       THEN 'AUTO FLUSHES'
               WHEN PMTY_ID NOT IN (
                               3
                               ,7
                               ,8
                               )
                       THEN 'CASH/UNPAID/NON-REV'
               WHEN PMTY_ID = 3
                       AND TXID_ID = - 13800
                       THEN 'TAGFLUSH'
               WHEN PMTY_ID = 3
                       THEN 'AVI'
               WHEN PMTY_ID IN (
                               7
                               ,8
                               )
                       THEN 'VIDEO'
               ELSE 'NOT POSTED'
               END AS LEVEL_0
			,CASE 
               WHEN PMTY_ID = 6
                       THEN 'NON-REV'
               WHEN PMTY_ID = 3
                       AND TXID_ID = - 13800
                       THEN 'TAGFLUSH'
               WHEN PMTY_ID = 3
                       AND ISNULL(COALESCE(TT.ACCT_ID,HT.ACCT_ID),'-1') = '-1'						-- ACCT_ID
                       AND ISNULL(COALESCE(TT.TAG_ID,HT.TAG_ID,IOP.TAG_ID,VIOP.TAG_ID),'-1') <> '-1'--TAG_ID
                       THEN 'IOP'
               WHEN PMTY_ID = 3
                       THEN 'TOLLTAG'
               WHEN LANE_REVIEW_STATUS IN (
                               'D'
                               ,'R'
                               ,'E'
                               ,'F'
                               ,'O'
                               ,'N'
                               )
                       THEN 'IMAGES ENTERING ICRS'
               ELSE 'IMAGES NOT ENTERING ICRS'
               END AS LEVEL_1
			,CASE 
               WHEN LANE_REVIEW_STATUS IN ('O')
                       THEN 'Auto OCR Pass'
               WHEN LANE_REVIEW_STATUS IN (
                               'D'
                               ,'R'
                               ,'E'
                               )
                       THEN 'Manual Review'
               WHEN LANE_REVIEW_STATUS IN ('N')
                       THEN 'Pending Review'
                ELSE '-1'
              END  AS LEVEL_2
           ,CASE 
               WHEN LANE_REVIEW_STATUS IN ('D')
                       THEN 'Images Discarded'
               WHEN LANE_REVIEW_STATUS IN (
                               'R'
                               ,'E'
                               )
                       THEN 'Images Kept'
               WHEN LANE_REVIEW_STATUS IN ('N')
                       THEN 'Not Transferred to VPS'
                ELSE '-1'
              END  AS LEVEL_3
			,CASE 
               WHEN VIOL_REJECT_TYPE = 'NR'
                       THEN 'Variance Pool'
               WHEN VIOL_REJECT_TYPE = 'RO'
                       THEN 'OCR Rejects'
                ELSE ISNULL(VIOL_REJECT_TYPE,'-1')
               END AS LEVEL_4
			,ISNULL(LANE_VIOL_STATUS,'-1') LEVEL_5
			,CASE 
               WHEN VIOL_STATUS IN (
                               'ZH'
                               ,'WJ'
                               )
                       THEN 'DMV Match Processing'
               WHEN VIOL_STATUS = 'ZI'
                       THEN 'Aged To Violation Invoices'
               ELSE ISNULL(VIOL_STATUS,'-1')
               END  AS LEVEL_6
			,CASE 
               WHEN VIOL_STATUS = 'P'
                       AND VBI_INVOICE_ID IS NULL
                       AND VIOL_INVOICE_ID IS NULL
                       THEN 'UNINVD'
               WHEN VIOL_STATUS = 'P'
                       AND (
                               VBI_INVOICE_ID IS NOT NULL
                               OR VIOL_INVOICE_ID IS NOT NULL
                               )
                       THEN 'INVD'
               WHEN  VBI_STATUS  = 'B' OR VIOL_INV_STATUS IN ('A', 'B')
                       THEN 'INV-BAD-ADD'
                 ELSE '-1'
              END AS LEVEL_7
			,CASE 
               WHEN DMV_STS IN (
                               'VIOL-NTX'
                               ,'VIOL-TX'
                               ,'LP-M-VLTR'
                               ,'LP-NDMV'
                               ,'LP-NV-TIME'
                               ,'LP-OTHER'
                               )
                       THEN 'VIOL-UM-DMV'
               WHEN DMV_STS = 'VIOL-M-DMV'
                       THEN 'VIOL-M-DMV'
               ELSE '-1'
               END  AS LEVEL_8
			,CASE 
               WHEN TXN_NAME IN (
                               'VIOL-UBR-C'
                               ,'VIOL-UBR-N'
                               )
                       THEN 'VIOL-UBR'
               WHEN DMV_STS IN (
                               'LP-M-VLTR'
                               ,'LP-NDMV'
                               ,'LP-NV-TIME'
                               ,'LP-OTHER'
                               )
                       THEN 'VIOL-TX'
               WHEN DMV_STS = 'VIOL-NTX'
                       THEN 'VIOL-NTX'
               ELSE ISNULL(TXN_NAME,'-1')
               END AS LEVEL_9
			,CASE 
               WHEN TXN_NAME IN (
                               'VIOL-UBR-C'
                               ,'VIOL-UBR-N'
                               )
                       THEN TXN_NAME
               WHEN DMV_STS IN (
                               'LP-M-VLTR'
                               ,'LP-NDMV'
                               ,'LP-NV-TIME'
                               ,'LP-OTHER'
                               )
                       THEN DMV_STS
               ELSE '-1'
               END AS LEVEL_10,
			   F.TART_ID,F.DAY_ID,ISNULL(F.PMTY_ID,-1) PMTY_ID,VCLY_ID,AVI_TAG_STATUS,F.LANE_ID,F.Local_Time,F.EAR_REV,COALESCE(IOP.POSTED_REVENUE, POS_REV) POS_REV
			,F.TXID_ID,F.TRANSACTION_FILE_DETAIL_ID--F.VES_DATE_TIME,F.VES_SERIAL_NO,L.LANE_ABBREV,
			,L.LANE_VIOL_ID,COALESCE(V.VIOL_DATE, L.VIOL_DATE) VIOL_DATE,L.AXLE_COUNT,--L.LANE_VIOL_STATUS_DESCR,
			LANE_VIOL_STATUS,LANE_REVIEW_STATUS,--L.REVIEW_STATUS_ABBREV LANE_REVIEW_STATUS_ABBREV,L.STATUS_DESCR LANE_STATUS_DESCR,--L.VEHICLE_CLASS,L.REV_STATUS_DESCR LANE_REV_STATUS_DESCR,
			L.VIOLATION_CODE,--L.VIOL_REJECT_TYPE_DESCR,
			L.VIOL_CREATED,COALESCE(L.LIC_PLATE_NBR,V.LIC_PLATE_NBR,HT.LIC_PLATE,TT.LIC_PLATE)LIC_PLATE_NBR,
			COALESCE(L.LIC_PLATE_STATE,V.LIC_PLATE_STATE,HT.LIC_STATE,TT.LIC_STATE)LIC_PLATE_STATE,L.REVIEW_DATE,VIOL_REJECT_TYPE,
			COALESCE(L.TOLL_DUE,V.TOLL_DUE)TOLL_DUE, COALESCE(L.TOLL_PAID,V.TOLL_PAID)TOLL_PAID,
			COALESCE(V.VIOLATION_ID,L.VIOLATION_ID) VIOLATION_ID,--V.STATUS_DESCR VIOL_STATUS_DESCR,
			V.STATUS_DATE,V.VIOL_TYPE,V.DRIVER_LIC_STATE,V.VIOLATOR_ID,--V.REV_STATUS_DESCR,--V.LANE_VIOL_ID,V.TRANSACTION_ID,
			VIOL_STATUS,--V.REVIEW_STATUS,
			VHT.TRANSACTION_ID,DISPOSITION,VHT.VTOLL_SEND_DATE,	
			COALESCE(TT.TTXN_ID,HT.TTXN_ID,IOP.SOURCE_TXN_ID,VIOP.SOURCE_TXN_ID) TTXN_ID,
			COALESCE(TT.AMOUNT,HT.AMOUNT,IOP.POSTED_REVENUE,VIOP.POSTED_REVENUE) AMOUNT,
			COALESCE(TT.POSTED_DATE,HT.POSTED_DATE,IOP.POSTED_DATE,VIOP.POSTED_DATE) POSTED_DATE,CAST(CONVERT(VARCHAR, COALESCE(TT.POSTED_DATE,HT.POSTED_DATE,IOP.POSTED_DATE,VIOP.POSTED_DATE) ,112) AS INT) POSTED_DAY_ID,
			ISNULL(CAST(COALESCE(TT.SOURCE_CODE,HT.SOURCE_CODE,IOP.SOURCE_CODE,VIOP.SOURCE_CODE)AS VARCHAR(2)),'-1') SOURCE_CODE,--			SC_DESCR,SOURCE_CODE_GROUP,
			ISNULL(COALESCE(TT.ACCT_ID,HT.ACCT_ID),'-1') ACCT_ID, ISNULL(COALESCE(TT.TAG_ID,HT.TAG_ID,IOP.TAG_ID,VIOP.TAG_ID),'-1') TAG_ID, 
			ISNULL(COALESCE(TT.AGENCY_ID,HT.AGENCY_ID,IOP.TAG_AGENCY_ID,VIOP.TAG_AGENCY_ID),'-1') TAG_AGENCY_ID, DMV_STS,TXN_NAME, NOT_TRANS_REVIEW_STATUS_ABBREV,
			VBI_INVOICE_ID,VIOL_INVOICE_ID,PAYMENT_DATE,SPLIT_AMOUNT,I.FEES_PAID,I.TOLL_PAID AS AMT_PAID,VBI_INVOICE_DATE,VBI_STATUS,VI_INVOICE_DATE,VIOL_INV_STATUS,INVOICE_STAGE_ID
			--SELECT COUNT_BIG(1)
	FROM		F																									--EDW_RITE.[dbo].[FACT_NET_REV_TFC_EVTS]
	--LEFT JOIN  HIX	 ON F.TART_ID = HIX.TART_ID																	--EDW_RITE.[dbo].[HOST_ICRS_XREF]
	LEFT JOIN  L	ON L.TRANSACTION_FILE_DETAIL_ID = F.TRANSACTION_FILE_DETAIL_ID									--EDW_RITE.[dbo].FACT_LANE_VIOLATIONS_DETAIL 
	LEFT JOIN  V	ON V.VIOLATION_ID = L.VIOLATION_ID AND V.TRANSACTION_FILE_DETAIL_ID IS NOT NULL					--EDW_RITE.[dbo].FACT_VIOLATIONS_DETAIL 
	LEFT JOIN  I	ON V.VIOLATION_ID = I.VIOLATION_ID																--EDW_RITE.[dbo].FACT_UNIFIED_VIOLATION_INVOICE
	LEFT JOIN  IVX	ON L.LANE_VIOL_ID = IVX.LANE_VIOL_ID															--EDW_RITE.[dbo].ICRS_VPS_XREFE
	LEFT JOIN  IOP	ON IOP.SOURCE_TXN_ID = F.TART_ID  AND IOP.TRANSACTION_FILE_DETAIL_ID IS NOT NULL				--EDW_RITE.[dbo].FACT_IOP_TGS
		 AND	IOP.Source_code IN ('H') --for TART_ID
	LEFT JOIN  VHT	ON VHT.TRANSACTION_ID = IVX.TRANSACTION_ID														--LND_LG_VPS.[VP_OWNER].[VPS_HOST_TRANSACTIONS]
	LEFT JOIN  IOP AS VIOP ON VIOP.SOURCE_TXN_ID = VHT.TRANSACTION_ID AND VIOP.TRANSACTION_FILE_DETAIL_ID IS NOT NULL--EDW_RITE.[dbo].FACT_IOP_TGS
		 AND	VIOP.Source_code IN ('V') --for TRANSACTION_ID 
	LEFT JOIN  VTX	ON VTX.TRANSACTION_ID = IVX.TRANSACTION_ID														--EDW_RITE.[dbo].VPS_TGS_XREF
	LEFT JOIN  HT AS TT ON TT.TTXN_ID = VTX.TTXN_ID  AND TT.TRANSACTION_FILE_DETAIL_ID IS NOT NULL					--EDW_RITE.[dbo].FACT_TOLL_TRANSACTIONS
	LEFT JOIN  HTX	ON HTX.TART_ID = F.TART_ID																		--EDW_RITE.[dbo].HOST_TGS_XREF
	LEFT JOIN  HT	ON HT.TTXN_ID = HTX.TTXN_ID  AND HT.TRANSACTION_FILE_DETAIL_ID IS NOT NULL						--EDW_RITE.[dbo].FACT_TOLL_TRANSACTIONS
	LEFT JOIN  BR	ON BR.VIOLATION_ID = V.VIOLATION_ID																--EDW_RITE.[dbo].FACT_VIOLATIONS_BR_DETAIL
	LEFT JOIN  NP	ON NP.LANE_VIOL_ID = L.LANE_VIOL_ID																--EDW_RITE.[dbo].FACT_NOT_TRANSFERRED_TO_VPS_DETAIL 
	LEFT JOIN  DMV	ON DMV.VIOLATION_ID = V.VIOLATION_ID															--EDW_RITE.[dbo].FACT_VIOLATIONS_DMV_STATUS_DETAIL
	WHERE 	  F.TRANSACTION_FILE_DETAIL_ID IS NOT NULL

		--STEP #1a: Replace OLD table with NEW
	IF OBJECT_ID('dbo.FACT_UNIFIED_VIOLATION_OLD')>0 	DROP TABLE dbo.FACT_UNIFIED_VIOLATION_OLD;
	IF OBJECT_ID('dbo.FACT_UNIFIED_VIOLATION')>0		RENAME OBJECT::dbo.FACT_UNIFIED_VIOLATION TO FACT_UNIFIED_VIOLATION_OLD;
	RENAME OBJECT::dbo.FACT_UNIFIED_VIOLATION_STAGE TO FACT_UNIFIED_VIOLATION;
	--IF OBJECT_ID('dbo.FACT_UNIFIED_VIOLATION_OLD')>0 		DROP TABLE dbo.FACT_UNIFIED_VIOLATION_OLD;

	--STEP #1b: Create Statistics --[dbo].[CreateStats] 'dbo', 'FACT_UNIFIED_VIOLATION'
	CREATE STATISTICS STATS_FACT_UNIFIED_VIOLATION_001 ON [dbo].FACT_UNIFIED_VIOLATION (DAY_ID)
	CREATE STATISTICS STATS_FACT_UNIFIED_VIOLATION_002 ON [dbo].FACT_UNIFIED_VIOLATION (LANE_ID)
	CREATE STATISTICS STATS_FACT_UNIFIED_VIOLATION_003 ON [dbo].FACT_UNIFIED_VIOLATION (LANE_VIOL_ID)
	CREATE STATISTICS STATS_FACT_UNIFIED_VIOLATION_004 ON [dbo].FACT_UNIFIED_VIOLATION (ACCT_ID)
	CREATE STATISTICS STATS_FACT_UNIFIED_VIOLATION_005 ON [dbo].FACT_UNIFIED_VIOLATION (TAG_ID)
	CREATE STATISTICS STATS_FACT_UNIFIED_VIOLATION_006 ON [dbo].FACT_UNIFIED_VIOLATION (VIOLATION_ID)
	CREATE STATISTICS STATS_FACT_UNIFIED_VIOLATION_007 ON [dbo].FACT_UNIFIED_VIOLATION (VIOLATOR_ID)
	CREATE STATISTICS STATS_FACT_UNIFIED_VIOLATION_008 ON [dbo].FACT_UNIFIED_VIOLATION (TRANSACTION_ID)
	CREATE STATISTICS STATS_FACT_UNIFIED_VIOLATION_009 ON [dbo].FACT_UNIFIED_VIOLATION (TRANSACTION_FILE_DETAIL_ID)
	CREATE STATISTICS STATS_FACT_UNIFIED_VIOLATION_010 ON [dbo].FACT_UNIFIED_VIOLATION (TTXN_ID)
	CREATE STATISTICS STATS_FACT_UNIFIED_VIOLATION_011 ON [dbo].FACT_UNIFIED_VIOLATION (AVI_TAG_STATUS)
	CREATE STATISTICS STATS_FACT_UNIFIED_VIOLATION_012 ON [dbo].FACT_UNIFIED_VIOLATION (LEVEL_0)
	CREATE STATISTICS STATS_FACT_UNIFIED_VIOLATION_013 ON [dbo].FACT_UNIFIED_VIOLATION (LEVEL_1)
	CREATE STATISTICS STATS_FACT_UNIFIED_VIOLATION_014 ON [dbo].FACT_UNIFIED_VIOLATION (LEVEL_2)
	CREATE STATISTICS STATS_FACT_UNIFIED_VIOLATION_015 ON [dbo].FACT_UNIFIED_VIOLATION (LEVEL_3)
	CREATE STATISTICS STATS_FACT_UNIFIED_VIOLATION_016 ON [dbo].FACT_UNIFIED_VIOLATION (LEVEL_4)
	CREATE STATISTICS STATS_FACT_UNIFIED_VIOLATION_017 ON [dbo].FACT_UNIFIED_VIOLATION (LEVEL_5)
	CREATE STATISTICS STATS_FACT_UNIFIED_VIOLATION_018 ON [dbo].FACT_UNIFIED_VIOLATION (LEVEL_6)
	CREATE STATISTICS STATS_FACT_UNIFIED_VIOLATION_019 ON [dbo].FACT_UNIFIED_VIOLATION (LEVEL_7)
	CREATE STATISTICS STATS_FACT_UNIFIED_VIOLATION_020 ON [dbo].FACT_UNIFIED_VIOLATION (LEVEL_8)
	CREATE STATISTICS STATS_FACT_UNIFIED_VIOLATION_021 ON [dbo].FACT_UNIFIED_VIOLATION (LEVEL_9)
	CREATE STATISTICS STATS_FACT_UNIFIED_VIOLATION_022 ON [dbo].FACT_UNIFIED_VIOLATION (LEVEL_10)
	CREATE STATISTICS STATS_FACT_UNIFIED_VIOLATION_023 ON [dbo].FACT_UNIFIED_VIOLATION (POSTED_DAY_ID)


