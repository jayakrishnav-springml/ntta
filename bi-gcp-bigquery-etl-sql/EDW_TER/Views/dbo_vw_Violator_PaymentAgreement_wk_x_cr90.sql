CREATE VIEW [dbo].[vw_Violator_PaymentAgreement_wk_x_cr90] AS select	f.ViolatorId
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
,	cx.cal_wk_bgn		as cal_wk_bgn
,	cx.cal_comp_wk_bgn	as cal_comp_wk_bgn
,	90					as cal_role_id
from	dbo.Violator_PaymentAgreement  f
  join	dbo.ViolatorStatus  vs
    on	f.ViolatorID = vs.ViolatorID
    and	f.VidSeq = vs.VidSeq
  join	dto.cal_day  d
    on	vs.TermLetterDate = d.cal_day_bgn
  join	dto.cal_wk_x  cx
    on	d.cal_wk_bgn = cx.cal_wk_x_bgn
    and	d.cal_id = cx.cal_id;
