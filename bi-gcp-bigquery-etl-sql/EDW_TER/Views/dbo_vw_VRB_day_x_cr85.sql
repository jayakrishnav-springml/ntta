CREATE VIEW [dbo].[vw_VRB_day_x_cr85] AS select	f.VrbID
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
,	cx.cal_day_bgn		as cal_day_bgn
,	cx.cal_comp_day_bgn	as cal_comp_day_bgn
,	85					as cal_role_id
from	dbo.VRB  f
  join	dbo.ViolatorStatus  vs
    on	f.ViolatorID = vs.ViolatorID
    and	f.VidSeq = vs.VidSeq
  join	dto.cal_day_x  cx
    on	vs.DeterminationLetterDate = cx.cal_day_x_bgn;
