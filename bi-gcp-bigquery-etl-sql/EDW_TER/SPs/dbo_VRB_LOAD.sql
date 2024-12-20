CREATE PROC [dbo].[VRB_LOAD] AS
	UPDATE dbo.VRB  
		SET 
			 -- dbo.Vrb.VrbID = B.VrbID,
			  dbo.Vrb.ViolatorID = B.ViolatorID
			, dbo.Vrb.VidSeq = B.VidSeq
			, dbo.Vrb.ActiveFlag = B.ActiveFlag
			, dbo.Vrb.VrbStatusLookupID = B.VrbStatusLookupID
			, dbo.Vrb.AppliedDate = B.AppliedDate
			, dbo.Vrb.VrbAgencyLookupID = B.VrbAgencyLookupID
			, dbo.Vrb.SentDate = B.SentDate
			, dbo.Vrb.AcknowledgedDate = B.AcknowledgedDate
			, dbo.Vrb.RejectionDate = B.RejectionDate
			, dbo.Vrb.VrbRejectLookupID = B.VrbRejectLookupID
			, dbo.Vrb.RemovedDate = B.RemovedDate
			, dbo.Vrb.VrbRemovalLookupID = B.VrbRemovalLookupID
			, dbo.Vrb.CreatedDate = B.CreatedDate
			, dbo.Vrb.CreatedBy = B.CreatedBy
			, dbo.Vrb.UpdatedDate = B.UpdatedDate
			, dbo.Vrb.UpdatedBy = B.UpdatedBy
			, dbo.Vrb.LAST_UPDATE_DATE = B.LAST_UPDATE_DATE
	FROM dbo.VRB_STAGE B
	WHERE 
		dbo.VRB.VrbID = B.VrbID
		--AND 
		--LAST_UPDATE_TYPE = 'U'
		--AND 
		--(	  dbo.Vrb.VrbID <> B.VrbID
		--	OR dbo.Vrb.ViolatorID <> B.ViolatorID
		--	OR dbo.Vrb.VidSeq <> B.VidSeq
		--	OR dbo.Vrb.ActiveFlag <> B.ActiveFlag
		--	OR dbo.Vrb.VrbStatusLookupID <> B.VrbStatusLookupID
		--	OR dbo.Vrb.AppliedDate <> B.AppliedDate
		--	OR dbo.Vrb.VrbAgencyLookupID <> B.VrbAgencyLookupID
		--	OR dbo.Vrb.SentDate <> B.SentDate
		--	OR dbo.Vrb.AcknowledgedDate <> B.AcknowledgedDate
		--	OR dbo.Vrb.RejectionDate <> B.RejectionDate
		--	OR dbo.Vrb.VrbRejectLookupID <> B.VrbRejectLookupID
		--	OR dbo.Vrb.RemovedDate <> B.RemovedDate
		--	OR dbo.Vrb.VrbRemovalLookupID <> B.VrbRemovalLookupID
		--	OR dbo.Vrb.CreatedDate <> B.CreatedDate
		--	OR dbo.Vrb.CreatedBy <> B.CreatedBy
		--	OR dbo.Vrb.UpdatedDate <> B.UpdatedDate
		--	OR dbo.Vrb.UpdatedBy <> B.UpdatedBy
		--) 

INSERT INTO dbo.Vrb 
       (        
			VrbID, ViolatorID, VidSeq, ActiveFlag, VrbStatusLookupID
		, AppliedDate, VrbAgencyLookupID, SentDate, AcknowledgedDate
		, RejectionDate, VrbRejectLookupID, RemovedDate, VrbRemovalLookupID
		, CreatedDate, CreatedBy, UpdatedDate, UpdatedBy
		, INSERT_DATE, LAST_UPDATE_DATE
       )
--Explain
SELECT   
          A.VrbID, A.ViolatorID, A.VidSeq, A.ActiveFlag, A.VrbStatusLookupID    
        , A.AppliedDate, A.VrbAgencyLookupID, A.SentDate, A.AcknowledgedDate
        , A.RejectionDate, A.VrbRejectLookupID, A.RemovedDate, A.VrbRemovalLookupID
		, A.CreatedDate, A.CreatedBy, A.UpdatedDate, A.UpdatedBy
        , A.LAST_UPDATE_DATE 
		, A.LAST_UPDATE_DATE--SELECT COUNT(1)
FROM dbo.VRB_Stage A
LEFT JOIN DBO.VRB B ON A.VrbID = B.VrbID
WHERE 
	B.ViolatorID IS NULL AND B.VidSeq IS NULL
	--AND LAST_UPDATE_TYPE = 'I'


--SELECT * 
--FROM dbo.VRB A
--WHERE NOT EXISTS(SELECT * FROM LND_TER.dbo.VRB B WHERE A.VrbID = B.VrbID)

--GetFields 'VRB'
--SELECT * 
--FROM dbo.VRB A
--WHERE NOT EXISTS(SELECT * FROM dbo.Violator B WHERE A.ViolatorID = B.ViolatorID AND A.VidSeq = B.VidSeq)

 


