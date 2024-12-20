CREATE VIEW [VW_Violator_EVENT] AS select 
		vs.ViolatorID, vs.VidSeq
		, CONVERT(date,HvDate ) AS EventDate 
		, v.AdminCountyLookupID
		, b.ParticipatingCounty
		, 1 As HVActive
		, 0 As HVRemoved
		, 0 AS VrbAcknowledged
		, 0 AS VrbRemoved
		, 0 as VrbRemovalQueued
		, 0 AS BanByProcessServer
		, 0 AS BanByDPS
		, 0 AS BanByUSMail1stBan
	FROM ViolatorStatus vs
	INNER JOIN Violator v ON v.ViolatorID = vs.ViolatorID and v.VidSeq = vs.VidSeq
	INNER JOIN CountyLookup b on v.AdminCountyLookupID = b.CountyLookupID
	where HVFlag = 1 -- for ref supporting criteria and HVexemptflag = 0 and termflag = 0 
	UNION ALL 
	select 
			vs.ViolatorID, vs.VidSeq
		, CASE WHEN HVexemptflag = 1 THEN CONVERT(date,HvExemptDate ) ELSE  CONVERT(date,TermDate) END As EventDate
		, v.AdminCountyLookupID
		, b.ParticipatingCounty
		, 0 As HVActive
		, 1 As HVRemoved
		, 0 AS VrbAcknowledged
		, 0 AS VrbRemoved
		, 0 as VrbRemovalQueued
		, 0 AS BanByProcessServer
		, 0 AS BanByDPS
		, 0 AS BanByUSMail1stBan
	FROM ViolatorStatus vs
	INNER JOIN Violator v ON v.ViolatorID = vs.ViolatorID and v.VidSeq = vs.VidSeq
	INNER JOIN CountyLookup b on v.AdminCountyLookupID = b.CountyLookupID
	where HvExemptDate is not null or TermDate is not null --HVFlag = 0 and (HVexemptflag = 1 or termflag = 1)

	UNION ALL 

	select 
			vs.ViolatorID, vs.VidSeq
		, CONVERT(date,AcknowledgedDate) As EventDate
		, v.AdminCountyLookupID
		, b.ParticipatingCounty
		, 0 As HVActive
		, 0 As HVRemoved
		, 1 AS VrbAcknowledged
		, 0 AS VrbRemoved
		, 0 as VrbRemovalQueued
		, 0 AS BanByProcessServer
		, 0 AS BanByDPS
		, 0 AS BanByUSMail1stBan
	FROM Vrb vs
	INNER JOIN Violator v ON v.ViolatorID = vs.ViolatorID and v.VidSeq = vs.VidSeq
	INNER JOIN CountyLookup b on v.AdminCountyLookupID = b.CountyLookupID
	where AcknowledgedDate is not null and RejectionDate is null and RemovedDate is null and VrbRejectLookupID = 0 and VrbRemovalLookupID = 0 

	UNION ALL 
	select 
			vs.ViolatorID, vs.VidSeq
		, CONVERT(date,RemovedDate) As EventDate
		, v.AdminCountyLookupID
		, b.ParticipatingCounty
		, 0 As HVActive
		, 0 As HVRemoved
		, 0 AS VrbAcknowledged
		, 1 AS VrbRemoved
		, 0 as VrbRemovalQueued
		, 0 AS BanByProcessServer
		, 0 AS BanByDPS
		, 0 AS BanByUSMail1stBan
	FROM Vrb vs
	INNER JOIN Violator v ON v.ViolatorID = vs.ViolatorID and v.VidSeq = vs.VidSeq
	INNER JOIN CountyLookup b on v.AdminCountyLookupID = b.CountyLookupID
	where RemovedDate is not null and VrbStatusLookupID = 6

	UNION ALL 
	select 
			vs.ViolatorID, vs.VidSeq
		, CONVERT(date,RemovedDate) As EventDate
		, v.AdminCountyLookupID
		, b.ParticipatingCounty
		, 0 As HVActive
		, 0 As HVRemoved
		, 0 AS VrbAcknowledged
		, 0 AS VrbRemoved
		, 1 as VrbRemovalQueued
		, 0 AS BanByProcessServer
		, 0 AS BanByDPS
		, 0 AS BanByUSMail1stBan
	FROM Vrb vs
	INNER JOIN Violator v ON v.ViolatorID = vs.ViolatorID and v.VidSeq = vs.VidSeq
	INNER JOIN CountyLookup b on v.AdminCountyLookupID = b.CountyLookupID
	where RemovedDate is not null and VrbStatusLookupID = 6

	UNION ALL

	select 
		vs.ViolatorID, vs.VidSeq
		, CONVERT(date,ActionDate ) AS EventDate 
		, v.AdminCountyLookupID
		, b.ParticipatingCounty
		, 0 As HVActive
		, 0 As HVRemoved
		, 0 AS VrbAcknowledged
		, 0 AS VrbRemoved
		, 0 as VrbRemovalQueued
		, 1 AS BanByProcessServer
		, 0 AS BanByDPS
		, 0 AS BanByUSMail1stBan
	FROM ban vs
	INNER JOIN Violator v ON v.ViolatorID = vs.ViolatorID and v.VidSeq = vs.VidSeq
	INNER JOIN CountyLookup b on v.AdminCountyLookupID = b.CountyLookupID
	where vs.ActiveFlag = 1  and vs.BanActionLookupID = 2 --Ban - PCP

	UNION ALL

	select 
		vs.ViolatorID, vs.VidSeq
		, CONVERT(date,ActionDate ) AS EventDate 
		, v.AdminCountyLookupID
		, b.ParticipatingCounty
		, 0 As HVActive
		, 0 As HVRemoved
		, 0 AS VrbAcknowledged
		, 0 AS VrbRemoved
		, 0 as VrbRemovalQueued
		, 0 AS BanByProcessServer
		, 1 AS BanByDPS
		, 0 AS BanByUSMail1stBan
	FROM ban vs
	INNER JOIN Violator v ON v.ViolatorID = vs.ViolatorID and v.VidSeq = vs.VidSeq
	INNER JOIN CountyLookup b on v.AdminCountyLookupID = b.CountyLookupID
	where vs.ActiveFlag = 1  and vs.BanActionLookupID = 1 --Ban - DPS

	UNION ALL

	select 
		vs.ViolatorID, vs.VidSeq
		, CONVERT(date,BanLetterDate ) AS EventDate 
		, v.AdminCountyLookupID
		, b.ParticipatingCounty
		, 0 As HVActive
		, 0 As HVRemoved
		, 0 AS VrbAcknowledged
		, 0 AS VrbRemoved
		, 0 as VrbRemovalQueued
		, 0 AS BanByProcessServer
		, 0 AS BanByDPS
		, 1 AS BanByUSMail1stBan
	FROM ViolatorStatus vs
	INNER JOIN Violator v ON v.ViolatorID = vs.ViolatorID and v.VidSeq = vs.VidSeq
	INNER JOIN CountyLookup b on v.AdminCountyLookupID = b.CountyLookupID
	where vs.BanLetterFlag = 1;
