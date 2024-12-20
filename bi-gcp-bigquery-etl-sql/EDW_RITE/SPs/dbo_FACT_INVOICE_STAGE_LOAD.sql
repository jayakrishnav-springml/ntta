CREATE PROC [DBO].[FACT_INVOICE_STAGE_LOAD] AS 

IF OBJECT_ID('dbo.FACT_INVOICE_STAGE')>0
	DROP TABLE dbo.FACT_INVOICE_STAGE

CREATE TABLE dbo.FACT_INVOICE_STAGE WITH (DISTRIBUTION = HASH(VIOLATOR_ID))--, CLUSTERED INDEX (VIOLATOR_ID, VIOLATION_ID)) 
AS 

	SELECT -- TOP 100000
		1 AS INVOICE_ANALYSIS_CATEGORY_ID, -- VB INVOICE VIOLATIONS NOT CONVERTED TO VIOL INVOICES 
		convert(date,vbib.date_produced) AS DATE_BATCH_PRODUCED, 
		VBI.VBI_INVOICE_ID, 
		ISNULL(vbi.INVOICE_DATE,'1/1/1900') AS VB_INV_DATE,
		ISNULL(vbi.DATE_EXCUSED,'1/1/1900') AS VB_INV_DATE_EXCUSED,
		case when VBI.VBB_LN_BATCH_ID is null then 1 else 2 end AS ZI_STAGE_ID,
		Case 
			when VBI.VBB_LN_BATCH_ID is null and vbi.vbi_status <> 'CV' then 1 -- 'ZipCash'  -- First Notice and not Converted to Viol Invoice
			when VBI.VBB_LN_BATCH_ID is not null and vbi.vbi_status <> 'CV' then 2 -- 'First Notice'  -- NOT First Notice and not Converted to Viol Invoice

		END AS INVOICE_STAGE_ID,
		VBI.VIOLATOR_ID,
		VBI.INVOICE_AMOUNT AS VB_INV_AMT, 
		VBI.INVOICE_AMT_DISC AS VB_INVOICE_AMT_DISC,
		VBI.LATE_FEE_AMOUNT AS VB_INV_LATE_FEES,
		CASE 
			WHEN VBI.VBI_STATUS = 'TS' THEN vTollPaid.VTOLL_AMT_PAID 
			ELSE VBI.INVOICE_AMT_PAID
		END AS VB_INV_AMT_PAID,
		'1/1/1900' AS CONVERTED_DATE,
		'1/1/1900' AS VIOL_INV_DATE_EXCUSED,
		-1 AS VIOL_INVOICE_ID,
		0 AS vi_inv_amt,
		0 AS VI_INVOICE_AMT_DISC,
		ISNULL(pay_date.date_paid,'1/1/1900') AS PAID_DATE,
		ISNULL(pay_date.POS_ID,-1) AS POS_ID, 
		ISNULL(pay_date.PAYMENT_SOURCE_CODE,'-1') AS PAYMENT_SOURCE_CODE,  
		ISNULL(pay_date.DELIVERY_CODE,'-1') AS DELIVERY_CODE,
		ISNULL(pay_date.PAYMENT_FORM,'-1') AS PAYMENT_FORM, 
		ISNULL(pay_date.PAYMENT_CREATED_BY,'(Null)') AS PAYMENT_CREATED_BY, 
		0 AS VIOL_INV_FEES,
		0 AS VIOL_INV_ADMIN_FEE,
		0 AS VIOL_INV_ADMIN_FEE2,  
		0 AS VIOL_INV_AMT_PAID,
		'-1' AS CA_INV_STATUS,
		-1 AS CA_COMPANY_ID,
		-1 AS CA_ACCT_ID,
		'1/1/1900' CA_FILE_GEN_DATE,
		'(Null)' AS CITATION_NBR,
		'1/1/1900' COURT_ACTION_MAIL_DATE,
		'-1' AS DPS_INV_STATUS, 
		vb_inv_sum.ZC_TXN_COUNT, 
		0 AS VIOL_TXN_COUNT,
		vb_inv_sum.ZC_TOLLS_DUE, 
		0 As VIOL_TOLLS_DUE

