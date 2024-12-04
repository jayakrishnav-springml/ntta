CREATE PROC [DBO].[FACT_INVOICE_DETAIL_STAGE_LOAD] AS 

/*

	 select COUNT(*) FROM FACT_INVOICE_DETAIL_STAGE
	 select INVOICE_CATEGORY_ID, COUNT(*) from FACT_INVOICE_DETAIL_STAGE group by INVOICE_CATEGORY_ID
	 SELECT * FROM VIOL_STATUS WHERE VIOL_STATUS IN ('L','V')
	 SELECT * FROM VIOL_STATUS WHERE VIOL_STATUS_SUM_GROUP = 'ReAsgn_UnAsgn'
	 SELECT * FROM VIOL_STATUS WHERE VIOL_STATUS_SUM_GROUP = 'ReAsgn_UnAsgn'

*/

IF OBJECT_ID('dbo.FACT_INVOICE_DETAIL_STAGE')>0
	DROP TABLE dbo.FACT_INVOICE_DETAIL_STAGE

CREATE TABLE dbo.FACT_INVOICE_DETAIL_STAGE WITH (CLUSTERED INDEX (VIOLATION_ID), DISTRIBUTION = HASH(VIOLATOR_ID))--, CLUSTERED INDEX (VIOLATOR_ID, VIOLATION_ID)) 
AS --EXPLAIN
	SELECT  --TOP 1000
		1 AS INVOICE_CATEGORY_ID, -- VB INVOICE VIOLATIONS 
		VBI.VIOLATOR_ID,
		VBI.VBI_INVOICE_ID, 
		ISNULL(vbi.INVOICE_DATE,'1/1/1900') AS VB_INV_DATE,
		ISNULL(vbi.DATE_EXCUSED,'1/1/1900') AS VB_INV_DATE_EXCUSED,
		-1 AS VIOL_INVOICE_ID,
		'1/1/1900' AS CONVERTED_DATE,
		'1/1/1900' AS VIOL_INV_DATE_EXCUSED,
		CASE 
			WHEN (ISNULL(VHT.POSTED_REVENUE,0) + ISNULL(viol.TOLL_PAID,0)) = 0 AND vs.VIOL_STATUS_SUM_GROUP = 'Paid' THEN ISNULL(vbiv.TOLL_DUE,0)
			WHEN VHT.POSTED_REVENUE > 0 THEN VHT.POSTED_REVENUE
			ELSE viol.TOLL_PAID
		END AS AMT_PAID,
		CASE 
			WHEN (ISNULL(VHT.POSTED_REVENUE,0) + ISNULL(viol.TOLL_PAID,0)) = 0 AND vs.VIOL_STATUS_SUM_GROUP = 'Paid' THEN ISNULL(vbiv.TOLL_DUE,0)
			WHEN VHT.POSTED_REVENUE > 0 THEN VHT.POSTED_REVENUE
			WHEN viol.TOLL_PAID  > 0 THEN viol.TOLL_PAID
			WHEN vsviol.VIOL_STATUS IN ('P','K') THEN viol.TOLL_DUE
			ELSE 0 
		END AS VIOL_AMT_PAID,
		ISNULL(VHT.POSTED_REVENUE,0) AS VPS_HOST_POSTED_REV,
		vbiv.VIOLATION_ID,
		viol.VIOL_TIME_ID,
		viol.VIOL_DATE,
		viol.LANE_ID,
		viol.TOLL_DUE AS TOLL_DUE_ON_VIOL,
		vbiv.TOLL_DUE AS TOLL_DUE_ON_INV,
		ISNULL(viol.VEHICLE_CLASS,'-1') AS VEHICLE_CLASS,
		ISNULL(vht.SOURCE_CODE,'-1') AS SOURCE_CODE,
		vbiv.VIOL_STATUS as INV_DTL_VIOL_STATUS,
		viol.VIOL_STATUS AS LAST_VIOL_STATUS,
		viol.VIOLATOR_ID as LAST_VIOLATOR_ID, 
		ISNULL(vht.TRANSACTION_ID,((ISNULL(vbiv.VIOLATION_ID,-1)%100000) * -1)) AS TRANSACTION_ID,
		ISNULL(REPLACE(vht.DISPOSITION, '-', '-1'),'-1') AS DISPOSITION,
		ISNULL(viol.VIOL_TYPE,'-1') AS VIOL_TYPE,
		ISNULL(viol.STATUS_DATE,'1/1/1900') as VIOL_STATUS_DATE,
		ISNULL(viol.POST_DATE,'1/1/1900') as VIOL_POST_DATE,
		ISNULL(viol.DATE_EXCUSED,'1/1/1900') as VIOL_DATE_EXCUSED,
		ISNULL(viol.VIOLATION_OR_ZIPCASH,'-1') as VIOLATION_OR_ZIPCASH,
		CASE WHEN viol.VIOL_STATUS in ('P','K') THEN viol.STATUS_DATE ELSE '1/1/1900' END AS VIOL_PAID_DATE,
		ISNULL(vht.POSTED_REVENUE,0) AS VPS_HOST_POSTED_REVENUE, 
		ISNULL(vht.POSTED_DATE,'1/1/1900') AS VPS_HOST_POSTED_DATE,
		CASE WHEN 
				(
					   (vbi.VBI_STATUS = 'F' AND vbiv.VIOL_STATUS in ('P', 'K'))
					OR (vbi.VBI_STATUS = 'TS' AND vbiv.VIOL_STATUS in ('T') AND vht.disposition = 'P') 
					OR (vbi.VBI_STATUS not in ('F', 'CV', 'TS')  AND vbiv.VIOL_STATUS not in ('P', 'K', 'T'))
				)
			THEN 1
			ELSE 0 
			END AS VIOL_LEFT_ON_INV_FLAG
	from dbo.VB_INVOICES vbi 
		INNER JOIN dbo.VB_INVOICE_VIOL vbiv ON vbi.vbi_invoice_id = vbiv.vbi_invoice_id
		INNER JOIN dbo.VIOL_STATUS vs ON vbiv.VIOL_STATUS = vs.VIOL_STATUS
		INNER JOIN dbo.VIOLATIONS_DIST_ON_VIOLATION_ID viol ON vbiv.VIOLATION_ID = viol.VIOLATION_ID --vbiv.VIOLATOR_ID = viol.VIOLATOR_ID AND 
		INNER JOIN dbo.VIOL_STATUS vsviol ON viol.VIOL_STATUS = vsviol.VIOL_STATUS
		LEFT JOIN dbo.VPS_HOST_TRANSACTIONS_DIST_ON_VIOLATION_ID vht ON viol.VIOLATION_ID = vht.violation_id

	--where vbi.INVOICE_DATE between '2015-12-01' and '2015-12-31'

	union all



	SELECT --TOP 1000
		2 AS INVOICE_CATEGORY_ID, -- VIOL INVOICES CONVERTED FROM VB INVOICES
		VBI.VIOLATOR_ID,
		VBI.VBI_INVOICE_ID, 
		ISNULL(vbi.INVOICE_DATE,'1/1/1900') AS VB_INV_DATE,
		ISNULL(vbi.DATE_EXCUSED,'1/1/1900') AS VB_INV_DATE_EXCUSED,
		vi.VIOL_INVOICE_ID,
		convert(date,VBVI.DATE_CREATED) AS CONVERTED_DATE,
		ISNULL(vi.DATE_EXCUSED,'1/1/1900') AS VIOL_INV_DATE_EXCUSED,
		CASE 
			WHEN viv.VIOL_STATUS IN ('L','V') THEN 0 
			WHEN (ISNULL(VHT.POSTED_REVENUE,0) + ISNULL(viol.TOLL_PAID,0)) = 0 AND vs.VIOL_STATUS_SUM_GROUP = 'Paid' THEN ISNULL(viv.TOLL_DUE_AMOUNT,0)
			WHEN VHT.POSTED_REVENUE > 0 THEN VHT.POSTED_REVENUE
			ELSE viol.TOLL_PAID
		END AS AMT_PAID,
		CASE 
			WHEN (ISNULL(VHT.POSTED_REVENUE,0) + ISNULL(viol.TOLL_PAID,0)) = 0 AND vs.VIOL_STATUS_SUM_GROUP = 'Paid' THEN ISNULL(viv.TOLL_DUE_AMOUNT,0)
			WHEN VHT.POSTED_REVENUE > 0 THEN VHT.POSTED_REVENUE
			WHEN viol.TOLL_PAID  > 0 THEN viol.TOLL_PAID
			WHEN vsviol.VIOL_STATUS IN ('P','K') THEN viol.TOLL_DUE
			ELSE 0 
		END AS VIOL_AMT_PAID,
		ISNULL(VHT.POSTED_REVENUE,0) AS VPS_HOST_POSTED_REV,
		viv.VIOLATION_ID,
		viol.VIOL_TIME_ID,
		viol.VIOL_DATE,
		viol.LANE_ID,
		viol.TOLL_DUE AS TOLL_DUE_ON_VIOL,
		viv.TOLL_DUE_AMOUNT AS TOLL_DUE_ON_INV,
		ISNULL(VEHICLE_CLASS,'-1') AS VEHICLE_CLASS,
		ISNULL(vht.SOURCE_CODE,'-1') AS SOURCE_CODE,
		viv.VIOL_STATUS as INV_DTL_VIOL_STATUS,
		viol.VIOL_STATUS AS LAST_VIOL_STATUS,
		viol.VIOLATOR_ID as LAST_VIOLATOR_ID, 
		ISNULL(vht.TRANSACTION_ID,((ISNULL(viv.VIOLATION_ID,-1)%100000) * -1)) AS TRANSACTION_ID,
		ISNULL(REPLACE(vht.DISPOSITION, '-', '-1'),'-1') AS DISPOSITION,
		ISNULL(viol.VIOL_TYPE,'-1') AS VIOL_TYPE,
		ISNULL(viol.STATUS_DATE,'1/1/1900') as VIOL_STATUS_DATE,
		ISNULL(viol.POST_DATE,'1/1/1900') as VIOL_POST_DATE,
		ISNULL(viol.DATE_EXCUSED,'1/1/1900') as VIOL_DATE_EXCUSED,
		ISNULL(viol.VIOLATION_OR_ZIPCASH,'-1') as VIOLATION_OR_ZIPCASH,
		CASE WHEN viol.VIOL_STATUS in ('P','K') THEN viol.STATUS_DATE ELSE '1/1/1900' END AS VIOL_PAID_DATE,
		ISNULL(vht.POSTED_REVENUE,0) AS VPS_HOST_POSTED_REVENUE, 
		ISNULL(vht.POSTED_DATE,'1/1/1900') AS VPS_HOST_POSTED_DATE,
		CASE WHEN (
						(vbi.vbi_status = 'CV' AND vi.viol_inv_Status in ('F', 'K') AND viv.VIOL_STATUS in ('P', 'K'))
					OR  (vbi.vbi_status = 'CV' AND vi.VIOL_INV_STATUS = 'TS'  AND viv.VIOL_STATUS in ('T') AND vht.disposition = 'P')
					OR	(vbi.vbi_status = 'CV' AND vi.viol_inv_Status not in ('TS', 'K', 'F') AND viv.VIOL_STATUS not in ('P', 'K', 'T'))
					)
			THEN 1
			ELSE 0 
			END AS VIOL_LEFT_ON_INV_FLAG
	from dbo.vb_invoice_batches vbib 
		INNER JOIN dbo.vb_invoices vbi ON VBIB.VBB_BATCH_ID = VBI.VBB_BATCH_ID  
		INNER JOIN dbo.vb_viol_invoices vbvi ON VBI.VBI_INVOICE_ID = VBVI.VBI_VBI_INVOICE_ID
		INNER JOIN dbo.viol_invoices vi ON VBVI.INV_VIOL_INVOICE_ID = VI.VIOL_INVOICE_ID
		INNER JOIN dbo.viol_invoice_viol viv ON VI.VIOL_INVOICE_ID = VIV.VIOL_INVOICE_ID
		INNER  JOIN dbo.VIOL_STATUS vs ON viv.VIOL_STATUS = vs.VIOL_STATUS
		INNER JOIN dbo.VIOLATIONS_DIST_ON_VIOLATION_ID viol ON viv.VIOLATION_ID = viol.VIOLATION_ID -- viv.VIOLATOR_ID = viol.VIOLATOR_ID AND 
		INNER JOIN dbo.VIOL_STATUS vsviol ON viol.VIOL_STATUS = vsviol.VIOL_STATUS
		LEFT JOIN dbo.VPS_HOST_TRANSACTIONS_DIST_ON_VIOLATION_ID vht ON viol.VIOLATION_ID = vht.violation_id
	--where vbi.INVOICE_DATE between '2015-12-01' and '2015-12-31'


	union all

