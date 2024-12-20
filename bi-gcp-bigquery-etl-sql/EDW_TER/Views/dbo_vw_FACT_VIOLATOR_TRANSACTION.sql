CREATE VIEW [dbo].[vw_FACT_VIOLATOR_TRANSACTION] AS select	ViolatorID		as ViolatorID
,	VidSeq			as VidSeq
,	TRANSACTION_ID		as TransactionID
,	VIOL_OR_TOLL_TRANSACTION
				as ViolationOrTollID
,	LANE_ID			as LaneID
,	LICENSE_PLATE_ID	as TransactionLicensePlateID
,	VIOL_STATUS		as ViolationStatusID
,	TRANS_TYPE_ID		as TransactionTypeID
,	SOURCE_CODE		as SourceCodeID
,	TRANSACTION_DATE	as TransactionDate
,	TRANSACTION_TIME_ID	as TransactionTimeID
,	POST_DATE		as TransactionPostDate
,	POST_TIME_ID		as TransactionPostTimeID
,	STATUS_DATE		as TransactionStatusDate
,	DATE_EXCUSED		as TransactionExcusedDate
,	TOLL_DUE		as ViolationTollDue
,	TOLL_PAID		as ViolationTollPaid
,	ZC_INVOICE_COUNT	as ZipCashInvoiceCount
,	VIOL_INVOICE_COUNT	as ViolationInvoiceCount
from	dbo.FACT_VIOLATOR_TRANSACTION;
