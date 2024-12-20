CREATE VIEW [dbo].[vw_FACT_VIOLATOR_PAYMENT] AS select	ViolatorId		as ViolatorID
	,	VidSeq				as VidSeq
	,	PAYMENT_TXN_ID		as PaymentTransactionID
	,	LicensePlateID		as ViolatorLicensePlateID
	,	CARD_CODE			as PaymentCreditCardCode
	,	PAYMENT_SOURCE_CODE	as PaymentSourceCodeID
	,	VIOL_PAY_TYPE		as ViolatorPayTypeID
	,	PMT_TXN_TYPE		as PaymentTransactionTypeID
	,	RETAIL_TRANS_ID		as RetailTransactionID
	,	TRANS_DATE			as PaymentTransactionDate
	,	TRANS_AMT			as PaymentTransactionAmount
	,	CREATED_BY			as PaymentCreatedBy
	,	POS_NAME			as PointOfSaleName
	,	INVOICE_TYPE		as InvoiceTypeID
	,	INV_TOLL_AMT		as InvoiceTollAmt
	,	INV_FEES_AMT		as InvoiceFeesAmt
	,	AMOUNT_DUE			as PaymentDueAmt
	FROM	dbo.FACT_VIOLATOR_PAYMENT
	WHERE	PAYMENT_STATUS = 'A' AND NOT EXISTS 
										(SELECT 'already undone'
										   FROM edw_rite.dbo.PAYMENTS_VPS pi
										  WHERE pi.ref_txn_id = FACT_VIOLATOR_PAYMENT.PAYMENT_TXN_ID
												AND pi.PAYMENT_STATUS = 'I');
