CREATE VIEW [dbo].[vw_BAN_wk_x_cr2] AS select	f.BanID
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
,	cx.cal_wk_bgn		as cal_wk_bgn
,	cx.cal_comp_wk_bgn	as cal_comp_wk_bgn
,	2					as cal_role_id
from	dbo.BAN  f
  join	dbo.Violator  v
    on	f.ViolatorID = v.ViolatorID
    and	f.VidSeq = v.VidSeq
  join	dto.cal_day  d
    on	v.LatestHvTranDate = d.cal_day_bgn
  join	dto.cal_wk_x  cx
    on	d.cal_wk_bgn = cx.cal_wk_x_bgn
    and	d.cal_id = cx.cal_id;
