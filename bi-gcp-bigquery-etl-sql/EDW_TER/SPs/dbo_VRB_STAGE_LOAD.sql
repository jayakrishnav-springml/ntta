CREATE PROC [dbo].[VRB_STAGE_LOAD] AS

DECLARE @LAST_UPDATE_DATE datetime2(2) 
exec dbo.GetLoadStartDatetime 'DBO.VRB', @LAST_UPDATE_DATE OUTPUT

IF OBJECT_ID('DBO.VRB_STAGE')>0
	DROP Table DBO.VRB_STAGE

CREATE TABLE dbo.VRB_STAGE WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (VrbID)) 
AS 
SELECT 
   VrbID, ViolatorID, VidSeq, ActiveFlag, VrbStatusLookupID
 , AppliedDate, VrbAgencyLookupID
 , ISNULL(SentDate,'1/1/1900') AS SentDate
 , ISNULL(AcknowledgedDate,'1/1/1900') AS AcknowledgedDate
 , ISNULL(RejectionDate,'1/1/1900') AS RejectionDate
 , VrbRejectLookupID
 , ISNULL(RemovedDate,'1/1/1900') AS RemovedDate
 , VrbRemovalLookupID
 , CreatedDate
 , CreatedBy
 , UpdatedDate
 , UpdatedBy
 , LAST_UPDATE_TYPE
 , LAST_UPDATE_DATE
FROM LND_TER.DBO.VRB 
  WHERE LAST_UPDATE_DATE >= @LAST_UPDATE_DATE 
		
  OPTION (LABEL = 'VRB_STAGE_LOAD: VRB_STAGE');

CREATE STATISTICS STATS_VRB_STAGE_LOAD_001 ON DBO.VRB_STAGE (VrbID)

