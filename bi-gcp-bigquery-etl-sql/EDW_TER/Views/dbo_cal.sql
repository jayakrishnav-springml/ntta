CREATE VIEW [dbo].[cal] AS select	cal_id				cal_id
,	cal_bgn					cal_bgn
,	cal_end					cal_end
,	cal_wk_day_end			cal_wk_day_end
,	cal_days_nrml			cal_days_nrml
,	cal_days_leap			cal_days_leap
,	cal_wks_nrml			cal_wks_nrml
,	cal_wks_leap			cal_wks_leap
,	cal_prds_nrml			cal_prds_nrml
,	cal_prds_leap			cal_prds_leap
,	cal_qtrs_nrml			cal_qtrs_nrml
,	cal_qtrs_leap			cal_qtrs_leap
,	cal_seas_nrml			cal_seas_nrml
,	cal_seas_leap			cal_seas_leap
,	cal_desc				cal_desc
from	dto.cal;