--EXPLAIN  54971821
-- select COUNT(*)
	from dbo.VB_INVOICE_BATCHES vbib
		INNER JOIN dbo.VB_INVOICES vbi ON VBIB.VBB_BATCH_ID = VBI.VBB_BATCH_ID 
		INNER JOIN dbo.FACT_INVOICE_VB_INVOICE_SUM_STAGE vb_inv_sum ON vbi.VIOLATOR_ID = vb_inv_sum.VIOLATOR_ID AND vbi.vbi_invoice_id = vb_inv_sum.vbi_invoice_id
		LEFT JOIN dbo.FACT_INVOICE_VTOLL_AMOUNT_PAID_STAGE vTollPaid ON vbi.VIOLATOR_ID = vTollPaid.VIOLATOR_ID AND vbi.vbi_invoice_id = vTollPaid.vbi_invoice_id and vTollPaid.VIOL_INVOICE_ID = -1
		LEFT JOIN dbo.FACT_INVOICE_VBI_VBI_INVOICE_ID_STAGE pay_date ON vbi.vbi_invoice_id = pay_date.vbi_vbi_invoice_id
	where 
			vb_inv_batch_type_code not IN  ('LN', 'FLN') 
		--AND vbi.INVOICE_DATE between '2015-12-01' and '2015-12-31'


	union all

	SELECT  -- TOP 100000
		2 AS INVOICE_ANALYSIS_CATEGORY_ID, -- VIOL INVOICES CONVERTED FROM VB INVOICES
		convert(date,vbib.date_produced) AS DATE_BATCH_PRODUCED, 
		VBI.VBI_INVOICE_ID, 
		ISNULL(vbi.INVOICE_DATE,'1/1/1900') AS VB_INV_DATE,
		ISNULL(vbi.DATE_EXCUSED,'1/1/1900') AS VB_INV_DATE_EXCUSED,
		case when VBI.VBB_LN_BATCH_ID is null then 1 else 2 end AS ZI_STAGE_ID,
		Case 
			when VBI.VBB_LN_BATCH_ID is null and vbi.vbi_status <> 'CV' then 1 -- 'ZipCash'  -- First Notice and not Converted to Viol Invoice
			when VBI.VBB_LN_BATCH_ID is not null and vbi.vbi_status <> 'CV' then 2 -- 'First Notice'  -- NOT First Notice and not Converted to Viol Invoice
			when VI.DPS_INV_STATUS in ('H','T') then 3 -- 'Citation Printed' -- DPS Status = Citation Printed OR Citation Issued
			when VI.CA_INV_STATUS = 'A' and VI.DPS_INV_STATUS = 'N' Then 4 -- 'Awaiting DPS' -- Pat's was 'Post-CA'
			when VI.DPS_INV_STATUS = 'D' then 4 -- 'Awaiting DPS' -- Pat's was 'Post-CA' -- Awaiting DPS Action
			when VI.CA_INV_STATUS = 'N' AND VI.DPS_INV_STATUS = 'N ' then 6 -- 'Second Notice' -- Pat's was 2nd NNP  --  CA = N	'Not Sent to Collections Agency' DPS = N	No DPS Activity
			else 7 -- 'In Collections'
		END AS INVOICE_STAGE_ID,
		VBI.VIOLATOR_ID,
		0 AS VB_INV_AMT, 
		0 AS VB_INVOICE_AMT_DISC,
		0 AS VB_INV_LATE_FEES, 
		0 AS VB_INV_AMT_PAID,
		convert(date,VBVI.DATE_CREATED) AS CONVERTED_DATE,
		ISNULL(vi.DATE_EXCUSED,'1/1/1900') AS VIOL_INV_DATE_EXCUSED,
		vi.VIOL_INVOICE_ID,
		VI.INVOICE_AMOUNT AS VI_INV_AMT,
		VI.INVOICE_AMT_DISC AS VI_INVOICE_AMT_DISC,
		ISNULL(pay_date.date_paid,'1/1/1900') AS PAID_DATE,
		ISNULL(pay_date.POS_ID,-1) AS POS_ID, 
		ISNULL(pay_date.PAYMENT_SOURCE_CODE,'-1'),
		ISNULL(pay_date.DELIVERY_CODE,'-1'),  
		ISNULL(pay_date.PAYMENT_FORM,'-1') AS PAYMENT_FORM, 
		ISNULL(pay_date.PAYMENT_CREATED_BY,'(Null)') AS PAYMENT_CREATED_BY, 
		viol_inv_sum.FINE_AMOUNT AS VIOL_INV_FEES,
		VI.INV_ADMIN_FEE AS VIOL_INV_ADMIN_FEE,
		VI.INV_ADMIN_FEE2 AS VIOL_INV_ADMIN_FEE2,  
		CASE 
			WHEN VI.VIOL_INV_STATUS = 'TS' THEN vTollPaid.VTOLL_AMT_PAID 
			ELSE VI.INVOICE_AMT_PAID
		END AS VIOL_INV_AMT_PAID,
		ISNULL(VI.CA_INV_STATUS,'-1') AS CA_INV_STATUS,
		ISNULL(CACCT.CA_COMPANY_ID,-1) AS CA_COMPANY_ID,
		ISNULL(CACCT.CA_ACCT_ID,-1) AS CA_ACCT_ID,
		ISNULL(Convert(date,cacct.file_gen_date),'1/1/1900') AS CA_FILE_GEN_DATE,
		ISNULL(CA.CITATION_NBR,'(Null)') AS CITATION_NBR,
		ISNULL(ca.mail_date,'1/1/1900') AS COURT_ACTION_MAIL_DATE,
		ISNULL(VI.DPS_INV_STATUS,'-1') AS DPS_INV_STATUS,
		vb_inv_sum.ZC_TXN_COUNT, 
		viol_inv_sum.VIOL_TXN_COUNT,
		0 AS ZC_TOLLS_DUE, 
		viol_inv_sum.VIOL_TOLLS_DUE
