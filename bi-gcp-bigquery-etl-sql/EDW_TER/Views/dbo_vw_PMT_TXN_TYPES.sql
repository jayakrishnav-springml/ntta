CREATE VIEW [dbo].[vw_PMT_TXN_TYPES] AS select	PMT_TXN_TYPE		as PaymentTransactionTypeID
,	PMT_TXN_TYPE_DESCR	as PaymentTransactionTypeDesc
from	dbo.PMT_TXN_TYPES;
