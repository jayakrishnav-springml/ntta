CREATE PROC [DBO].[FACT_INVOICE_VIOL_INVOICE_ID_STAGE_LOAD] AS 


IF OBJECT_ID('dbo.FACT_INVOICE_VIOL_INVOICE_ID_STAGE')>0	DROP TABLE dbo.FACT_INVOICE_VIOL_INVOICE_ID_STAGE

CREATE TABLE dbo.FACT_INVOICE_VIOL_INVOICE_ID_STAGE WITH (CLUSTERED INDEX (VIOL_INVOICE_ID),DISTRIBUTION = HASH(VIOL_INVOICE_ID)) 
AS 
--DBCC PDW_SHOWSPACEUSED('dbo.FACT_INVOICE_VIOL_INVOICE_ID_STAGE');

	select 
		  px.viol_invoice_id
		, CONVERT(date,p.payment_date) date_paid
		, s.pos_id
		, p.PAYMENT_SOURCE_CODE
		, MAX(pli.PAYMENT_FORM) AS PAYMENT_FORM
		, P.DELIVERY_CODE
		, MAX(p.CREATED_BY) as PAYMENT_CREATED_BY
	from dbo.PAYMENTS_VPS p
	INNER JOIN dbo.payment_line_items_VPS pli ON p.payment_txn_id = pli.payment_txn_id
	INNER JOIN dbo.payment_xref_VPS px ON pli.payment_line_item_id = px.payment_line_item_id
	LEFT JOIN LND_LG_VPS.VP_OWNER.SHIFTS  s ON p.shift_id = s.shift_id
	where 
			p.payment_status = 'A'
		and pli.payment_status = 'A'
		and px.viol_invoice_id is not null
		and not exists
			(
				select 'already undone'
				from dbo.payments_vps pi
				INNER JOIN dbo.payment_line_items_VPS pli1 ON pi.payment_txn_id = pli1.payment_txn_id
				where 
						p.VIOLATOR_ID = pi.VIOLATOR_ID 
					and p.payment_txn_id = pi.ref_txn_id
					and pli1.pmt_txn_type in ('VB', 'VC', 'C', 'B', 'U')
					and pli1.payment_line_item_amount < 0
			)
		and pli.payment_line_item_amount > 0
	GROUP BY 
		  px.viol_invoice_id
		, CONVERT(date,p.payment_date)
		, s.pos_id
		, p.PAYMENT_SOURCE_CODE
		, P.DELIVERY_CODE



--exec DropStats 'dbo','FACT_INVOICE_VIOL_INVOICE_ID_STAGE' 
-- exec CreateStats 'FACT_INVOICE_VIOL_INVOICE_ID_STAGE'

CREATE STATISTICS STATS_FACT_INVOICE_VIOL_INVOICE_ID_STAGE_001 ON DBO.FACT_INVOICE_VIOL_INVOICE_ID_STAGE  (pos_id)
CREATE STATISTICS STATS_FACT_INVOICE_VIOL_INVOICE_ID_STAGE_002 ON DBO.FACT_INVOICE_VIOL_INVOICE_ID_STAGE  (date_paid)
CREATE STATISTICS STATS_FACT_INVOICE_VIOL_INVOICE_ID_STAGE_003 ON DBO.FACT_INVOICE_VIOL_INVOICE_ID_STAGE  (PAYMENT_SOURCE_CODE)
CREATE STATISTICS STATS_FACT_INVOICE_VIOL_INVOICE_ID_STAGE_004 ON DBO.FACT_INVOICE_VIOL_INVOICE_ID_STAGE  (DELIVERY_CODE)
CREATE STATISTICS STATS_FACT_INVOICE_VIOL_INVOICE_ID_STAGE_005 ON DBO.FACT_INVOICE_VIOL_INVOICE_ID_STAGE  (PAYMENT_FORM)
CREATE STATISTICS STATS_FACT_INVOICE_VIOL_INVOICE_ID_STAGE_006 ON DBO.FACT_INVOICE_VIOL_INVOICE_ID_STAGE  (PAYMENT_CREATED_BY)



