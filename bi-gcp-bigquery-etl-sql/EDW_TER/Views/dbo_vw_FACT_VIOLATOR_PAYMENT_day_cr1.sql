CREATE VIEW [dbo].[vw_FACT_VIOLATOR_PAYMENT_day_cr1] AS select	f.ViolatorID	as ViolatorID
,	f.VidSeq			as VidSeq
,	f.PAYMENT_TXN_ID	as PaymentTransactionID
,	f.LicensePlateID	as ViolatorLicensePlateID
,	f.CARD_CODE			as PaymentCreditCardCode
,	f.PAYMENT_SOURCE_CODE
						as PaymentSourceCodeID
,	f.VIOL_PAY_TYPE		as ViolatorPayTypeID
,	f.PMT_TXN_TYPE		as PaymentTransactionTypeID
,	f.RETAIL_TRANS_ID	as RetailTransactionID
,	f.TRANS_DATE		as PaymentTransactionDate
,	f.TRANS_AMT			as PaymentTransactionAmount
,	f.CREATED_BY		as PaymentCreatedBy
,	f.POS_NAME			as PointOfSaleName
,	f.INVOICE_TYPE		as InvoiceTypeID
,	f.INV_TOLL_AMT		as InvoiceTollAmt
,	f.INV_FEES_AMT		as InvoiceFeesAmt
,	f.AMOUNT_DUE		as PaymentDueAmt
,	v.EarliestHvTranDate
						as cal_day_bgn
,	-1					as TimeID
,	1					as cal_role_id
from	dbo.FACT_VIOLATOR_PAYMENT  f
  join	dbo.Violator  v
    on	f.ViolatorID = v.ViolatorID
    and	f.VidSeq = v.VidSeq;
