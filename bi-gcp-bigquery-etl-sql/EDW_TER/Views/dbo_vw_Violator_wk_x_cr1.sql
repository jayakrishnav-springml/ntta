CREATE VIEW [dbo].[vw_Violator_wk_x_cr1] AS select	coalesce(v.ViolatorID, vs.ViolatorID, vc.ViolatorID)  as ViolatorID
,	coalesce(v.VidSeq, vs.VidSeq, vc.VidSeq)  as VidSeq
,	v.CURRENT_IND
,	v.HV_NON_HV_IND
,	v.LicPlateNbr
,	v.LicPlateStateLookupID
,	v.VEHICLE_ID
,	v.DocNum
,	v.Vin
,	v.PrimaryViolatorFname
,	v.PrimaryViolatorLname
,	v.SecondaryViolatorFname
,	v.SecondaryViolatorLname
,	v.DriversLicense
,	v.DriversLicenseStateLookupID
,	v.SecondaryDriversLicense
,	v.SecondaryDriversLicenseStateLookupID
,	v.AdminCountyLookupID
,	v.RegistrationCountyLookupID
,	v.RegistrationDateNextMonth
,	v.RegistrationDateNextYear
,	v.ViolatorAgencyLookupID	
,	coalesce(v.ViolatorAddressSourceLookupID, -1) AS ViolatorAddressSourceLookupID 
,	coalesce(v.ViolatorAddressStatusLookupID, -1) AS ViolatorAddressStatusLookupID
,	v.ViolatorAddressActiveFlag
,	v.ViolatorAddressConfirmedFlag
,	v.ViolatorAddress1
,	v.ViolatorAddress2
,	v.ViolatorAddressCity
,	v.ViolatorAddressStateLookupID
,	v.ViolatorAddressZipCode
,	v.ViolatorAddressPlus4
,	v.ViolatorAddressCreatedBy
,	v.ViolatorAddressUpdatedBy
,	coalesce(vs.ViolatorStatusID, -1) as ViolatorStatusID
,	coalesce(vs.ViolatorStatusLookupID, -1) as ViolatorStatusLookupID
,	coalesce(vs.ViolatorStatusTermLookupID, -1) as ViolatorStatusTermLookupID
,	coalesce(vs.ViolatorStatusEligRmdyLookupID, -1) as ViolatorStatusEligRmdyLookupID
,	coalesce(vs.ViolatorStatusLetterDeterminationLookupID, -1) as ViolatorStatusLetterDeterminationLookupID
,	coalesce(vs.ViolatorStatusLetterBanLookupID, -1) as ViolatorStatusLetterBanLookupID
,	coalesce(vs.ViolatorStatusLetterTermLookupID, -1) as ViolatorStatusLetterTermLookupID
,	coalesce(vs.ViolatorStatusLetterBan2ndLookupID, -1) as ViolatorStatusLetterBan2ndLookupID
,	coalesce(vs.ViolatorStatusLetterVrbLookupID, -1) as ViolatorStatusLetterVrbLookupID
,	vs.BanByProcessServer
,	vs.BanByDPS
,	vs.BanByUSMail1stBan 
,	vs.ACCT_ID
,	vs.ACCT_STATUS_CODE
,	vs.BanFlag
,	vs.BanCiteWarnFlag
,	vs.BanImpoundFlag
,	vs.BankruptcyInd
,	vs.BanLetterFlag
,	vs.DefaultInd
,	vs.DeterminationLetterFlag
,	vs.EligRmdyFlag
,	vs.HAS_TOLL_TAG_ACCOUNT
,	vs.HVActive
,	vs.HvExemptFlag
,	vs.HvFlag
,	vs.HVRemoved
,	vs.TermFlag
,	vs.TermLetterFlag
,	vs.VrbAcknowledged
,	vs.VrbFlag
,	vs.VrbRemoved
,	vs.VrbRemovalQueued
,	vs.Ban2ndLetterFlag
,	vs.VrbLetterFlag
,	vs.AdminFees
,	vs.BALANCE_AMOUNT
,	vs.BalanceDue
,	vs.BanCiteWarnCount
,	vs.CitationFees
,	vs.CollectableAmount
,	vs.Collections
,	vs.DownPayment
,	vs.ExcusedAmount
,	vs.HvQAmountDue
,	vs.HvQTollsDue
,	vs.HvQTransactions
,	vs.HvQFeesDue
,	vs.MonthlyPaymentAmount
,	vs.PaidInFull
,	vs.PMT_TYPE_CODE
,	vs.REBILL_AMT
,	vs.SettlementAmount
,	vs.TollTransactionCount
,	vs.TotalAmountDue
,	vs.TotalAmountDueInitial
,	vs.TotalCitationCount
,	vs.TotalFeesDue
,	vs.TotalTollsDue
,	vs.TotalTransactionsCount
,	vs.TotalTransactionsInitial
,	coalesce(vc.PhoneNbr, '(Null)')  as PhoneNbr
,	coalesce(vc.WorkPhoneNbr, '(Null)')  as WorkPhoneNbr
,	coalesce(vc.OtherPhoneNbr, '(Null)')  as OtherPhoneNbr
,	coalesce(vc.EmailAddress, '(Null)')  as EmailAddress
,	cx.cal_id			as cal_id
,	cx.cal_x_mxm_id		as cal_x_mxm_id
,	cx.cal_x_1x1_id		as cal_x_1x1_id
,	cx.cal_wk_bgn		as cal_wk_bgn
,	cx.cal_comp_wk_bgn	as cal_comp_wk_bgn
,	1					as cal_role_id
from	dbo.Violator  v
  join
		dbo.ViolatorStatus  vs
    on	v.ViolatorID = vs.ViolatorID
    and	v.VidSeq = vs.VidSeq
  join
		dbo.ViolatorContact  vc
    on	coalesce(v.ViolatorID, vs.ViolatorID) = vc.ViolatorID
    and	coalesce(v.VidSeq, vs.VidSeq) = vc.VidSeq
  join	dto.cal_day  d
    on	v.EarliestHvTranDate = d.cal_day_bgn
  join	dto.cal_wk_x  cx
    on	d.cal_wk_bgn = cx.cal_wk_x_bgn
    and	d.cal_id = cx.cal_id;
