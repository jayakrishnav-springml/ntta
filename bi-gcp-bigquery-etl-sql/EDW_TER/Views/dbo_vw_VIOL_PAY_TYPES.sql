CREATE VIEW [dbo].[vw_VIOL_PAY_TYPES] AS select	VIOL_PAY_TYPE		as ViolatorPayTypeID
,	VIOL_PAY_TYPE_DESCR	as ViolatorPayTypeDesc
from	dbo.VIOL_PAY_TYPES;