-- SELECT COUNT(*) 
	from dbo.vb_invoice_batches vbib 
		INNER JOIN dbo.vb_invoices vbi ON VBIB.VBB_BATCH_ID = VBI.VBB_BATCH_ID  
		INNER JOIN dbo.FACT_INVOICE_VB_INVOICE_SUM_STAGE vb_inv_sum ON vbi.VIOLATOR_ID = vb_inv_sum.VIOLATOR_ID AND vbi.vbi_invoice_id = vb_inv_sum.vbi_invoice_id
		INNER JOIN dbo.vb_viol_invoices vbvi ON VBI.VIOLATOR_ID = VBVI.VIOLATOR_ID AND VBI.VBI_INVOICE_ID = VBVI.VBI_VBI_INVOICE_ID
		INNER JOIN dbo.viol_invoices vi ON VBVI.VIOLATOR_ID = VI.VIOLATOR_ID AND VBVI.INV_VIOL_INVOICE_ID = VI.VIOL_INVOICE_ID
		LEFT JOIN dbo.FACT_INVOICE_VTOLL_AMOUNT_PAID_STAGE vTollPaid ON vbi.VIOLATOR_ID = vTollPaid.VIOLATOR_ID AND vbi.vbi_invoice_id = vTollPaid.vbi_invoice_id and vi.VIOL_INVOICE_ID = vTollPaid.VIOL_INVOICE_ID 
		LEFT JOIN dbo.FACT_INVOICE_VIOL_INVOICE_ID_STAGE pay_date ON vi.viol_invoice_id = pay_Date.viol_invoice_id
		INNER JOIN dbo.FACT_INVOICE_VIOL_INVOICE_SUM_STAGE viol_inv_sum ON vi.VIOLATOR_ID = viol_inv_sum.VIOLATOR_ID AND vi.VIOL_INVOICE_ID = viol_inv_sum.VIOL_INVOICE_ID
		LEFT JOIN dbo.court_act_viol cav ON vi.viol_invoice_id = CAV.VIOL_INVOICE_ID
		LEFT JOIN dbo.court_actions ca ON cav.court_action_id = CA.COURT_ACTION_ID
		LEFT JOIN dbo.ca_acct_inv_xref caix ON VI.VIOL_INVOICE_ID = CAIX.VIOL_INVOICE_ID
		LEFT JOIN dbo.ca_accts cacct ON CAIX.CA_ACCT_ID = CACCT.CA_ACCT_ID
	where 
			vb_inv_batch_type_code not IN  ('LN', 'FLN') 
		--AND vbi.INVOICE_DATE between '2015-12-01' and '2015-12-31'

	union all

