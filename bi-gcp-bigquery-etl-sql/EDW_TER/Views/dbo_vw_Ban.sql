CREATE VIEW [dbo].[vw_Ban] AS SELECT  
		  BanID
		, A.ViolatorID
		, A.VidSeq
		, ActiveFlag
		, 1 AS BanCount
		, Convert(smallint, 1) AS BanFlag 
		, BanActionLookupID
		, ActionDate
		, BanStartDate
		, BanLocationLookupID
		, BanOfficerLookupID
		, BanImpoundServiceLookupID
		, CreatedDate
		, CreatedBy
		, UpdatedDate
		, UpdatedBy

	FROM dbo.Ban A
	INNER JOIN dbo.Violator B ON A.ViolatorID = B.ViolatorID AND A.VidSeq = B.VidSeq
	UNION ALL 
	SELECT 
		  0
		, ViolatorID
		, VidSeq
		, 0
		, 0 AS BanCount
		, Convert(smallint, 0)  AS BanFlag 
		, -1 AS BanActionLookupID
		, '1/1/1900' AS ActionDate
		, '1/1/1900' AS BanStartDate
		, -1 AS BanLocationLookupID
		, -1 AS BanOfficerLookupID
		, -1 AS BanImpoundServiceLookupID
		, null AS CreatedDate
		, null AS CreatedBy
		, null AS UpdatedDate
		, null AS UpdatedBy
	FROM dbo.Violator a
	WHERE NOT EXISTS (SELECT * FROM dbo.Ban b where a.ViolatorID = b.ViolatorID AND a.VidSeq = b.VidSeq);
