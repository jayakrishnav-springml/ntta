CREATE PROC [DBO].[FACT_INVOICE_HV_STAGE_LOAD] AS 
		
IF OBJECT_ID('dbo.FACT_INVOICE_HV_STAGE')>0
	DROP TABLE dbo.FACT_INVOICE_HV_STAGE

CREATE TABLE dbo.FACT_INVOICE_HV_STAGE WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (ViolatorId)) 
AS 
SELECT A.ViolatorId, A.HVFlag
FROM edw_ter.dbo.ViolatorStatus A
INNER JOIN 
(
	select ViolatorId, MAX(VidSeq) AS VidSeq--, COUNT(*)
	FROM edw_ter.dbo.ViolatorStatus
	group by ViolatorId
) MaxHV ON A.ViolatorId = MAXHV.ViolatorId AND A.VidSeq = MAXHV.VidSeq

