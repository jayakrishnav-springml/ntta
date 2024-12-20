CREATE PROC [dbo].[ViolatorContact_Stage_Load] AS 

DECLARE @LAST_UPDATE_DATE datetime2(2) 
exec dbo.GetLoadStartDatetime 'DBO.ViolatorContact', @LAST_UPDATE_DATE OUTPUT

IF OBJECT_ID('DBO.ViolatorContact_Stage')>0
	DROP Table DBO.ViolatorContact_Stage

CREATE TABLE dbo.ViolatorContact_Stage WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (ViolatorContactID)) 
AS 
SELECT 
	  ViolatorContactID
	, ViolatorID
	, VidSeq
	, PhoneNbr
	, WorkPhoneNbr
	, OtherPhoneNbr
	, EmailAddress
	, LAST_UPDATE_TYPE
	, LAST_UPDATE_DATE
FROM LND_TER.DBO.ViolatorContact
WHERE LAST_UPDATE_DATE >= @LAST_UPDATE_DATE 
	
OPTION (LABEL = 'ViolatorContact_Stage_Load: ViolatorContact_Stage');

CREATE STATISTICS STATS_ViolatorContact_Stage_Load_001 ON DBO.ViolatorContact_Stage (ViolatorContactID)


