CREATE VIEW [dbo].[vw_VRB_day_cr112] AS select	f.VrbID
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
,	f.AcknowledgedDate
,	f.RejectionDate
,	f.AppliedDate
,	f.CreatedDate
,	f.RemovedDate
,	f.SentDate
,	f.UpdatedDate
,	f.AcknowledgedDate	as cal_day_bgn
,	-1					as TimeID
,	112					as cal_role_id
from	dbo.VRB  f;