-- EXPLAIN
	SELECT -- TOP 1000
		7 AS INVOICE_CATEGORY_ID, -- 'VIOL INVOICES NEVER BEEN A VB INVOICE
		VI.VIOLATOR_ID,
		-1 as VBI_INVOICE_ID, 
		'1/1/1900' AS VB_INV_DATE,
		'1/1/1900' AS VB_INV_DATE_EXCUSED,
		vi.VIOL_INVOICE_ID,
		vi.INVOICE_DATE AS CONVERTED_DATE,
		ISNULL(vi.DATE_EXCUSED,'1/1/1900') AS VIOL_INV_DATE_EXCUSED,
		CASE 
			WHEN viv.VIOL_STATUS IN ('L','V') THEN 0 
			WHEN (ISNULL(VHT.POSTED_REVENUE,0) + ISNULL(viol.TOLL_PAID,0)) = 0 AND vs.VIOL_STATUS_SUM_GROUP = 'Paid' THEN ISNULL(viv.TOLL_DUE_AMOUNT,0)
			WHEN VHT.POSTED_REVENUE > 0 THEN VHT.POSTED_REVENUE
			ELSE viol.TOLL_PAID
		END AS AMT_PAID,
		CASE 
			WHEN (ISNULL(VHT.POSTED_REVENUE,0) + ISNULL(viol.TOLL_PAID,0)) = 0 AND vs.VIOL_STATUS_SUM_GROUP = 'Paid' THEN ISNULL(viv.TOLL_DUE_AMOUNT,0)
			WHEN VHT.POSTED_REVENUE > 0 THEN VHT.POSTED_REVENUE
			WHEN viol.TOLL_PAID  > 0 THEN viol.TOLL_PAID
			WHEN vsviol.VIOL_STATUS IN ('P','K') THEN viol.TOLL_DUE
			ELSE 0 
		END AS VIOL_AMT_PAID,
		ISNULL(VHT.POSTED_REVENUE,0) AS VPS_HOST_POSTED_REV,
		viv.VIOLATION_ID,
		viol.VIOL_TIME_ID,
		viol.VIOL_DATE,
		viol.LANE_ID,
		viol.TOLL_DUE AS TOLL_DUE_ON_VIOL,
		viv.TOLL_DUE_AMOUNT AS TOLL_DUE_ON_INV,
		ISNULL(VEHICLE_CLASS,'-1') AS VEHICLE_CLASS,
		ISNULL(vht.SOURCE_CODE,'-1') AS SOURCE_CODE,
		viv.VIOL_STATUS as INV_DTL_VIOL_STATUS,
		viol.VIOL_STATUS AS LAST_VIOL_STATUS,
		viol.VIOLATOR_ID as LAST_VIOLATOR_ID, 
		ISNULL(vht.TRANSACTION_ID,((ISNULL(viv.VIOLATION_ID,-1)%100000) * -1)) AS TRANSACTION_ID,
		ISNULL(REPLACE(vht.DISPOSITION, '-', '-1'),'-1') AS DISPOSITION,
		ISNULL(viol.VIOL_TYPE,'-1') AS VIOL_TYPE,
		ISNULL(viol.STATUS_DATE,'1/1/1900') as VIOL_STATUS_DATE,
		ISNULL(viol.POST_DATE,'1/1/1900') as VIOL_POST_DATE,
		ISNULL(viol.DATE_EXCUSED,'1/1/1900') as VIOL_DATE_EXCUSED,
		ISNULL(viol.VIOLATION_OR_ZIPCASH,'-1') as VIOLATION_OR_ZIPCASH,
		CASE WHEN viol.VIOL_STATUS in ('P','K') THEN viol.STATUS_DATE ELSE '1/1/1900' END AS VIOL_PAID_DATE,
		ISNULL(vht.POSTED_REVENUE,0) AS VPS_HOST_POSTED_REVENUE, 
		ISNULL(vht.POSTED_DATE,'1/1/1900') AS VPS_HOST_POSTED_DATE,
		CASE WHEN (
						(vs.VIOL_STATUS_SUM_GROUP = 'Paid') --viv.VIOL_STATUS in ('P', 'K')) -- vi.viol_inv_Status in ('F', 'K')  AND 
					OR  (vi.VIOL_INV_STATUS = 'TS'  AND viv.VIOL_STATUS in ('T') AND vht.disposition = 'P')
					OR	(vi.viol_inv_Status not in ('TS', 'K', 'F') AND viv.VIOL_STATUS not in ('P', 'K', 'T'))
					)
			THEN 1
			ELSE 0 
			END AS VIOL_LEFT_ON_INV_FLAG
