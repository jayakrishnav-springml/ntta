CREATE VIEW [dbo].[vw_Violator_PaymentAgreement_prd_x_cr84] AS select	f.ViolatorId
,	f.VidSeq
,	f.InstanceNbr
,	convert(smallint,1)  as PaymentAgreementFlag
,	f.LastName
,	f.FirstName
,	f.PhoneNumber
,	f.LicensePlate
,	f.[State]
,	f.AgentID
,	f.PaymentAgreement_SourceId
,	f.AgreementTypeId
,	f.CheckNumber
,	f.PaidInFull
,	f.[DefaultInd]
,	f.SpanishOnly
,	f.AmnestyAccount
,	f.Tolltag_Acct_Id
,	f.MaintenanceAgencyId
,	f.ViolatorID2 
,	f.ViolatorID3 
,	f.ViolatorID4 
,	f.InsertByUser  as PaymentAgreementInsertByUser
,	f.LastUpdateByUser  as PaymentAgreementLastUpdateByUser

,	1  as PaymentAgreementCount
,	f.SettlementAmount
,	f.DownPayment
,	f.Collections
,	cast(f.RemainingBalanceDue as money)  as RemainingBalanceDue
,	f.AdminFees
,	f.CitationFees
,	f.MonthlyPaymentAmount
,	f.BalanceDue 
,	cx.cal_id			as cal_id
,	cx.cal_x_mxm_id		as cal_x_mxm_id
,	cx.cal_x_1x1_id		as cal_x_1x1_id
,	cx.cal_prd_bgn		as cal_prd_bgn
,	cx.cal_comp_prd_bgn	as cal_comp_prd_bgn
,	84					as cal_role_id
from	dbo.Violator_PaymentAgreement  f
  join	dbo.ViolatorStatus  vs
    on	f.ViolatorID = vs.ViolatorID
    and	f.VidSeq = vs.VidSeq
  join	dto.cal_day  d
    on	vs.BanStartDate = d.cal_day_bgn
  join	dto.cal_prd_x  cx
    on	d.cal_prd_bgn = cx.cal_prd_x_bgn
    and	d.cal_id = cx.cal_id;
