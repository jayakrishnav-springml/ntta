CREATE VIEW [dbo].[vw_FACT_VIOLATOR_INVOICE_TRANS] AS select	ViolatorID		as ViolatorID
,	VidSeq			as VidSeq
,	INVOICE_TYPE		as InvoiceTypeID
,	INVOICE_ID		as InvoiceID
,	TRANS_ID		as TransactionID
,	'V'			as ViolationOrTollID
,	VIOL_STATUS		as ViolationStatusID
,	TOLL_DUE_AMOUNT		as ViolationTollDue
,	FINE_AMOUNT		as InvoiceFine
,	VIOL_DATE		as TransactionDate
,	VIOL_TIME_ID		as TransactionTimeID
,	POST_DATE		as TransactionPostDate
,	POST_TIME_ID		as TransactionPostTimeID
from	dbo.FACT_VIOLATOR_INVOICE_TRANS;
