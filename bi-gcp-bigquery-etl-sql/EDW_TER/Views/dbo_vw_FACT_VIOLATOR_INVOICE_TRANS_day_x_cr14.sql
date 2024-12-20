CREATE VIEW [dbo].[vw_FACT_VIOLATOR_INVOICE_TRANS_day_x_cr14] AS select	f.ViolatorID	as ViolatorID
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
,	cx.cal_day_bgn		as cal_day_bgn
,	cx.cal_comp_day_bgn	as cal_comp_day_bgn
,	14					as cal_role_id
from	dbo.FACT_VIOLATOR_INVOICE_TRANS  f
  join	dbo.FACT_VIOLATOR_INVOICE  i
    on	f.ViolatorID = i.ViolatorID
    and f.VidSeq = i.VidSeq
    and f.INVOICE_ID = i.INVOICE_ID
    and f.INVOICE_TYPE = i.INVOICE_TYPE
  join	dto.cal_day_x  cx
    on	i.DATE_MODIFIED = cx.cal_day_x_bgn;
