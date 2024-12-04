CREATE VIEW [dbo].[vw_FACT_VIOLATOR_INVOICE_day_cr11] AS select	f.ViolatorID	as ViolatorID
,	f.VidSeq			as VidSeq
,	f.INVOICE_ID		as InvoiceID
,	f.INVOICE_TYPE		as InvoiceTypeID
,	f.INVOICE_DATE		as InvoiceDate
,	f.INVOICE_DUE_DATE	as InvoiceDueDate
,	f.DATE_EXCUSED		as InvoiceExcusedDate
,	f.DATE_MODIFIED		as InvoiceModifiedDate
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
,	f.INVOICE_DATE		as cal_day_bgn
,	(datepart(hour, f.INVOICE_DATE) * 3600 + datepart(minute, f.INVOICE_DATE) * 60 + datepart(second, f.INVOICE_DATE))
						as TimeID
,	11					as cal_role_id
from	dbo.FACT_VIOLATOR_INVOICE  f;