-- EXPLAIN
	SELECT -- TOP 100000
		7 AS INVOICE_ANALYSIS_CATEGORY_ID, -- 'VIOL INVOICES NEVER BEEN A VB INVOICE
		'1/1/1900' AS DATE_BATCH_PRODUCED, 
		-1 as VBI_INVOICE_ID, 
		'1/1/1900' AS VB_INV_DATE,
		'1/1/1900' AS VB_INV_DATE_EXCUSED,
		-1 AS ZI_STAGE_ID,
		Case 
			--when VBI.VBB_LN_BATCH_ID is null and vbi.vbi_status <> 'CV' then 1 -- 'ZipCash'  -- First Notice and not Converted to Viol Invoice
			--when VBI.VBB_LN_BATCH_ID is not null and vbi.vbi_status <> 'CV' then 2 -- 'First Notice'  -- NOT First Notice and not Converted to Viol Invoice
			when VI.DPS_INV_STATUS in ('H','T') then 3 -- 'Citation Printed' -- DPS Status = Citation Printed OR Citation Issued
			when VI.CA_INV_STATUS = 'A' and VI.DPS_INV_STATUS = 'N' Then 4 -- 'Awaiting DPS' -- Pat's was 'Post-CA'
			when VI.DPS_INV_STATUS = 'D' then 4 -- 'Awaiting DPS' -- Pat's was 'Post-CA' -- Awaiting DPS Action
			when VI.CA_INV_STATUS = 'N' AND VI.DPS_INV_STATUS = 'N ' then 6 -- 'Second Notice' -- Pat's was 2nd NNP  --  CA = N	'Not Sent to Collections Agency' DPS = N	No DPS Activity
			else 7 -- 'In Collections'
		END AS INVOICE_STAGE_ID,
		VI.VIOLATOR_ID,
		0 AS VB_INV_AMT, 
		0 AS VB_INVOICE_AMT_DISC,
		0 AS VB_INV_LATE_FEES,
		0 AS VB_INV_AMT_PAID,
		vi.INVOICE_DATE AS CONVERTED_DATE,
		ISNULL(vi.DATE_EXCUSED,'1/1/1900') AS VIOL_INV_DATE_EXCUSED,
		vi.VIOL_INVOICE_ID,
		VI.INVOICE_AMOUNT AS VI_INV_AMT,
		VI.INVOICE_AMT_DISC AS VI_INVOICE_AMT_DISC,
		ISNULL(pay_date.date_paid,'1/1/1900') AS PAID_DATE,
		ISNULL(pay_date.POS_ID,-1) AS POS_ID, 
		ISNULL(pay_date.PAYMENT_SOURCE_CODE,'-1') AS PAYMENT_SOURCE_CODE,
		ISNULL(pay_date.DELIVERY_CODE,'-1') AS DELIVERY_CODE,  
		ISNULL(pay_date.PAYMENT_FORM,'-1') AS PAYMENT_FORM, 
		ISNULL(pay_date.PAYMENT_CREATED_BY,'(Null)') AS PAYMENT_CREATED_BY, 
		viol_inv_sum.FINE_AMOUNT AS VIOL_INV_FEES,
		VI.INV_ADMIN_FEE AS VIOL_INV_ADMIN_FEE,
		VI.INV_ADMIN_FEE2 AS VIOL_INV_ADMIN_FEE2,  
		CASE 
			WHEN VI.VIOL_INV_STATUS = 'TS' THEN vTollPaid.VTOLL_AMT_PAID 
			ELSE VI.INVOICE_AMT_PAID
		END AS VIOL_INV_AMT_PAID,
		ISNULL(VI.CA_INV_STATUS,'-1') AS CA_INV_STATUS,
		ISNULL(CACCT.CA_COMPANY_ID,-1) AS CA_COMPANY_ID,
		ISNULL(CACCT.CA_ACCT_ID,-1) AS CA_ACCT_ID,
		ISNULL(Convert(date,cacct.file_gen_date),'1/1/1900') AS CA_FILE_GEN_DATE,
		ISNULL(CA.CITATION_NBR,'(Null)') AS CITATION_NBR,
		ISNULL(ca.mail_date,'1/1/1900') AS COURT_ACTION_MAIL_DATE,
		ISNULL(VI.DPS_INV_STATUS,'-1') AS DPS_INV_STATUS,
		0 AS ZC_TXN_COUNT, 
		viol_inv_sum.VIOL_TXN_COUNT,
		0 AS ZC_TOLLS_DUE, 
		viol_inv_sum.VIOL_TOLLS_DUE
