CREATE VIEW [dbo].[cal_prd_qtr] AS select	cal_id				cal_id
,	cal_prd_qtr_bgn			cal_prd_qtr_bgn
,	cal_prd_qtr_ix			cal_prd_qtr_ix
,	cal_prds_qtr			cal_prds_qtr
,	cal_prd_qtr				cal_prd_qtr
,	cal_prd_qtr_sid			cal_prd_qtr_sid
,	cal_prd_qtr_desc_1		cal_prd_qtr_desc_1
,	cal_prd_qtr_desc_2		cal_prd_qtr_desc_2
from	dto.cal_prd_qtr;