FROM dbo.viol_invoices vi 
	INNER JOIN FACT_INVOICE_VIOL_INV_NO_VB_INV_STAGE viNOvb ON VI.VIOL_INVOICE_ID = viNOvb.VIOL_INVOICE_ID
	INNER JOIN dbo.viol_invoice_viol viv ON VI.VIOL_INVOICE_ID = VIV.VIOL_INVOICE_ID
	INNER JOIN dbo.VIOL_STATUS vs ON viv.VIOL_STATUS = vs.VIOL_STATUS
	INNER JOIN dbo.VIOLATIONS_DIST_ON_VIOLATION_ID viol ON viv.VIOLATION_ID = viol.VIOLATION_ID -- viv.VIOLATOR_ID = viol.VIOLATOR_ID AND 
	INNER JOIN dbo.VIOL_STATUS vsviol ON viol.VIOL_STATUS = vsviol.VIOL_STATUS
	LEFT JOIN dbo.VPS_HOST_TRANSACTIONS_DIST_ON_VIOLATION_ID vht ON viol.VIOLATION_ID = vht.violation_id


------ ------ ------ ------ ------ ------ ------ ------ ------ ------ 
------ ------ ------  FINAL STATS ------ ------ ------ ------ ------ 
------ ------ ------ ------ ------ ------ ------ ------ ------ ------ 

