CREATE VIEW [dvo].[cal_wk] AS select	cal_id				cal_id
,	cal_wk_bgn				cal_wk_bgn
,	cal_wk_end				cal_wk_end
,	cal_wk_ix				cal_wk_ix
,	cal_wk_prd_bgn			cal_wk_prd_bgn
,	cal_wk_qtr_bgn			cal_wk_qtr_bgn
,	cal_wk_sea_bgn			cal_wk_sea_bgn
,	cal_wk_yr_bgn			cal_wk_yr_bgn
,	cal_yr_bgn				cal_yr_bgn
,	cal_yr_end				cal_yr_end
,	cal_yr_ix				cal_yr_ix
,	cal_yr_leap				cal_yr_leap

,	cal_wks_prd				cal_wks_prd
,	cal_wk_prd				cal_wk_prd
,	cal_wks_qtr				cal_wks_qtr
,	cal_wk_qtr				cal_wk_qtr
,	cal_wks_sea				cal_wks_sea
,	cal_wk_sea				cal_wk_sea
,	cal_wks_yr				cal_wks_yr
,	cal_wk_yr				cal_wk_yr

,	cal_wk_sid				cal_wk_sid
,	cal_yr_sid				cal_yr_sid
,	cal_wk_prd_sid			cal_wk_prd_sid
,	cal_wk_qtr_sid			cal_wk_qtr_sid
,	cal_wk_sea_sid			cal_wk_sea_sid
,	cal_wk_yr_sid			cal_wk_yr_sid

,	cal_wk_desc_1			cal_wk_desc_1
,	cal_yr_desc_1			cal_yr_desc_1
,	cal_wk_prd_desc_1		cal_wk_prd_desc_1
,	cal_wk_qtr_desc_1		cal_wk_qtr_desc_1
,	cal_wk_sea_desc_1		cal_wk_sea_desc_1
,	cal_wk_yr_desc_1		cal_wk_yr_desc_1

,	cal_wk_desc_2			cal_wk_desc_2
,	cal_yr_desc_2			cal_yr_desc_2
,	cal_wk_prd_desc_2		cal_wk_prd_desc_2
,	cal_wk_qtr_desc_2		cal_wk_qtr_desc_2
,	cal_wk_sea_desc_2		cal_wk_sea_desc_2
,	cal_wk_yr_desc_2		cal_wk_yr_desc_2
from	dbo.cal_wk;
