CREATE PROC [dbo].[ViolatorCallLog_Load] AS

UPDATE dbo.ViolatorCallLog  
	SET 
		  dbo.ViolatorCallLog.ViolatorCallLogID = B.ViolatorCallLogID
		, dbo.ViolatorCallLog.ViolatorID = B.ViolatorID
		, dbo.ViolatorCallLog.VidSeq = B.VidSeq
		, dbo.ViolatorCallLog.ViolatorCallLogLookupID = B.ViolatorCallLogLookupID
		, dbo.ViolatorCallLog.OutgoingCallFlag = B.OutgoingCallFlag
		, dbo.ViolatorCallLog.PhoneNbr = B.PhoneNbr
		, dbo.ViolatorCallLog.ConnectedFlag = B.ConnectedFlag
		, dbo.ViolatorCallLog.LAST_UPDATE_DATE = B.LAST_UPDATE_DATE
		, dbo.ViolatorCallLog.CreatedDate = B.CreatedDate
		, dbo.ViolatorCallLog.CreatedBy = B.CreatedBy
		, dbo.ViolatorCallLog.UpdatedDate = B.UpdatedDate
		, dbo.ViolatorCallLog.UpdatedBy = B.UpdatedBy
FROM dbo.ViolatorCallLog_Stage B
WHERE 
	dbo.ViolatorCallLog.ViolatorCallLogID = B.ViolatorCallLogID
	AND 
	LAST_UPDATE_TYPE = 'U'

	
INSERT INTO dbo.ViolatorCallLog 
	(
		  ViolatorCallLogID
		, ViolatorID
		, VidSeq
		, ViolatorCallLogLookupID
		, OutgoingCallFlag
		, PhoneNbr
		, ConnectedFlag
		, INSERT_DATE
		, LAST_UPDATE_DATE
		, CreatedDate
		, CreatedBy
		, UpdatedDate
		, UpdatedBy

	)
SELECT 
	  A.ViolatorCallLogID
	, A.ViolatorID
	, A.VidSeq
	, A.ViolatorCallLogLookupID
	, A.OutgoingCallFlag
	, A.PhoneNbr
	, A.ConnectedFlag
	, A.LAST_UPDATE_DATE
	, A.LAST_UPDATE_DATE
	, A.CreatedDate
	, A.CreatedBy
	, A.UpdatedDate
	, A.UpdatedBy

		
FROM dbo.ViolatorCallLog_Stage A
LEFT JOIN DBO.ViolatorCallLog B ON A.ViolatorCallLogID = B.ViolatorCallLogID
WHERE 
	B.ViolatorCallLogID IS NULL
	AND 
	A.LAST_UPDATE_TYPE = 'I'

	UPDATE STATISTICS [dbo].ViolatorCallLog WITH FULLSCAN


	
IF OBJECT_ID('dbo.ViolatorCallLog_Stage')>0
	DROP Table dbo.ViolatorCallLog_Stage


