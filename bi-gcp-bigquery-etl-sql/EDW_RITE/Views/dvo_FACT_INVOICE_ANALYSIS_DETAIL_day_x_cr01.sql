CREATE VIEW [dvo].[FACT_INVOICE_ANALYSIS_DETAIL_day_x_cr01] AS select	f.PARTITION_DATE
,		f.VIOLATOR_ID
,		f.VIOLATION_ID
,		f.VBI_INVOICE_ID
,		f.ZI_STAGE_ID
,		f.INVOICE_STAGE_ID
,		f.VBI_STATUS  VB_INV_STATUS
,		f.VIOL_STATUS
,		f.VIOL_INVOICE_ID
,		f.VIOL_INV_STATUS
,		f.LAST_POS_ID
,		f.PAYMENT_SOURCE_CODE
,		f.CA_INV_STATUS
,		f.LAST_CA_COMPANY_ID
,		f.LAST_CA_ACCT_ID
,		f.LAST_CITATION_NBR
,		f.CLOSE_OUT_STATUS
,		f.CLOSE_OUT_TYPE
,		f.DPS_INV_STATUS
,		f.LANE_ID
,		f.VEHICLE_CLASS
,		f.SOURCE_CODE
,		f.DELIVERY_CODE
,		f.INVOICE_AMT
,		f.TOLL_DUE
,		f.ZI_LATE_FEES
,		f.VI_LATE_FEES
,		f.ADMIN_FEE
,		f.ADMIN_FEE2
,		f.AMT_PAID
,		cast(datediff
		(
			day
		,	(
			case
			  when	coalesce(f.CONVERTED_DATE, '1900-01-01') > '1900-01-01' then CONVERTED_DATE
			  when	coalesce(f.VB_INV_DATE, '1900-01-01') > '1900-01-01' then VB_INV_DATE
			  else	null
			end
			)
		,	(
			case
			  when	coalesce(f.LAST_PAID_DATE, '1900-01-01') > '1900-01-01' then LAST_PAID_DATE
			  else	null
			end
			)
		) as bigint)  DAYS_INV_TO_PMT
,		cast(
		case
		  when	coalesce(f.VIOL_INVOICE_ID, -1) = -1 then null
		  when	coalesce(f.CONVERTED_DATE, '1900-01-01') = '1900-01-01'
		   and	coalesce(f.VB_INV_DATE, '1900-01-01') = '1900-01-01' then null
		  when	coalesce(f.LAST_PAID_DATE, '1900-01-01') = '1900-01-01' then null
		  else	1
		end
		as bigint)  INVS_INV_TO_PMT
,		cast(datediff
		(
			day
		,	(
			case
			  when	coalesce(f.VIOL_DATE, '1900-01-01') > '1900-01-01' then VIOL_DATE
			  else	null
			end
			)
		,	(
			case
			  when	coalesce(f.LAST_PAID_DATE, '1900-01-01') > '1900-01-01' then LAST_PAID_DATE
			  else	null
			end
			)
		) as bigint)  DAYS_TXN_TO_PMT
,		cast(
		case
		  when	coalesce(f.VIOL_DATE, '1900-01-01') = '1900-01-01' then null
		  when	coalesce(f.LAST_PAID_DATE, '1900-01-01') = '1900-01-01' then null
		  else	1
		end
		as bigint)  TXNS_TXN_TO_PMT
,		cast(datediff
		(
			day
		,	(
			case
			  when	coalesce(f.CONVERTED_DATE, '1900-01-01') > '1900-01-01' then CONVERTED_DATE
			  when	coalesce(f.VB_INV_DATE, '1900-01-01') > '1900-01-01' then VB_INV_DATE
			  else	null
			end
			)
		,	(
			case
			  when	coalesce(f.PARTITION_DATE, '1900-01-01') > '1900-01-01' then PARTITION_DATE
			  else	null
			end
			)
		) as bigint)  DAYS_INV_TO_PART
,		cast(
		case
		  when	coalesce(f.VIOL_INVOICE_ID, -1) = -1 then null
		  when	coalesce(f.CONVERTED_DATE, '1900-01-01') = '1900-01-01'
		   and	coalesce(f.VB_INV_DATE, '1900-01-01') = '1900-01-01' then null
		  when	coalesce(f.PARTITION_DATE, '1900-01-01') = '1900-01-01' then null
		  else	1
		end
		as bigint)  INVS_INV_TO_PART
,		cast(datediff
		(
			day
		,	(
			case
			  when	coalesce(f.VB_INV_DATE, '1900-01-01') > '1900-01-01' then VB_INV_DATE
			  else	null
			end
			)
		,	(
			case
			  when	coalesce(f.PARTITION_DATE, '1900-01-01') > '1900-01-01' then PARTITION_DATE
			  else	null
			end
			)
		) as bigint)  DAYS_VB_INV_TO_PART
,		cast(
		case
		  when	coalesce(f.VBI_INVOICE_ID, -1) = -1 then null
		  when	coalesce(f.VB_INV_DATE, '1900-01-01') = '1900-01-01' then null
		  when	coalesce(f.PARTITION_DATE, '1900-01-01') = '1900-01-01' then null
		  else	1
		end
		as bigint)  INVS_VB_INV_TO_PART
,		f.CURRENT_INVOICE_LEVEL_FLAG
,		cx.cal_id					as cal_id
,		cx.cal_x_mxm_id				as cal_x_mxm_id
,		cx.cal_x_1x1_id				as cal_x_1x1_id
,		cx.cal_day_bgn				as cal_day_bgn
,		cx.cal_comp_day_bgn			as cal_comp_day_bgn
,		f.VIOL_TIME_ID				as TimeID
,		01							as cal_role_id
from	dbo.FACT_INVOICE_ANALYSIS_DETAIL  f
  join	dbo.cal_day_x  cx
    on	f.VIOL_DATE = cx.cal_day_x_bgn;
