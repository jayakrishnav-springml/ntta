CREATE VIEW [dbo].[vw_FACT_VIOLATOR_PAYMENT_prd_x_cr87] AS select	f.ViolatorID	as ViolatorID
,	f.VidSeq			as VidSeq
,	f.PAYMENT_TXN_ID	as PaymentTransactionID
,	f.LicensePlateID	as ViolatorLicensePlateID
,	f.CARD_CODE			as PaymentCreditCardCode
,	f.PAYMENT_SOURCE_CODE
						as PaymentSourceCodeID
,	f.VIOL_PAY_TYPE		as ViolatorPayTypeID
,	f.PMT_TXN_TYPE		as PaymentTransactionTypeID
,	f.RETAIL_TRANS_ID	as RetailTransactionID
,	f.TRANS_AMT			as PaymentTransactionAmount
,	f.CREATED_BY		as PaymentCreatedBy
,	f.POS_NAME			as PointOfSaleName
,	f.INVOICE_TYPE		as InvoiceTypeID
,	f.INV_TOLL_AMT		as InvoiceTollAmt
,	f.INV_FEES_AMT		as InvoiceFeesAmt
,	f.AMOUNT_DUE		as PaymentDueAmt
,	cx.cal_id			as cal_id
,	cx.cal_x_mxm_id		as cal_x_mxm_id
,	cx.cal_x_1x1_id		as cal_x_1x1_id
,	cx.cal_prd_bgn		as cal_prd_bgn
,	cx.cal_comp_prd_bgn	as cal_comp_prd_bgn
,	87					as cal_role_id
from	dbo.FACT_VIOLATOR_PAYMENT  f
  join	dbo.ViolatorStatus  vs
    on	f.ViolatorID = vs.ViolatorID
    and	f.VidSeq = vs.VidSeq
  join	dto.cal_day  d
    on	vs.HvDate = d.cal_day_bgn
  join	dto.cal_prd_x  cx
    on	d.cal_prd_bgn = cx.cal_prd_x_bgn
    and	d.cal_id = cx.cal_id;
