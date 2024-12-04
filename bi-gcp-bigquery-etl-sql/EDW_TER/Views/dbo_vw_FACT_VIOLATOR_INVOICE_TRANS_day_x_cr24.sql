CREATE VIEW [dbo].[vw_FACT_VIOLATOR_INVOICE_TRANS_day_x_cr24] AS select	f.ViolatorID	as ViolatorID
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
,	24					as cal_role_id
from	dbo.FACT_VIOLATOR_INVOICE_TRANS  f
  join	dbo.FACT_VIOLATOR_TRANSACTION  t
    on	f.ViolatorID = t.ViolatorID
    and f.VidSeq = t.VidSeq
    and f.TRANS_ID = t.TRANSACTION_ID
    and 'V' = t.VIOL_OR_TOLL_TRANSACTION
  join	dto.cal_day_x  cx
    on	t.DATE_EXCUSED = cx.cal_day_x_bgn;
