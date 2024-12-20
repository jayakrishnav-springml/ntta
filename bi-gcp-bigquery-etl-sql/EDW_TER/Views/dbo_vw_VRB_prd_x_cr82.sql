CREATE VIEW [dbo].[vw_VRB_prd_x_cr82] AS select	f.VrbID
,	f.ViolatorID
,	f.VidSeq
,	f.VrbStatusLookupID
,	f.VrbAgencyLookupID
,	f.VrbRejectLookupID
,	f.VrbRemovalLookupID
,	f.CreatedBy
,	f.UpdatedBy
,	f.ActiveFlag
,	Convert(smallint, 1) AS VrbFlag 
,	1 AS VrbCount
,	cx.cal_id			as cal_id
,	cx.cal_x_mxm_id		as cal_x_mxm_id
,	cx.cal_x_1x1_id		as cal_x_1x1_id
,	cx.cal_prd_bgn		as cal_prd_bgn
,	cx.cal_comp_prd_bgn	as cal_comp_prd_bgn
,	82					as cal_role_id
from	dbo.VRB  f
  join	dbo.ViolatorStatus  vs
    on	f.ViolatorID = vs.ViolatorID
    and	f.VidSeq = vs.VidSeq
  join	dto.cal_day  d
    on	vs.BanImpoundDate = d.cal_day_bgn
  join	dto.cal_prd_x  cx
    on	d.cal_prd_bgn = cx.cal_prd_x_bgn
    and	d.cal_id = cx.cal_id;
