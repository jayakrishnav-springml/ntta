CREATE VIEW [dbo].[vw_FACT_VIOLATOR_INVOICE_wk_x_cr11] AS select	f.ViolatorID	as ViolatorID
,	f.VidSeq			as VidSeq
,	f.INVOICE_ID		as InvoiceID
,	f.INVOICE_TYPE		as InvoiceTypeID
,	f.INVOICE_BATCH_ID	as InvoiceBatchID
,	f.INVOICE_STATUS	as InvoiceStatusID
,	f.CA_INV_STATUS		as CA_InvoiceStatusID
,	f.DPS_INV_STATUS	as DPS_InvoiceStatusID
,	f.ZI_STAGE_ID		as ZI_StageID
,	f.INVOICE_AMOUNT	as InvoiceAmount
,	f.LATE_FEE_AMOUNT	as InvoiceLateFeeAmount
,	f.PAST_DUE_AMOUNT	as InvoicePastDueAmount
,	f.INV_ADMIN_FEE		as InvoiceAdminFee
,	f.INV_ADMIN_FEE2	as InvoiceAdminFee2
,	f.INVOICE_AMT_PAID	as InvoicePaidAmount
,	f.TOLL_DUE_AMOUNT	as ViolationTollDue
,	f.TOLL_PAID			as ViolationTollPaid
,	f.FINE_AMOUNT		as InvoiceFine
,	cx.cal_id			as cal_id
,	cx.cal_x_mxm_id		as cal_x_mxm_id
,	cx.cal_x_1x1_id		as cal_x_1x1_id
,	cx.cal_wk_bgn		as cal_wk_bgn
,	cx.cal_comp_wk_bgn	as cal_comp_wk_bgn
,	11					as cal_role_id
from	dbo.FACT_VIOLATOR_INVOICE  f
  join	dto.cal_day  d
    on	f.INVOICE_DATE = d.cal_day_bgn
  join	dto.cal_wk_x  cx
    on	d.cal_wk_bgn = cx.cal_wk_x_bgn
    and	d.cal_id = cx.cal_id;
