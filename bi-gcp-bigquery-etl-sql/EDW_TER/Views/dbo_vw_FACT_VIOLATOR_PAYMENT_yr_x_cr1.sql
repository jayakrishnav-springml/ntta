CREATE VIEW [dbo].[vw_FACT_VIOLATOR_PAYMENT_yr_x_cr1] AS select	f.ViolatorID		as ViolatorID
,	f.VidSeq		as VidSeq
,	f.PAYMENT_TXN_ID	as PaymentTransactionID
,	f.LicensePlateID	as ViolatorLicensePlateID
,	f.CARD_CODE		as PaymentCreditCardCode
,	f.PAYMENT_SOURCE_CODE	as PaymentSourceCodeID
,	f.VIOL_PAY_TYPE		as ViolatorPayTypeID
,	f.PMT_TXN_TYPE		as PaymentTransactionTypeID
,	f.RETAIL_TRANS_ID	as RetailTransactionID
,	f.TRANS_AMT		as PaymentTransactionAmount
,	f.CREATED_BY		as PaymentCreatedBy
,	f.POS_NAME		as PointOfSaleName
,	cx.cal_id		as cal_id
,	cx.cal_x_mxm_id		as cal_x_mxm_id
,	cx.cal_x_1x1_id		as cal_x_1x1_id
,	cx.cal_yr_bgn		as cal_yr_bgn
,	cx.cal_comp_yr_bgn	as cal_comp_yr_bgn
,	1			as cal_role_id
from	dbo.FACT_VIOLATOR_PAYMENT  f
  join	dbo.Violator  v
    on	f.ViolatorID = v.ViolatorID
    and	f.VidSeq = v.VidSeq
  join	dto.cal_day  d
    on	v.EarliestHvTranDate = d.cal_day_bgn
  join	dto.cal_yr_x  cx
    on	d.cal_yr_bgn = cx.cal_yr_x_bgn
    and	d.cal_id = cx.cal_id;
