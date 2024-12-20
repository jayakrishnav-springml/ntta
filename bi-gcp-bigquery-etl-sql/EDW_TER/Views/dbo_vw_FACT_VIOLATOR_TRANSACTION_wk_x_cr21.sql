CREATE VIEW [dbo].[vw_FACT_VIOLATOR_TRANSACTION_wk_x_cr21] AS select	f.ViolatorID	as ViolatorID
,	f.VidSeq			as VidSeq
,	f.TRANSACTION_ID	as TransactionID
,	f.VIOL_OR_TOLL_TRANSACTION
						as ViolationOrTollID
,	f.LANE_ID			as LaneID
,	f.LICENSE_PLATE_ID	as TransactionLicensePlateID
,	f.VIOL_STATUS		as ViolationStatusID
,	f.TRANS_TYPE_ID		as TransactionTypeID
,	f.SOURCE_CODE		as SourceCodeID
,	f.TOLL_DUE			as ViolationTollDue
,	f.TOLL_PAID			as ViolationTollPaid
,	f.ZC_INVOICE_COUNT	as ZipCashInvoiceCount
,	f.VIOL_INVOICE_COUNT
						as ViolationInvoiceCount
,	cx.cal_id			as cal_id
,	cx.cal_x_mxm_id		as cal_x_mxm_id
,	cx.cal_x_1x1_id		as cal_x_1x1_id
,	cx.cal_wk_bgn		as cal_wk_bgn
,	cx.cal_comp_wk_bgn	as cal_comp_wk_bgn
,	21					as cal_role_id
from	dbo.FACT_VIOLATOR_TRANSACTION  f
  join	dto.cal_day  d
    on	f.TRANSACTION_DATE = d.cal_day_bgn
  join	dto.cal_wk_x  cx
    on	d.cal_wk_bgn = cx.cal_wk_x_bgn
    and	d.cal_id = cx.cal_id;
