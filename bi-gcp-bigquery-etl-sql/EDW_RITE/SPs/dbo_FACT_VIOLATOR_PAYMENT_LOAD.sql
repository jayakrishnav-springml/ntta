CREATE PROC [DBO].[FACT_VIOLATOR_PAYMENT_LOAD] AS 

IF (SELECT COUNT(*) FROM edw_rite.dbo.PAYMENT_LINE_ITEMS_VPS)>0 
BEGIN 

	IF OBJECT_ID('dbo.FACT_VIOLATOR_PAYMENT_LINE_ITEMS_STAGE')<>0		DROP TABLE dbo.FACT_VIOLATOR_PAYMENT_LINE_ITEMS_STAGE

	IF OBJECT_ID('dbo.FACT_VIOLATOR_PAYMENT_NEW')<>0		DROP TABLE dbo.FACT_VIOLATOR_PAYMENT_NEW

	CREATE TABLE dbo.FACT_VIOLATOR_PAYMENT_NEW WITH (CLUSTERED INDEX (PAYMENT_TXN_ID), DISTRIBUTION = HASH(ViolatorId))
	AS 
		SELECT	
				 ViolatorId
				, VidSeq
				, PAYMENT_TXN_ID
				, LicensePlateID
				, CARD_CODE
				, PAYMENT_SOURCE_CODE
				, VIOL_PAY_TYPE
				, PMT_TXN_TYPE
				, RETAIL_TRANS_ID
				, TRANS_DATE
				, SUM (split_amount) TRANS_AMT
				, CREATED_BY 
				, POS_NAME
		--New Fields
				, SUM (toll_amount) AS INV_TOLL_AMT
				, SUM (fees_amount) AS INV_FEES_AMT
				, INVOICE_TYPE
				, MAX(amount_due) AS AMOUNT_DUE
				, VIOL_INVOICE_ID
				, VBI_VBI_INVOICE_ID
		-- Old Field
				, GETDATE() AS INSERT_DATE
			FROM (
					SELECT 
							tr.ViolatorId,
							tr.VidSeq,
							p.payment_Txn_id,
							tr.LicensePlateID,
							ISNULL(CONVERT(varchar(2),pli.CREDIT_CARD_TYPE),'-1') AS CARD_CODE,
							p.PAYMENT_SOURCE_CODE,
							p.VIOL_PAY_TYPE,
							rtl.RETAIL_TRANS_ID,
							convert(date,p.payment_Date) AS TRANS_DATE,
							COALESCE(px.split_amount,P.Amount_Tendered,px.split_amount )split_amount , 
							p.CREATED_BY,
							pos.POS_NAME,
							pli.PMT_TXN_TYPE,
							p.amount_due,
							VB.TOLL_AMOUNT,
							(  VB.LATE_FEE_AMOUNT + VB.PAST_DUE_LATE_FEE_AMOUNT + VB.PAST_DUE_MAIL_FEE_AMOUNT) AS fees_amount,
							CASE 
								WHEN PX.VIOL_INVOICE_ID IS NULL AND PX.VBI_VBI_INVOICE_ID IS NULL THEN 'UN'
								WHEN PX.VBI_VBI_INVOICE_ID IS NOT NULL THEN 'ZC'
								WHEN PX.VIOL_INVOICE_ID IS NOT NULL THEN 'VI'
							END AS invoice_type,
							PX.VIOL_INVOICE_ID, 
							PX.VBI_VBI_INVOICE_ID
					FROM -- dbo.vw_Violator tr 
						(
								SELECT tr1.ViolatorId,tr1.VidSeq, ISNULL(LicensePlateID,-1) as LicensePlateID, tr1.CURRENT_IND
								FROM EDW_TER.dbo.vw_Violator tr1
								LEFT JOIN EDW_TER.dbo.vw_DIM_LICENSE_PLATE lp ON lp.LicensePlateNumber = tr1.LicPlateNbr AND lp.LicensePlateStateId = tr1.LicPlateStateLookupID 

								UNION 

								SELECT DISTINCT AA.AltViolatorID, 1 As VidSeq, ISNULL(LP2.LICENSE_PLATE_ID,-1) AS LicensePlateID, 1 as CURRENT_IND
								FROM EDW_TER.dbo.Violator_PaymentAgreement_VIOL_INVOICES AA
								INNER JOIN edw_rite.dbo.Violators V ON AA.AltViolatorID = V.VIOLATOR_ID
								LEFT JOIN EDW_TER.dbo.DIM_LICENSE_PLATE LP2  ON V.LIC_PLATE_NBR = LP2.LICENSE_PLATE_NBR AND V.LIC_PLATE_STATE = LP2.LICENSE_PLATE_STATE
								LEFT JOIN edw_ter.dbo.vw_Violator BB ON AA.AltViolatorID  = BB.ViolatorID 
								where BB.ViolatorID IS NULL		
						) tr
							INNER JOIN edw_rite.dbo.PAYMENTS_VPS p ON tr.violatorid = p.violator_id 
							LEFT JOIN edw_rite.dbo.payment_line_items_vps pli ON P.PAYMENT_TXN_ID = PLI.PAYMENT_TXN_ID
							LEFT JOIN edw_rite.dbo.payment_Xref_vps px ON PLI.PAYMENT_LINE_ITEM_ID = PX.PAYMENT_LINE_ITEM_ID
							JOIN edw_rite.dbo.vb_invoices vb ON VB.VBI_INVOICE_ID = PX.VBI_VBI_INVOICE_ID 
							LEFT JOIN edw_rite.dbo.RETAIL_TRANSACTIONS rtl 
								ON p.VIOLATOR_ID = rtl.VIOLATOR_ID AND p.PAYMENT_TXN_ID = rtl.PAYMENT_TXN_ID AND p.RETAIL_TRANS_ID = rtl.RETAIL_TRANS_ID
							LEFT JOIN edw_rite.dbo.POS_LOCATIONS pos ON rtl.POS_ID = pos.POS_ID
			

					WHERE 
					
						tr.CURRENT_IND = 1

					UNION ALL

					SELECT 
							tr.ViolatorId,
							tr.VidSeq,
							p.payment_Txn_id,
							tr.LicensePlateID,
							ISNULL(CONVERT(varchar(2),pli.CREDIT_CARD_TYPE),'-1') AS CARD_CODE,
							p.PAYMENT_SOURCE_CODE,
							p.VIOL_PAY_TYPE,
							rtl.RETAIL_TRANS_ID,
							CONVERT(date,p.payment_Date) AS TRANS_DATE,
							COALESCE(px.split_amount ,P.Amount_Tendered, px.split_amount)split_amount ,
							p.CREATED_BY,
							pos.POS_NAME,
							pli.PMT_TXN_TYPE,
							p.amount_due,
							( SELECT SUM( VIV.TOLL_DUE_AMOUNT) FROM         edw_rite.dbo.viol_invoice_viol viv  WHERE  PX.VIOL_INVOICE_ID = VIV.VIOL_INVOICE_ID ) AS TOLL_AMOUNT,
							( SELECT SUM( VIV.FINE_AMOUNT) FROM         edw_rite.dbo.viol_invoice_viol viv  WHERE  PX.VIOL_INVOICE_ID = VIV.VIOL_INVOICE_ID ) AS fees_amount,
							CASE 
								WHEN PX.VIOL_INVOICE_ID IS NULL AND PX.VBI_VBI_INVOICE_ID IS NULL THEN 'UN'
								WHEN PX.VBI_VBI_INVOICE_ID IS NOT NULL THEN 'ZC'
								WHEN PX.VIOL_INVOICE_ID IS NOT NULL THEN 'VI'
							END AS invoice_type,
							PX.VIOL_INVOICE_ID, 
							PX.VBI_VBI_INVOICE_ID
					FROM 
						(
								SELECT tr1.ViolatorId,tr1.VidSeq, ISNULL(LicensePlateID,-1) as LicensePlateID, tr1.CURRENT_IND
								FROM EDW_TER.dbo.vw_Violator tr1
								LEFT JOIN EDW_TER.dbo.vw_DIM_LICENSE_PLATE lp ON lp.LicensePlateNumber = tr1.LicPlateNbr AND lp.LicensePlateStateId = tr1.LicPlateStateLookupID 

								UNION 

								SELECT DISTINCT AA.AltViolatorID, 1 As VidSeq, ISNULL(LP2.LICENSE_PLATE_ID,-1) AS LicensePlateID, 1 as CURRENT_IND
								FROM EDW_TER.dbo.Violator_PaymentAgreement_VIOL_INVOICES AA
								INNER JOIN edw_rite.dbo.Violators V ON AA.AltViolatorID = V.VIOLATOR_ID
								LEFT JOIN EDW_TER.dbo.DIM_LICENSE_PLATE LP2  ON V.LIC_PLATE_NBR = LP2.LICENSE_PLATE_NBR AND V.LIC_PLATE_STATE = LP2.LICENSE_PLATE_STATE
								LEFT JOIN EDW_TER.dbo.vw_Violator BB ON AA.AltViolatorID  = BB.ViolatorID 
								where BB.ViolatorID IS NULL		
						) tr
							INNER JOIN edw_rite.dbo.PAYMENTS_VPS p ON tr.violatorid = p.violator_id -- VPS payments 
							LEFT JOIN edw_rite.dbo.payment_line_items_vps pli ON P.PAYMENT_TXN_ID = PLI.PAYMENT_TXN_ID -- VPS payment_line_items 
							LEFT JOIN edw_rite.dbo.payment_Xref_vps px ON PLI.PAYMENT_LINE_ITEM_ID = PX.PAYMENT_LINE_ITEM_ID
							LEFT JOIN edw_rite.dbo.RETAIL_TRANSACTIONS rtl 
								ON p.VIOLATOR_ID = rtl.VIOLATOR_ID AND p.PAYMENT_TXN_ID = rtl.PAYMENT_TXN_ID AND p.RETAIL_TRANS_ID = rtl.RETAIL_TRANS_ID
							LEFT JOIN edw_rite.dbo.POS_LOCATIONS pos ON rtl.POS_ID = pos.POS_ID
--						
					WHERE   	tr.CURRENT_IND = 1
						) ASDASD
		GROUP BY	
					ViolatorId
				, VidSeq
				, PAYMENT_TXN_ID
				, LicensePlateID
				, CARD_CODE
				, PAYMENT_SOURCE_CODE
				, VIOL_PAY_TYPE
				, PMT_TXN_TYPE
				, RETAIL_TRANS_ID
				, TRANS_DATE
				, CREATED_BY 
				, POS_NAME
		--New Fields
				, invoice_type
				, VIOL_INVOICE_ID
				, VBI_VBI_INVOICE_ID

	CREATE STATISTICS STATS_FACT_VIOLATOR_PAYMENT_001 ON dbo.FACT_VIOLATOR_PAYMENT_NEW (ViolatorID,VidSeq, PAYMENT_TXN_ID)

	IF OBJECT_ID('dbo.FACT_VIOLATOR_PAYMENT')<>0		RENAME OBJECT::dbo.FACT_VIOLATOR_PAYMENT TO FACT_VIOLATOR_PAYMENT_OLD;

	RENAME OBJECT::dbo.FACT_VIOLATOR_PAYMENT_NEW TO FACT_VIOLATOR_PAYMENT;

	IF OBJECT_ID('dbo.FACT_VIOLATOR_PAYMENT_OLD')>0		DROP TABLE dbo.FACT_VIOLATOR_PAYMENT_OLD



END