-- SELECT COUNT(*) -- 3320029
FROM dbo.viol_invoices vi 
	LEFT JOIN dbo.FACT_INVOICE_VTOLL_AMOUNT_PAID_STAGE vTollPaid ON vi.VIOLATOR_ID = vTollPaid.VIOLATOR_ID AND vTollPaid.vbi_invoice_id = -1 and vi.VIOL_INVOICE_ID = vTollPaid.VIOL_INVOICE_ID 
	INNER JOIN FACT_INVOICE_VIOL_INV_NO_VB_INV_STAGE viNOvb ON VI.VIOLATOR_ID = viNOvb.VIOLATOR_ID AND VI.VIOL_INVOICE_ID = viNOvb.VIOL_INVOICE_ID
	LEFT JOIN dbo.FACT_INVOICE_VIOL_INVOICE_ID_STAGE pay_date ON vi.viol_invoice_id = pay_Date.viol_invoice_id
	INNER JOIN dbo.FACT_INVOICE_VIOL_INVOICE_SUM_STAGE viol_inv_sum ON vi.VIOLATOR_ID = viol_inv_sum.VIOLATOR_ID AND vi.VIOL_INVOICE_ID = viol_inv_sum.VIOL_INVOICE_ID
	LEFT JOIN dbo.court_act_viol cav ON vi.viol_invoice_id = CAV.VIOL_INVOICE_ID
	LEFT JOIN dbo.court_actions ca ON cav.court_action_id = CA.COURT_ACTION_ID
	LEFT JOIN dbo.ca_acct_inv_xref caix ON VI.VIOL_INVOICE_ID = CAIX.VIOL_INVOICE_ID
	LEFT JOIN dbo.ca_accts cacct ON CAIX.CA_ACCT_ID = CACCT.CA_ACCT_ID

------ ------ ------ ------ ------ ------ ------ ------ ------ ------ 
------ ------ ------  FINAL STATS ------ ------ ------ ------ ------ 
------ ------ ------ ------ ------ ------ ------ ------ ------ ------ 

------CreateStats 'FACT_INVOICE_STAGE'
exec DropStats 'dbo','FACT_INVOICE_STAGE'

CREATE STATISTICS STATS_FACT_INVOICE_STAGE_001 ON [dbo].FACT_INVOICE_STAGE (VIOLATOR_ID)

CREATE STATISTICS STATS_FACT_INVOICE_STAGE_003 ON [dbo].FACT_INVOICE_STAGE 
	(VIOLATOR_ID, VBI_INVOICE_ID, VIOL_INVOICE_ID, CA_FILE_GEN_DATE, CA_ACCT_ID, CITATION_NBR, PAID_DATE, POS_ID, DELIVERY_CODE, PAYMENT_SOURCE_CODE)

CREATE STATISTICS STATS_FACT_INVOICE_STAGE_004 ON [dbo].FACT_INVOICE_STAGE 
	(VIOLATOR_ID, VBI_INVOICE_ID, VIOL_INVOICE_ID)

CREATE STATISTICS STATS_FACT_INVOICE_STAGE_005 ON [dbo].FACT_INVOICE_STAGE 
	(VIOLATOR_ID, VBI_INVOICE_ID)

CREATE STATISTICS STATS_FACT_INVOICE_STAGE_006 ON [dbo].FACT_INVOICE_STAGE 
	(VIOLATOR_ID, VBI_INVOICE_ID, VIOL_INVOICE_ID, CA_FILE_GEN_DATE, CA_ACCT_ID, CITATION_NBR, PAID_DATE, POS_ID )

	

