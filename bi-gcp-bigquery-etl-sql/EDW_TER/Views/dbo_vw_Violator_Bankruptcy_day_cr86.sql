CREATE VIEW [dbo].[vw_Violator_Bankruptcy_day_cr86] AS select	f.ViolatorId
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
,	f.Insertdate AS BankruptcyInsertdate
,	f.LastUpdatedate AS BankruptcyLastUpdatedate
,	f.ConversionDate
,	f.Discharge_Dismissed_Date
,	f.FilingDate
,	f.DateNotified
,	vs.EligRmdyDate		as cal_day_bgn
,	-1					as TimeID
,	86					as cal_role_id
from	dbo.Violator_Bankruptcy  f
  join	dbo.ViolatorStatus  vs
    on	f.ViolatorID = vs.ViolatorID
    and	f.VidSeq = vs.VidSeq;
