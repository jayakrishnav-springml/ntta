CREATE VIEW [dbo].[cal_wk_x] AS select	cal_id
,	cal_x_mxm_id
,	cal_x_1x1_id
,	cal_wk_bgn
,	cal_comp_wk_bgn
,	cal_comp_bgn
,	cal_comp_end
,	cal_wk_x_bgn
,	cal_wk_x_end
from	dto.cal_wk_x;
