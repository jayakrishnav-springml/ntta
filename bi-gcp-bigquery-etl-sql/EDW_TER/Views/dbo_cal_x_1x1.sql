CREATE VIEW [dbo].[cal_x_1x1] AS select	cal_x_1x1_id		cal_x_1x1_id
,	cal_x_1x1_id		cal_x_1x1_sort
,	cal_x_1x1_desc_1	cal_x_1x1_desc_1
,	cal_x_1x1_desc_2	cal_x_1x1_desc_2
from	dto.cal_x_1x1
where	not etl_chg = 'd';
