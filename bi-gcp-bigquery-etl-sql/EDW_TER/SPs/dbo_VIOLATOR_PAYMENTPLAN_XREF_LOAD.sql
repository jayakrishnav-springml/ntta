CREATE PROC [DBO].[VIOLATOR_PAYMENTPLAN_XREF_LOAD] AS 


-- Fix Vidseq in paymentplan violator 

IF OBJECT_ID('dbo.Paymentplanviolator_Fixed')>0
	DROP TABLE dbo.Paymentplanviolator_Fixed	;	

-- EXPLAIN 
CREATE TABLE dbo.Paymentplanviolator_Fixed WITH (CLUSTERED COLUMNSTORE INDEX ,DISTRIBUTION = HASH (PaymentPlanID)) 
AS 
SELECT [PaymentPlanID], [ViolatorID], Correct_VIDSEQ as [VidSeq], [PaymentPlanViolatorSeq], [DeletedFlag] 
FROM
(
select PV.PAYMENTPLANID,PV.VIOLATORID,PV.VIDSEQ AS Paymentplanviolator_VIDSEQ,VS.VIDSEQ AS Correct_VIDSEQ,[PaymentPlanViolatorSeq], pv.[DeletedFlag]
from lnd_Ter.dbo.paymentplanviolator PV 
JOIN lnd_Ter.dbo.paymentplan P ON PV.PAYMENTPLANID = P.PAYMENTPLANID
JOIN lnd_Ter.dbo.violatorstatus VS ON PV.VIOLATORID = VS.VIOLATORID
WHERE P.CREATEDDATE BETWEEN HVDATE AND TERMDATE
) q
WHERE Paymentplanviolator_VIDSEQ <> Correct_VIDSEQ 


IF OBJECT_ID('dbo.VIOLATOR_PAYMENTPLAN_XREF_STAGE')>0
	DROP TABLE dbo.VIOLATOR_PAYMENTPLAN_XREF_STAGE		

CREATE TABLE dbo.VIOLATOR_PAYMENTPLAN_XREF_STAGE WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH (Paymentplanid)) 
AS 


SELECT 
pv.[PaymentPlanID], 
pv.[ViolatorID], 
max(case when pc.vidseq is null then pv.[VidSeq] else pc.vidseq end) as VidSeq,
--pc.[VidSeq] as Pc_vidseq, 
--pv.vidseq as pv_vidseq,
max(pv.[PaymentPlanViolatorSeq]) as PaymentPlanViolatorSeq, 
max(cast(pv.[DeletedFlag] as int)) as DeletedFlag,
max(PL.[PaymentPlanStatusLookupID])  AS PaymentPlanStatus
FROM
lnd_ter.dbo.paymentplanviolator pv 
left join Paymentplanviolator_Fixed pc 
on 
pv.[PaymentPlanID]            =  pc.[PaymentPlanID]  and
pv.[ViolatorID]               =  pc.[ViolatorID] and 
pv.[PaymentPlanViolatorSeq]   =  pc.[PaymentPlanViolatorSeq] and
pv.[DeletedFlag]              =  pc.[DeletedFlag]
left join EDW_TER.DBO.DIM_PAYMENTPLAN PL ON PV.PAYMENTPLANID = PL.PAYMENTPLANID 
WHERE PL.DELETEDFLAG=0 AND PL.PAYMENTPLANSTATUSLOOKUPID > 4
GROUP BY
pv.[PaymentPlanID], 
pv.[ViolatorID]


CREATE TABLE dbo.VIOLATOR_PAYMENTPLAN_XREF_FINAL WITH (CLUSTERED COLUMNSTORE INDEX, DISTRIBUTION = HASH (Paymentplanid)) 
AS 
SELECT 
 ISNULL(PaymentPlanID,-1) AS PaymentPlanID
,COALESCE(DV.VIOLATORID,VP.VIOLATORID) AS VIOLATORID	
,COALESCE(DV.VIDSEQ,VP.VIDSEQ) AS VIDSEQ		
,ISNULL(PaymentPlanViolatorSeQ,-1) AS PaymentPlanViolatorSeQ
,ISNULL(DeletedFlag,-1) AS DeletedFlag
,ISNULL(PaymentPlanStatus,-1) AS PaymentPlanStatus

FROM EDW_TER.DBO.DIM_VIOLATOR DV 
FULL JOIN EDW_TER.DBO.VIOLATOR_PAYMENTPLAN_XREF_STAGE VP ON DV.VIOLATORID = VP.VIOLATORID AND DV.VIDSEQ = VP.VIDSEQ


OPTION (LABEL = 'VIOLATOR_PAYMENTPLAN_XREF_FINAL_LOAD: VIOLATOR_PAYMENTPLAN_XREF_FINAL_STAGE');

--STEP #2: Replace OLD table with NEW
IF OBJECT_ID('dbo.VIOLATOR_PAYMENTPLAN_XREF_OLD') > 0
	DROP TABLE dbo.VIOLATOR_PAYMENTPLAN_XREF_OLD;

IF OBJECT_ID('dbo.VIOLATOR_PAYMENTPLAN_XREF') > 0 RENAME OBJECT::dbo.VIOLATOR_PAYMENTPLAN_XREF TO VIOLATOR_PAYMENTPLAN_XREF_OLD;
	RENAME OBJECT::dbo.VIOLATOR_PAYMENTPLAN_XREF_FINAL TO VIOLATOR_PAYMENTPLAN_XREF;

IF OBJECT_ID('dbo.VIOLATOR_PAYMENTPLAN_XREF_OLD') > 0
	DROP TABLE dbo.VIOLATOR_PAYMENTPLAN_XREF_OLD;

IF OBJECT_ID('dbo.Paymentplanviolator_Fixed')> 0
	DROP TABLE dbo.Paymentplanviolator_Fixed	;	

IF OBJECT_ID('dbo.VIOLATOR_PAYMENTPLAN_XREF_STAGE')>0
	DROP TABLE dbo.VIOLATOR_PAYMENTPLAN_XREF_STAGE	

CREATE STATISTICS STAT_VIOLATOR_PAYMENTPLAN_XREF_001 ON DBO.VIOLATOR_PAYMENTPLAN_XREF(Paymentplanid,ViolatorID, VidSeq)

--EXEC [VIOLATOR_PAYMENTPLAN_XREF_LOAD]

--SELECT * fROM [VIOLATOR_PAYMENTPLAN_XREF]
