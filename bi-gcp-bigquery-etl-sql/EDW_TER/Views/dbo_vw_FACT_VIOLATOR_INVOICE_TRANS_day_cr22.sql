CREATE VIEW [dbo].[vw_FACT_VIOLATOR_INVOICE_TRANS_day_cr22] AS select	f.ViolatorID	as ViolatorID
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
,	f.POST_DATE			as cal_day_bgn
,	f.POST_TIME_ID		as TimeID
,	22					as cal_role_id
from	dbo.FACT_VIOLATOR_INVOICE_TRANS  f;
