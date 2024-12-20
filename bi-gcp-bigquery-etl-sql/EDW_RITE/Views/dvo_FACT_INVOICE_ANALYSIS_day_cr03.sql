CREATE VIEW [dvo].[FACT_INVOICE_ANALYSIS_day_cr03] AS select	f.PARTITION_DATE
,		f.VIOLATOR_ID
,		f.VBI_INVOICE_ID
,		f.ZI_STAGE_ID
,		f.INVOICE_STAGE_ID
,		f.VBI_STATUS  VB_INV_STATUS
,		f.VIOL_INVOICE_ID
,		f.VIOL_INV_STATUS
,		f.FIRST_POS_ID
,		f.LAST_POS_ID
,		f.POS_NAME_LIST
,		f.POS_COUNT
,		f.PAYMENT_SOURCE_CODE
,		f.CA_INV_STATUS
,		f.FIRST_CA_COMPANY_ID
,		f.LAST_CA_COMPANY_ID
,		f.CA_COMPANY_NAME_LIST
,		f.CA_COMPANY_COUNT
,		f.FIRST_CITATION_NBR
,		f.LAST_CITATION_NBR
,		f.CITATION_NBR_LIST
,		f.CITATION_NBR_COUNT
,		f.FIRST_CA_ACCT_ID
,		f.LAST_CA_ACCT_ID
,		f.CA_ACCT_ID_LIST
,		f.CA_ACCT_ID_COUNT
,		f.CLOSE_OUT_STATUS
,		f.CLOSE_OUT_TYPE
,		f.DPS_INV_STATUS
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
,		f.DATE_BATCH_PRODUCED
,		f.VB_INV_DATE
,		f.CONVERTED_DATE
,		f.FIRST_PAID_DATE
,		f.LAST_PAID_DATE
,		f.PAID_DATE_LIST
,		f.PAID_DATE_COUNT
,		f.FIRST_CA_FILE_GEN_DATE
,		f.LAST_CA_FILE_GEN_DATE
,		f.CA_FILE_GEN_DATE_LIST
,		f.CA_FILE_GEN_DATE_COUNT
,		f.COURT_ACTION_MAIL_DATE
,		f.CLOSE_OUT_ELIGIBILITY_DATE
,		f.CLOSE_OUT_DATE
,		f.[3NNP_INV_DATE]
,		f.VB_INV_DATE				as cal_day_bgn
,		-1							as TimeID
,		03							as cal_role_id
from	dbo.FACT_INVOICE_ANALYSIS  f;
