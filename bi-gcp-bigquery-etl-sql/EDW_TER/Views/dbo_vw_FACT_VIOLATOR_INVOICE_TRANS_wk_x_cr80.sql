CREATE VIEW [dbo].[vw_FACT_VIOLATOR_INVOICE_TRANS_wk_x_cr80] AS select	f.ViolatorID	as ViolatorID
,	f.VidSeq			as VidSeq
,	f.INVOICE_ID		as InvoiceID
,	f.INVOICE_TYPE		as InvoiceTypeID
,	f.TRANS_ID			as TransactionID
,	'V'					as ViolationOrTollID
,	f.VIOL_STATUS		as ViolationStatusID
,	f.TOLL_DUE_AMOUNT	as ViolationTollDue
,	f.FINE_AMOUNT		as InvoiceFine
,	cx.cal_id			as cal_id
,	cx.cal_x_mxm_id		as cal_x_mxm_id
,	cx.cal_x_1x1_id		as cal_x_1x1_id
,	cx.cal_wk_bgn		as cal_wk_bgn
,	cx.cal_comp_wk_bgn	as cal_comp_wk_bgn
,	80					as cal_role_id
from	dbo.FACT_VIOLATOR_INVOICE_TRANS  f
  join	dbo.ViolatorStatus  vs
    on	f.ViolatorID = vs.ViolatorID
    and	f.VidSeq = vs.VidSeq
  join	dto.cal_day  d
    on	vs.BanCiteWarnDate = d.cal_day_bgn
  join	dto.cal_wk_x  cx
    on	d.cal_wk_bgn = cx.cal_wk_x_bgn
    and	d.cal_id = cx.cal_id;
