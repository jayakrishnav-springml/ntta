CREATE VIEW [dbo].[vw_FACT_VIOLATOR_INVOICE_TRANS_day_cr11] AS select	f.ViolatorID	as ViolatorID
,	f.VidSeq			as VidSeq
,	f.INVOICE_ID		as InvoiceID
,	f.INVOICE_TYPE		as InvoiceTypeID
,	f.TRANS_ID			as TransactionID
,	'V'					as ViolationOrTollID
,	f.VIOL_DATE			as TransactionDate
,	f.VIOL_TIME_ID		as TransactionTimeID
,	f.POST_DATE			as TransactionPostDate
,	f.POST_TIME_ID		as TransactionPostTimeID
,	f.VIOL_STATUS		as ViolationStatusID
,	f.TOLL_DUE_AMOUNT	as ViolationTollDue
,	f.FINE_AMOUNT		as InvoiceFine
,	i.INVOICE_DATE		as cal_day_bgn
,	(datepart(hour, i.INVOICE_DATE) * 3600 + datepart(minute, i.INVOICE_DATE) * 60 + datepart(second, i.INVOICE_DATE))
						as TimeID
,	11					as cal_role_id
from	dbo.FACT_VIOLATOR_INVOICE_TRANS  f
  join	dbo.FACT_VIOLATOR_INVOICE  i
    on	f.ViolatorID = i.ViolatorID
    and f.VidSeq = i.VidSeq
    and f.INVOICE_ID = i.INVOICE_ID
    and f.INVOICE_TYPE = i.INVOICE_TYPE;
