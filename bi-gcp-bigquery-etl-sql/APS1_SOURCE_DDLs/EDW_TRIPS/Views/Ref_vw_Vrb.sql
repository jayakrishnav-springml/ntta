CREATE VIEW [Ref].[vw_Vrb] AS SELECT  
		  A.VrbID
		, A.ViolatorID
		, A.VidSeq
		, A.ActiveFlag
		, CASE WHEN A.VrbStatusLookupID NOT IN (1,2,8,11)
					AND NOT EXISTS (SELECT 1 
									  FROM LND_TER.dbo.VrbHistory c 
									 WHERE a.VrbID = c.VrbID AND a.VrbStatusLookupID IN (5,6,10) AND c.VrbStatusLookupID IN (8,11)
									   AND c.VRBHistoryID = (SELECT MAX(VRBHistoryID) FROM LND_TER.dbo.VrbHistory d WHERE d.VrbID = c.VrbID AND d.VrbStatusLookupID NOT IN (5,6,10)))
				THEN 1 ELSE 0
		   END VrbCount
		, Convert(smallint, 1) AS VrbFlag
		, A.VrbStatusLookupID
		, A.AppliedDate
		, A.VrbAgencyLookupID
		, A.SentDate
		, A.AcknowledgedDate
		, A.RejectionDate
		, A.VrbRejectLookupID
		, A.RemovedDate
		, A.VrbRemovalLookupID
		, Cast(A.CreatedDate AS DATE) CreatedDate
		, A.CreatedBy
		, A.UpdatedDate
		, A.UpdatedBy
    FROM EDW_TER.dbo.Vrb A
    INNER JOIN EDW_TER.dbo.Violator b ON a.ViolatorID = b.ViolatorID AND a.VidSeq = b.VidSeq
	UNION ALL 
	 SELECT  
		  0 AS VrbID
		, ViolatorID
		, VidSeq
		, 0 AS ActiveFlag
		, 0 AS VrbCount
		, Convert(smallint, 0) AS VrbFlag 
		, -1 AS VrbStatusLookupID
		, '1/1/1900' AS AppliedDate
		, -1 AS VrbAgencyLookupID
		, '1/1/1900' AS SentDate
		, '1/1/1900'AS AcknowledgedDate
		, '1/1/1900' AS RejectionDate
		, -1 AS VrbRejectLookupID
		, '1/1/1900' AS RemovedDate
		, -1 AS VrbRemovalLookupID
		, null AS CreatedDate
		, null AS CreatedBy
		, null AS UpdatedDate
		, null AS UpdatedBy
	FROM EDW_TER.dbo.Violator a
	WHERE NOT EXISTS (SELECT 1 FROM EDW_TER.dbo.Vrb b WHERE a.ViolatorID = b.ViolatorID and a.VidSeq = b.VidSeq);