------CreateStats 'FACT_INVOICE_DETAIL_STAGE'
exec DropStats 'dbo','FACT_INVOICE_DETAIL_STAGE'

CREATE STATISTICS STATS_FACT_INVOICE_DETAIL_STAGE_001 ON [dbo].FACT_INVOICE_DETAIL_STAGE (VIOLATOR_ID)
CREATE STATISTICS STATS_FACT_INVOICE_DETAIL_STAGE_002 ON [dbo].FACT_INVOICE_DETAIL_STAGE (VIOL_INVOICE_ID)
CREATE STATISTICS STATS_FACT_INVOICE_DETAIL_STAGE_003 ON [dbo].FACT_INVOICE_DETAIL_STAGE (VBI_INVOICE_ID, VIOL_INVOICE_ID)
CREATE STATISTICS STATS_FACT_INVOICE_DETAIL_STAGE_004 ON [dbo].FACT_INVOICE_DETAIL_STAGE (TRANSACTION_ID)


--CREATE STATISTICS STATS_FACT_INVOICE_DETAIL_STAGE_005 ON [dbo].FACT_INVOICE_DETAIL_STAGE 
--	(VIOLATOR_ID, VIOLATION_ID, VBI_INVOICE_ID)

--CREATE STATISTICS STATS_FACT_INVOICE_DETAIL_STAGE_006 ON [dbo].FACT_INVOICE_DETAIL_STAGE 
--	(VIOLATOR_ID, VIOLATION_ID, VBI_INVOICE_ID, VIOL_INVOICE_ID, SOURCE_CODE, VEHICLE_CLASS, TRANSACTION_ID)

--CREATE STATISTICS STATS_FACT_INVOICE_DETAIL_STAGE_007 ON [dbo].FACT_INVOICE_DETAIL_STAGE 
--	(VIOLATOR_ID, VIOLATION_ID, VBI_INVOICE_ID, VIOL_INVOICE_ID, TRANSACTION_ID)

