CREATE VIEW [dbo].[vw_TRANSACTION_TYPES] AS select	
TRANS_TYPE_ID		as TransactionTypeID
,	TRANS_TYPE_DESCR	as TransactionTypeDesc
from	dbo.TRANSACTION_TYPES;
