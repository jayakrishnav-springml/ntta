CREATE VIEW [dbo].[vw_FACT_VIOLATOR_INVOICE] AS select	ViolatorID		as ViolatorID
,	VidSeq				as VidSeq
,	INVOICE_ID			as InvoiceID
,	INVOICE_TYPE		as InvoiceTypeID
,	INVOICE_DATE		as InvoiceDate
,	INVOICE_DUE_DATE	as InvoiceDueDate
,	DATE_EXCUSED		as InvoiceExcusedDate
,	DATE_MODIFIED		as InvoiceModifiedDate
,	INVOICE_BATCH_ID	as InvoiceBatchID
,	INVOICE_STATUS		as InvoiceStatusID
,	CA_INV_STATUS		as CA_InvoiceStatusID
,	DPS_INV_STATUS		as DPS_InvoiceStatusID
,	ZI_STAGE_ID			as ZI_StageID
,	INVOICE_AMOUNT		as InvoiceAmount
,	LATE_FEE_AMOUNT		as InvoiceLateFeeAmount
,	PAST_DUE_AMOUNT		as InvoicePastDueAmount
,	INV_ADMIN_FEE		as InvoiceAdminFee
,	INV_ADMIN_FEE2		as InvoiceAdminFee2
,	INVOICE_AMT_PAID	as InvoicePaidAmount
,	TOLL_DUE_AMOUNT		as ViolationTollDue
,	TOLL_PAID			as ViolationTollPaid
,	FINE_AMOUNT			as InvoiceFine
from	dbo.FACT_VIOLATOR_INVOICE;
