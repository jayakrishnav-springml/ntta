CREATE VIEW [dbo].[vw_DIM_INVOICE_STATUS] AS select	INVOICE_TYPE		as InvoiceTypeID
,	INVOICE_STATUS		as InvoiceStatusID,	INVOICE_STATUS_DESCR		as InvoiceStatusDESC
from	dbo.DIM_INVOICE_STATUS;
