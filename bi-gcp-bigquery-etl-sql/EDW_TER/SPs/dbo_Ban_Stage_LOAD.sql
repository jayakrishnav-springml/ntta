CREATE PROC [DBO].[Ban_Stage_LOAD] AS 

DECLARE @LAST_UPDATE_DATE datetime2(2) 
exec dbo.GetLoadStartDatetime 'EDW_TER.DBO.BAN', @LAST_UPDATE_DATE OUTPUT

IF OBJECT_ID('dbo.Ban_Stage')>0
	DROP TABLE dbo.Ban_Stage

CREATE TABLE dbo.Ban_Stage WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (BanID)) 
AS 
SELECT 
   BanID, 
   ViolatorID, 
   VidSeq, 
   ActiveFlag, 
   BanActionLookupID, 
   ActionDate, 
   ISNULL(BanStartDate,'1/1/1900') AS BanStartDate, 
   BanLocationLookupID, 
   BanOfficerLookupID, 
   ISNULL(BanImpoundServiceLookupID,-1) AS BanImpoundServiceLookupID,
   LAST_UPDATE_TYPE AS BAN_LAST_UPDATE_TYPE, 
   LAST_UPDATE_DATE AS BAN_LAST_UPDATE_DATE,
   CreatedDate,
   CreatedBy,
   UpdatedDate,
   UpdatedBy

FROM LND_TER.DBO.BAN 
  WHERE LAST_UPDATE_DATE >= @LAST_UPDATE_DATE 
  OPTION (LABEL = 'Ban_Stage_LOAD: Ban_Stage');

CREATE STATISTICS STATS_Ban_Stage_LOAD_001 ON DBO.Ban_Stage (ViolatorID, VidSeq)


