CREATE VIEW [dbo].[vw_Violator_PaymentAgreement_day_cr71] AS select	f.ViolatorId
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
,	f.Insertdate  as PaymentAgreementInsertdate
,	f.LastUpdatedate  as PaymentAgreementLastUpdatedate
,	f.DueDate
,	f.TodaysDate  as PaymentPlanDate
,	f.PaymentPlanDueDate
,	f.DefaultDate

,	f.LastUpdatedate	as cal_day_bgn
,	-1					as TimeID
,	71					as cal_role_id
from	dbo.Violator_PaymentAgreement  f;
