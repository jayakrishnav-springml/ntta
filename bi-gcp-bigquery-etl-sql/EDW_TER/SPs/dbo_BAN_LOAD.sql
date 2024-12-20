CREATE PROC [dbo].[BAN_LOAD] AS

UPDATE dbo.BAN 
	SET 
		  dbo.Ban.BanID = B.BanID
		, dbo.Ban.ViolatorID = B.ViolatorID
		, dbo.Ban.VidSeq = B.VidSeq
		, dbo.Ban.ActiveFlag = B.ActiveFlag
		, dbo.Ban.BanActionLookupID = B.BanActionLookupID
		, dbo.Ban.ActionDate = B.ActionDate
		, dbo.Ban.BanStartDate = B.BanStartDate
		, dbo.Ban.BanLocationLookupID = B.BanLocationLookupID
		, dbo.Ban.BanOfficerLookupID = B.BanOfficerLookupID
		, dbo.Ban.BanImpoundServiceLookupID = B.BanImpoundServiceLookupID
		, dbo.Ban.LAST_UPDATE_DATE = B.BAN_LAST_UPDATE_DATE
		, dbo.Ban.CreatedDate = B.CreatedDate
		, dbo.Ban.CreatedBy = B.CreatedBy
		, dbo.Ban.UpdatedDate = B.UpdatedDate
		, dbo.Ban.UpdatedBy = B.UpdatedBy
FROM dbo.BAN_STAGE B
WHERE 
	dbo.Ban.BanID = B.BanID --AND B.BAN_LAST_UPDATE_TYPE = 'U'
	--AND 

	--(
	--		dbo.Ban.BanID <> B.BanID
	--	OR dbo.Ban.ViolatorID <> B.ViolatorID
	--	OR dbo.Ban.VidSeq <> B.VidSeq
	--	OR dbo.Ban.ActiveFlag <> B.ActiveFlag
	--	OR dbo.Ban.BanActionLookupID <> B.BanActionLookupID
	--	--OR dbo.Ban.ActionDate <> B.ActionDate
	--	OR dbo.Ban.BanStartDate <> B.BanStartDate
	--	OR dbo.Ban.BanLocationLookupID <> B.BanLocationLookupID
	--	OR dbo.Ban.BanOfficerLookupID <> B.BanOfficerLookupID
	--	OR dbo.Ban.BanImpoundServiceLookupID <> B.BanImpoundServiceLookupID
	--	OR dbo.Ban.LAST_UPDATE_DATE <> B.BAN_LAST_UPDATE_DATE
	--	OR dbo.Ban.CreatedDate <> B.CreatedDate
	--	OR dbo.Ban.CreatedBy <> B.CreatedBy
	--	OR ISNULL(dbo.Ban.UpdatedDate,'1/1/1900') <> ISNULL(B.UpdatedDate,'1/1/1900')
	--	OR dbo.Ban.UpdatedBy <> B.UpdatedBy	
	--)

INSERT INTO DBO.BAN
	(
		  BanID
		, ViolatorID
		, VidSeq
		, ActiveFlag
		, BanActionLookupID
		, ActionDate
		, BanStartDate
		, BanLocationLookupID
		, BanOfficerLookupID
		, BanImpoundServiceLookupID
		, INSERT_DATE
		, LAST_UPDATE_DATE
		, CreatedDate
		, CreatedBy
		, UpdatedDate
		, UpdatedBy
	)
-- EXPLAIN
SELECT 
		A.BanID, 
		A.ViolatorID, 
		A.VidSeq, 
		A.ActiveFlag, 
		A.BanActionLookupID, 
		A.ActionDate, 
		A.BanStartDate,
        A.BanLocationLookupID, 
		A.BanOfficerLookupID, 
		A.BanImpoundServiceLookupID,
		A.BAN_LAST_UPDATE_DATE,
        A.BAN_LAST_UPDATE_DATE,
		A.CreatedDate,
		A.CreatedBy,
		A.UpdatedDate,
		A.UpdatedBy
FROM dbo.BAN_STAGE A
LEFT JOIN DBO.BAN B ON A.BanID = B.BanID
WHERE 
	B.BanID IS NULL --AND BAN_LAST_UPDATE_TYPE = 'I'
