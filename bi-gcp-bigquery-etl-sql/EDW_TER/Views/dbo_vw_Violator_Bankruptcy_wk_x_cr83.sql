CREATE VIEW [dbo].[vw_Violator_Bankruptcy_wk_x_cr83] AS select	f.ViolatorId
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
,	cx.cal_wk_bgn		as cal_wk_bgn
,	cx.cal_comp_wk_bgn	as cal_comp_wk_bgn
,	83					as cal_role_id
from	dbo.Violator_Bankruptcy  f
  join	dbo.ViolatorStatus  vs
    on	f.ViolatorID = vs.ViolatorID
    and	f.VidSeq = vs.VidSeq
  join	dto.cal_day  d
    on	vs.BanLetterDate = d.cal_day_bgn
  join	dto.cal_wk_x  cx
    on	d.cal_wk_bgn = cx.cal_wk_x_bgn
    and	d.cal_id = cx.cal_id;
