CREATE VIEW [dbo].[vw_DIM_INVOICE_TYPE] AS select	INVOICE_TYPE		as InvoiceTypeID
,	INVOICE_TYPE_DESC	as InvoiceTypeDesc
from	dbo.DIM_INVOICE_TYPE;
