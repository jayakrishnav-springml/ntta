CREATE VIEW [dbo].[vw_PAYMENT_SOURCE] AS select	PAYMENT_SOURCE_CODE	as PaymentSourceCodeID
,	PAYMENT_SOURCE_CODE_DESCR
				as PaymentSourceCodeDesc
from	dbo.PAYMENT_SOURCE;
