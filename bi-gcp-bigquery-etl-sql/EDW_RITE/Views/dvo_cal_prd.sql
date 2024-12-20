CREATE VIEW [dvo].[cal_prd] AS select	cal_id				cal_id
,	cal_prd_bgn				cal_prd_bgn
,	cal_prd_end				cal_prd_end
,	cal_prd_ix				cal_prd_ix
,	cal_prd_qtr_bgn			cal_prd_qtr_bgn
,	cal_prd_sea_bgn			cal_prd_sea_bgn
,	cal_prd_yr_bgn			cal_prd_yr_bgn
,	cal_qtr_bgn				cal_qtr_bgn
,	cal_qtr_end				cal_qtr_end
,	cal_qtr_ix				cal_qtr_ix
,	cal_qtr_sea_bgn			cal_qtr_sea_bgn
,	cal_qtr_yr_bgn			cal_qtr_yr_bgn
,	cal_sea_bgn				cal_sea_bgn
,	cal_sea_end				cal_sea_end
,	cal_sea_ix				cal_sea_ix
,	cal_sea_yr_bgn			cal_sea_yr_bgn
,	cal_yr_bgn				cal_yr_bgn
,	cal_yr_end				cal_yr_end
,	cal_yr_ix				cal_yr_ix
,	cal_yr_leap				cal_yr_leap

,	cal_prds_qtr			cal_prds_qtr
,	cal_prd_qtr				cal_prd_qtr
,	cal_prds_sea			cal_prds_sea
,	cal_prd_sea				cal_prd_sea
,	cal_prds_yr				cal_prds_yr
,	cal_prd_yr				cal_prd_yr
,	cal_qtrs_sea			cal_qtrs_sea
,	cal_qtr_sea				cal_qtr_sea
,	cal_qtrs_yr				cal_qtrs_yr
,	cal_qtr_yr				cal_qtr_yr
,	cal_seas_yr				cal_seas_yr
,	cal_sea_yr				cal_sea_yr

,	cal_prd_sid				cal_prd_sid
,	cal_qtr_sid				cal_qtr_sid
,	cal_sea_sid				cal_sea_sid
,	cal_yr_sid				cal_yr_sid
,	cal_prd_qtr_sid			cal_prd_qtr_sid
,	cal_prd_sea_sid			cal_prd_sea_sid
,	cal_prd_yr_sid			cal_prd_yr_sid
,	cal_qtr_sea_sid			cal_qtr_sea_sid
,	cal_qtr_yr_sid			cal_qtr_yr_sid
,	cal_sea_yr_sid			cal_sea_yr_sid

,	cal_prd_desc_1			cal_prd_desc_1
,	cal_qtr_desc_1			cal_qtr_desc_1
,	cal_sea_desc_1			cal_sea_desc_1
,	cal_yr_desc_1			cal_yr_desc_1
,	cal_prd_qtr_desc_1		cal_prd_qtr_desc_1
,	cal_prd_sea_desc_1		cal_prd_sea_desc_1
,	cal_prd_yr_desc_1		cal_prd_yr_desc_1
,	cal_qtr_sea_desc_1		cal_qtr_sea_desc_1
,	cal_qtr_yr_desc_1		cal_qtr_yr_desc_1
,	cal_sea_yr_desc_1		cal_sea_yr_desc_1

,	cal_prd_desc_2			cal_prd_desc_2
,	cal_qtr_desc_2			cal_qtr_desc_2
,	cal_sea_desc_2			cal_sea_desc_2
,	cal_yr_desc_2			cal_yr_desc_2
,	cal_prd_qtr_desc_2		cal_prd_qtr_desc_2
,	cal_prd_sea_desc_2		cal_prd_sea_desc_2
,	cal_prd_yr_desc_2		cal_prd_yr_desc_2
,	cal_qtr_sea_desc_2		cal_qtr_sea_desc_2
,	cal_qtr_yr_desc_2		cal_qtr_yr_desc_2
,	cal_sea_yr_desc_2		cal_sea_yr_desc_2
from	dbo.cal_prd;
