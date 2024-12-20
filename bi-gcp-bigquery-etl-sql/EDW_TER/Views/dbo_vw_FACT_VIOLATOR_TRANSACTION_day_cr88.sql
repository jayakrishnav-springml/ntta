CREATE VIEW [dbo].[vw_FACT_VIOLATOR_TRANSACTION_day_cr88] AS select	f.ViolatorID	as ViolatorID
,	f.VidSeq			as VidSeq
,	f.TRANSACTION_ID	as TransactionID
,	f.VIOL_OR_TOLL_TRANSACTION
						as ViolationOrTollID
,	f.LANE_ID			as LaneID
,	f.LICENSE_PLATE_ID	as TransactionLicensePlateID
,	f.VIOL_STATUS		as ViolationStatusID
,	f.TRANS_TYPE_ID		as TransactionTypeID
,	f.SOURCE_CODE		as SourceCodeID
,	f.TRANSACTION_DATE	as TransactionDate
,	f.TRANSACTION_TIME_ID
						as TransactionTimeID
,	f.POST_DATE			as TransactionPostDate
,	f.POST_TIME_ID		as TransactionPostTimeID
,	f.STATUS_DATE		as TransactionStatusDate
,	f.DATE_EXCUSED		as TransactionExcusedDate
,	f.TOLL_DUE			as ViolationTollDue
,	f.TOLL_PAID			as ViolationTollPaid
,	f.ZC_INVOICE_COUNT	as ZipCashInvoiceCount
,	f.VIOL_INVOICE_COUNT
						as ViolationInvoiceCount
,	vs.HvExemptDate		as cal_day_bgn
,	-1					as TimeID
,	88					as cal_role_id
from	dbo.FACT_VIOLATOR_TRANSACTION  f
  join	dbo.ViolatorStatus  vs
    on	f.ViolatorID = vs.ViolatorID
    and	f.VidSeq = vs.VidSeq;
