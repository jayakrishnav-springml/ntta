CREATE PROC [dbo].[ViolatorCallLog_Stage_Load] AS 

DECLARE @LAST_UPDATE_DATE datetime2(2) 
exec dbo.GetLoadStartDatetime 'DBO.ViolatorCallLog', @LAST_UPDATE_DATE OUTPUT

IF OBJECT_ID('dbo.ViolatorCallLog_Stage')>0
	DROP Table dbo.ViolatorCallLog_Stage

CREATE TABLE dbo.ViolatorCallLog_Stage WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (ViolatorCallLogID)) 
AS 
SELECT 
	  ViolatorCallLogID
	, ViolatorID
	, VidSeq
	, ViolatorCallLogLookupID
	, OutgoingCallFlag
	, PhoneNbr
	, ConnectedFlag
	, CreatedDate, CreatedBy, UpdatedDate, UpdatedBy
	, LAST_UPDATE_TYPE
	, LAST_UPDATE_DATE
FROM LND_TER.DBO.ViolatorCallLog
WHERE LAST_UPDATE_DATE >= @LAST_UPDATE_DATE 
	
OPTION (LABEL = 'ViolatorCallLog_Stage_Load: ViolatorCallLog_Stage');

CREATE STATISTICS STATS_ViolatorCallLog_Stage_Load_001 ON DBO.ViolatorCallLog_Stage (ViolatorCallLogID)


