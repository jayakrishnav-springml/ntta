CREATE VIEW [dbo].[vw_DIM_VIOL_OR_TOLL_TRANSACTION] AS select	VIOL_OR_TOLL_TRANSACTION
				as ViolationOrTollID
,	VIOL_OR_TOLL_TRANSACTION_DESC
				as ViolationOrTollDesc
from	dbo.DIM_VIOL_OR_TOLL_TRANSACTION;
