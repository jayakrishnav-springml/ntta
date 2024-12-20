CREATE VIEW [dbo].[vw_Violator_Bankruptcy_day_x_cr81] AS select	f.ViolatorId
,	f.VidSeq
,	f.BankruptcyInstanceNbr
,	f.LastName
,	f.FirstName
,	f.LastName2
,	f.FirstName2
,	f.LicensePlate
,	f.CaseNumber
,	f.PhoneNumber
,	f.LawFirm
,	f.AttorneyName
,	f.ClaimFilled
,	f.FilingStatusId
,	f.InsertByUser AS BankruptcyInsertByUser
,	f.LastUpdateByUser AS BankruptcyLastUpdateByUser
,	f.Assets
,	f.CollectionAccounts
,	f.DischargeDismissedId
,	convert(smallint,1) As BankruptcyFlag
,	convert(smallint,1) As BankruptcyCount
,	f.CollectableAmount
,	f.ExcusedAmount
,	cx.cal_id			as cal_id
,	cx.cal_x_mxm_id		as cal_x_mxm_id
,	cx.cal_x_1x1_id		as cal_x_1x1_id
,	cx.cal_day_bgn		as cal_day_bgn
,	cx.cal_comp_day_bgn	as cal_comp_day_bgn
,	81					as cal_role_id
from	dbo.Violator_Bankruptcy  f
  join	dbo.ViolatorStatus  vs
    on	f.ViolatorID = vs.ViolatorID
    and	f.VidSeq = vs.VidSeq
  join	dto.cal_day_x  cx
    on	vs.BanDate = cx.cal_day_x_bgn;
