CREATE VIEW [dvo].[cal_role] AS select	cal_role_id			cal_role_id
,	cal_role_ix				cal_role_ix
,	cal_role_desc_1			cal_role_desc_1
,	cal_role_desc_2			cal_role_desc_2
from	dbo.cal_role
where	not etl_chg = 'd';
