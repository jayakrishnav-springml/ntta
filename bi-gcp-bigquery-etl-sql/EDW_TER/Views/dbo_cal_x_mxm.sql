CREATE VIEW [dbo].[cal_x_mxm] AS select	cal_x_mxm_id		cal_x_mxm_id
,	cal_x_mxm_id		cal_x_mxm_sort
,	cal_x_mxm_attrib	cal_x_mxm_attrib
,	cal_x_mxm_desc_1	cal_x_mxm_desc_1
,	cal_x_mxm_desc_2	cal_x_mxm_desc_2
from	dto.cal_x_mxm
where	not etl_chg = 'd';
