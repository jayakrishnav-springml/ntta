CREATE VIEW [dbo].[vw_BAN_prd_x_cr80] AS select	f.BanID
,	f.ViolatorID
,	f.VidSeq
,	f.BanActionLookupID
,	f.BanLocationLookupID
,	f.BanOfficerLookupID
,	f.BanImpoundServiceLookupID
,	f.CreatedBy
,	f.UpdatedBy
,	f.ActiveFlag
,	convert(smallint, 1) as BanFlag 
,	1 as BanCount
,	cx.cal_id			as cal_id
,	cx.cal_x_mxm_id		as cal_x_mxm_id
,	cx.cal_x_1x1_id		as cal_x_1x1_id
,	cx.cal_prd_bgn		as cal_prd_bgn
,	cx.cal_comp_prd_bgn	as cal_comp_prd_bgn
,	80					as cal_role_id
from	dbo.BAN  f
  join	dbo.ViolatorStatus  vs
    on	f.ViolatorID = vs.ViolatorID
    and	f.VidSeq = vs.VidSeq
  join	dto.cal_day  d
    on	vs.BanCiteWarnDate = d.cal_day_bgn
  join	dto.cal_prd_x  cx
    on	d.cal_prd_bgn = cx.cal_prd_x_bgn
    and	d.cal_id = cx.cal_id;
