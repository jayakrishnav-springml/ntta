CREATE VIEW [dbo].[vw_BAN_day_x_cr92] AS select	f.BanID
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
,	cx.cal_day_bgn		as cal_day_bgn
,	cx.cal_comp_day_bgn	as cal_comp_day_bgn
,	92					as cal_role_id
from	dbo.BAN  f
  join	dbo.ViolatorStatus  vs
    on	f.ViolatorID = vs.ViolatorID
    and	f.VidSeq = vs.VidSeq
  join	dto.cal_day_x  cx
    on	vs.Ban2ndLetterDate = cx.cal_day_x_bgn;
