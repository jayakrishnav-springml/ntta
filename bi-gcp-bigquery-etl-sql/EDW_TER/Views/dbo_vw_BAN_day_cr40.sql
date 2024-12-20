CREATE VIEW [dbo].[vw_BAN_day_cr40] AS select	f.BanID
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
,	f.ActionDate
,	f.BanStartDate
,	f.CreatedDate
,	f.UpdatedDate
,	f.ActionDate		as cal_day_bgn
,	-1					as TimeID
,	40					as cal_role_id
from	dbo.BAN  f;
