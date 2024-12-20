CREATE PROC [dbo].[TER_LETTER_ALERTS_VRB_LOAD] AS

BEGIN
	--#1    Shankar Metla    2019-05-16  Created

	DECLARE @SOURCE VARCHAR(50), @LOG_START_DATE DATETIME2 (0), @PROCEDURE_NAME VARCHAR(100), @LOG_MESSAGE VARCHAR(3000), @ROW_COUNT BIGINT, @TABLE_ROW_COUNT BIGINT, @NEW_ROW_COUNT BIGINT, @ALERTS_COUNT BIGINT, @ALERTS_RUN_ID INT
	SELECT  @SOURCE = 'TER_LETTER_ALERTS_VRB', @LOG_START_DATE = SYSDATETIME(), @PROCEDURE_NAME = 'TER_LETTER_ALERTS_VRB_LOAD'

	DECLARE @CURRENT_WEEK_DUE_DATE DATETIME =  CASE WHEN DATEPART(DW,GETDATE()) > 2 THEN DATEADD(SECOND, -1, DATEADD(DAY, 1, DATEADD(WEEK,DATEDIFF(WEEK,0,GETDATE()),0))) ELSE DATEADD(SECOND, -1, DATEADD(DAY, 1, DATEADD(WEEK,DATEDIFF(WEEK,7,GETDATE()),0))) END,
			@HV_DATE_FROM DATETIME = '10/1/2018'
 
	SET @LOG_MESSAGE = @PROCEDURE_NAME + ' started for the current week due date ' + CONVERT(VARCHAR(19),@CURRENT_WEEK_DUE_DATE,121)
	EXEC dbo.LOG_PROCESS @SOURCE, @LOG_START_DATE, @LOG_MESSAGE, NULL

	--::===========================================================================================
	--:: Get HV data for VRB Letters Analysis
	--::===========================================================================================
	IF OBJECT_ID('tempdb..#HV') IS NOT NULL DROP TABLE #HV;
	WITH PP_CTE AS
	(
			SELECT	VIOLATORID, VIDSEQ , MAX(PV.PaymentPlanID) PaymentPlanID, COUNT(1) PaymentPlanCount  
			FROM	LND_TER.DBO.PAYMENTPLANVIOLATOR PV JOIN LND_TER.DBO.PAYMENTPLAN P 
					ON PV.PAYMENTPLANID = P.PAYMENTPLANID   
			WHERE	P.DELETEDFLAG = 0 AND P.PAYMENTPLANStatusLookupID > 4 -- AND VIDSEQ <> 0
			GROUP BY VIOLATORID, VIDSEQ
	)
	,VS_CTE AS
	(
		SELECT	ViolatorID, VidSeq, 
				MIN(CASE WHEN UpdatedBy = 'QuestMark_Send_Vrb_XML' THEN UpdatedDate END) FirstVrbLetterSendDate, 
				MAX(CASE WHEN UpdatedBy = 'QuestMark_Send_Vrb_XML' THEN UpdatedDate END) LastVrbLetterSendDate,
				COUNT(DISTINCT CASE WHEN UpdatedBy = 'QuestMark_Send_Vrb_XML' THEN UpdatedDate END) VrbLetterSendCount,
				MIN(VrbLetterDate) FirstVrbLetterDate, 
				MAX(VrbLetterDate) LastVrbLetterDate, 
				COUNT(DISTINCT VrbLetterDate) VrbLetterCount,
				MIN(CASE WHEN UpdatedBy = 'UpdateViolatorStatusPaidInFullInRite' THEN UpdatedDate END) RITE_PaidInFullDate, 
				MIN(CASE WHEN UpdatedBy = 'UpdatePaymentPlanPaidInFull' THEN UpdatedDate END) PP_PaidInFullDate,
				MIN(CASE WHEN UpdatedBy = 'QuestMark_Receive_Determination_XML' THEN UpdatedDate END) QuestMarkDetLetterAckDate,
				MIN(CASE WHEN UpdatedBy = 'UpdateViolatorStatusLetterVrbQueueExpiring' THEN UpdatedDate END) ExpiringRegVrbQueueDate,
				MIN(CASE WHEN UpdatedBy = 'UpdateVrbResponseDallasInvalid' AND ViolatorStatusLetterVrbLookupID = 4  THEN UpdatedDate END) DallasInvalidResponseDate,
				MIN(CASE WHEN UpdatedBy LIKE 'NTTA\%' AND ViolatorStatusLetterVrbLookupID = 4 THEN UpdatedDate END) UserCancelDate,
				MIN(CASE WHEN UpdatedBy IN ('DmvVrbRequestBlock','DmvVrbBlock') THEN UpdatedDate END) DmvRequestBlockDate, 
				MIN(CASE WHEN UpdatedBy = 'UpdateViolatorStatusBankruptcy' THEN UpdatedDate END) BankruptcyDate, 
				MIN(CASE WHEN UpdatedBy = 'UpdateViolatorStatusBankruptcyDismissed' THEN UpdatedDate END) BankruptcyDismissedDate,
				MIN(CASE WHEN ViolatorStatusEligRmdyLookupID = 5 THEN UpdatedDate END) AdminHearingDate, 
				MIN(CASE WHEN ViolatorStatusEligRmdyLookupID = 2 THEN UpdatedDate END) ApplyPaymentPlanDate,			
				MIN(CASE WHEN ViolatorStatusLetterVrbLookupID = 1 THEN UpdatedDate END) VrbLetterQueuedDate,
				MIN(CASE WHEN ViolatorStatusLetterVrbLookupID = 4 THEN UpdatedDate END) VrbLetterQueueCancelDate,
				MIN(CASE WHEN UpdatedBy LIKE 'Dlog%' AND ViolatorStatusLetterVrbLookupID = 1 THEN UpdatedDate END ) DlogVrbLetterQueuedDate 
			
		FROM	(
					SELECT ViolatorID, VidSeq, ViolatorStatusEligRmdyLookupID, ViolatorStatusLetterVrbLookupID, VrbLetterDate, UpdatedBy, UpdatedDate FROM LND_TER.dbo.ViolatorStatus WHERE HvDate >= @HV_DATE_FROM 
					UNION
					SELECT ViolatorID, VidSeq, ViolatorStatusEligRmdyLookupID, ViolatorStatusLetterVrbLookupID, VrbLetterDate, UpdatedBy, UpdatedDate FROM LND_TER.dbo.ViolatorStatusHistory WHERE HvDate >= @HV_DATE_FROM
				) V
		GROUP BY ViolatorID, VidSeq
	)
	SELECT  
			VS.ViolatorID, 
			VS.VidSeq, 
			SL.StateCode LicPlateState, 
			VS.HvDate, 
			VS.DeterminationLetterDate, 
			DATEADD(DAY, 40, VS.DeterminationLetterDate) DtrLtr40daysDate,
			DATEADD(SECOND, -1,DATEADD(WEEK,DATEDIFF(WEEK,0,DATEADD(DAY, 40, VS.DeterminationLetterDate)), CASE WHEN DATENAME(DW,DATEADD(DAY, 40, VS.DeterminationLetterDate)) = 'Monday' THEN 1 ELSE 8 END)) DtrLtr40daysDueMonday,
			DATEADD(SECOND, -1,DATEADD(WEEK,DATEDIFF(WEEK,0,PP.DefaultedDate), CASE WHEN DATENAME(DW,PP.DefaultedDate) = 'Monday' THEN 1 ELSE 8 END)) DefaultedMonday,
			DATEADD(SECOND, -1,
				DATEADD(WEEK,
					DATEDIFF(WEEK,0,
								CASE WHEN HvDate < VSC.BankruptcyDismissedDate AND VSC.BankruptcyDismissedDate > DATEADD(DAY, 40, VS.DeterminationLetterDate) THEN VSC.BankruptcyDismissedDate
								     WHEN HvDate < ActiveAgreementDate AND PP.DefaultedDate > DATEADD(DAY, 40, VS.DeterminationLetterDate) THEN PP.DefaultedDate
									 ELSE DATEADD(DAY, 40, VS.DeterminationLetterDate)
								END
							), CASE WHEN DATENAME(DW,
									CASE WHEN HvDate < VSC.BankruptcyDismissedDate AND VSC.BankruptcyDismissedDate > DATEADD(DAY, 40, VS.DeterminationLetterDate) THEN VSC.BankruptcyDismissedDate
										 WHEN HvDate < ActiveAgreementDate AND PP.DefaultedDate > DATEADD(DAY, 40, VS.DeterminationLetterDate) THEN PP.DefaultedDate
										 ELSE DATEADD(DAY, 40, VS.DeterminationLetterDate)
									END
									) = 'Monday' THEN 1 ELSE 8 END
				)
			) VrbLetterDueMonday, -- Letter due on Bankruptcy Dismissed Date 
			VSC.FirstVrbLetterSendDate, 
			VSC.FirstVrbLetterDate, 
			PP.ActiveAgreementDate,
			VSC.ApplyPaymentPlanDate,
			PP.DefaultedDate,
			VSC.RITE_PaidInFullDate, 
			VSC.PP_PaidInFullDate,
			VS.TermDate, 
			VSC.BankruptcyDate,
			VSC.BankruptcyDismissedDate,
			VSC.AdminHearingDate,
			VSC.DmvRequestBlockDate,
			VSC.ExpiringRegVrbQueueDate,
			VSC.DallasInvalidResponseDate,
			VSC.DlogVrbLetterQueuedDate,
			VSC.VrbLetterQueuedDate,
			VSC.VrbLetterQueueCancelDate,
			VSC.UserCancelDate,
			V.CreatedDate ViolatorCreatedDate,
			VSC.QuestMarkDetLetterAckDate,
			LVL.Descr VrbLetterStatus,
			VSL.Descr ViolatorStatus,
			EL.Descr ViolatorStatusEligRmdy,
			VS.HvFlag, 
			VS.EligRmdyFlag,
			VS.VrbLetterFlag, 
			PPV0.PaymentPlanID NonHvPaymentPlanID,
			PPV.PaymentPlanID,
			pp.PlanStartDate, 
			CASE WHEN PP.DefaultedDate < pp.LastPaymentDate THEN PP.DefaultedDate ELSE pp.LastPaymentDate END PlanEndDate, 
			PPS.Descr PaymentPlanStatus,
			PPV.PaymentPlanCount,
			PP.TotalNoOfMonths,  
			CASE WHEN VSC.VrbLetterSendCount > 1 THEN VSC.LastVrbLetterSendDate END LastVrbLetterSendDate, VSC.VrbLetterSendCount, CASE WHEN VSC.VrbLetterCount > 1 THEN VSC.LastVrbLetterDate END LastVrbLetterDate, VSC.VrbLetterCount,
			CASE WHEN V.RegistrationCountyLookupID = 57 AND VSC.DmvRequestBlockDate IS NULL THEN 'Dallas' ELSE 'DMV' END Agency,
			V.DocNum
	INTO #HV
	FROM LND_TER.dbo.ViolatorStatus VS
	JOIN LND_TER.dbo.VIOLATOR V ON	VS.VIOLATORID = V.VIOLATORID AND V.VIDSEQ = VS.VIDSEQ
	LEFT JOIN PP_CTE AS PPV ON	PPV.VIOLATORID = VS.VIOLATORID AND PPV.VIDSEQ = VS.VIDSEQ  
	LEFT JOIN PP_CTE AS PPV0 ON	PPV0.VIOLATORID = VS.VIOLATORID AND PPV0.VIDSEQ = 0
	LEFT JOIN VS_CTE VSC ON VS.VIOLATORID = VSC.VIOLATORID AND VSC.VIDSEQ = VS.VIDSEQ
	LEFT JOIN EDW_TER.dbo.DIM_PAYMENTPLAN PP ON PPV.PaymentPlanID = pp.PaymentPlanID AND PP.ActiveAgreementDate >= VS.HVDate
	LEFT JOIN EDW_TER.dbo.Dim_PaymentPlanStatusLookup PPS ON PP.PaymentPlanStatusLookupID = PPS.PaymentPlanStatusLookupID
	LEFT JOIN LND_TER.dbo.ViolatorStatusLookup VSL ON VSL.ViolatorStatusLookupID = VS.ViolatorStatusLookupID
	LEFT JOIN LND_TER.dbo.ViolatorStatusEligRmdyLookup  EL ON EL.ViolatorStatusEligRmdyLookupID = VS.ViolatorStatusEligRmdyLookupID 
	LEFT JOIN LND_TER.dbo.ViolatorStatusLetterVrbLookup  LVL ON LVL.ViolatorStatusLetterVrbLookupID = VS.ViolatorStatusLetterVrbLookupID 
	LEFT JOIN LND_TER.dbo.StateLookup  SL ON V.LicPlateStateLookupID = SL.StateLookupID
	WHERE	VS.HvDate >= @HV_DATE_FROM
			AND VS.DeterminationLetterFlag = 1
			AND V.LicPlateStateLookupID = 56 -- 'TX'
			AND DATEADD(DAY, 40, VS.DeterminationLetterDate) < = @CURRENT_WEEK_DUE_DATE

	--:: Get the range of weeks affected by the max letters threshold 
 
	IF OBJECT_ID('tempdb..#Max_Letters') IS NOT NULL DROP TABLE #Max_Letters;
	WITH Max_Letters_CTE AS 
	(
		SELECT LetterDate, MAX(Value) MaxLettersCount, (1 + ROW_NUMBER() OVER(ORDER BY LetterDate) * 7) i 
		  FROM LND_TER.dbo.LetterQuestMarkRequestHeader RH
		  JOIN LND_TER.dbo.BatchProcessConfig BC ON BC.Descr = 'GetLetterViolatorsVrb'
		 WHERE RH.LetterType = 'VRBLET01A'   
		   AND RH.LetterCount  >= Value 
		   AND LetterDate > @HV_DATE_FROM
		GROUP BY LetterDate
	)
	SELECT ROW_NUMBER() OVER(ORDER BY MIN(LetterDate)) RangeID, MAX(MaxLettersCount) MaxLettersCount, DATEADD(DAY,-6,MIN(LetterDate)) MaxLetterStartDate, DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(WEEK,1,MAX(LetterDate)))+1, 0)) MaxLetterEndDate, DATEDIFF(WEEK, MIN(LetterDate), DATEADD(WEEK,1,MAX(LetterDate))) + 1 WeeksAffected
	INTO #Max_Letters
	FROM Max_Letters_CTE
	GROUP BY DATEDIFF(DAY,i,LetterDate)

	--::===========================================================================================
	--:: Load VRB Letters status as of current week due date
	--::===========================================================================================
	SELECT @TABLE_ROW_COUNT = COUNT(1) FROM dbo.TER_LETTER_ALERTS_VRB
	IF  OBJECT_ID('dbo.TER_LETTER_ALERTS_VRB_STAGE') IS NOT NULL DROP TABLE dbo.TER_LETTER_ALERTS_VRB_STAGE;	
	CREATE TABLE dbo.TER_LETTER_ALERTS_VRB_STAGE WITH (HEAP, DISTRIBUTION = HASH(ViolatorID)) AS	
	WITH VRB_Letter_Analysis_CTE AS
	(
		SELECT	
				ISNULL((SELECT MAX(AlertsRunID ) + 1 FROM TER_LETTER_ALERTS_VRB),1) AlertsRunID,
				ViolatorID, 
				VidSeq,
				CASE WHEN FirstVrbLetterSendDate IS NOT NULL THEN 'Sent ' 
						  + CASE WHEN FirstVrbLetterSendDate <= VrbLetterDueMonday THEN 'on time' 
								 WHEN FirstVrbLetterSendDate > VrbLetterDueMonday THEN 'late'  
							END
				ELSE 'Not Sent' 
				END SentStatus,
				CASE WHEN FirstVrbLetterSendDate IS NULL THEN -- NOT SENT
						CASE
							WHEN DocNum IS NULL THEN 'OK. No Doc Number'
							WHEN DocNum LIKE 'ETAG%' THEN 'OK. ETAG'
							WHEN BankruptcyDate IS NOT NULL AND BankruptcyDismissedDate IS NULL THEN 'OK. Bankruptcy'  
							WHEN ActiveAgreementDate > HvDate THEN 'OK. Payment Plan'
							WHEN TermDate IS NOT NULL THEN 'OK. Termination'
							WHEN TermDate > DtrLtr40daysDueMonday AND DallasInvalidResponseDate IS NULL AND TermDate BETWEEN ML.MaxLetterStartDate AND ML.MaxLetterEndDate THEN 'OK. Termination after 40 days due date during Max 5K letters limit' -- OK. Terminated during max letters limit 
							WHEN COALESCE(RITE_PaidInFullDate,PP_PaidInFullDate) IS NOT NULL THEN 'OK. Paid In Full'
							WHEN DallasInvalidResponseDate IS NOT NULL THEN 'OK. Rejected Dallas VRB canceled letter' 
							WHEN UserCancelDate IS NOT NULL THEN 'OK. User canceled VRB letter'
							WHEN VrbLetterQueueCancelDate BETWEEN ML.MaxLetterStartDate AND ML.MaxLetterEndDate AND VrbLetterStatus = 'Q Cancel' THEN 'OK. Q Cancel during max letters limit'
							WHEN BankruptcyDismissedDate BETWEEN HvDate AND VrbLetterDueMonday AND COALESCE(RITE_PaidInFullDate,PP_PaidInFullDate) IS NULL AND GETDATE() > VrbLetterDueMonday THEN 'Not OK. Bankruptcy Dismissed' -- Bankruptcy Dismissed, Not PIF, Past Letter Due Date
							WHEN ActiveAgreementDate IS NULL AND NonHvPaymentPlanID IS NOT NULL THEN 'OK. Non HV Payment Plan'
							WHEN @CURRENT_WEEK_DUE_DATE BETWEEN ML.MaxLetterStartDate AND ML.MaxLetterEndDate THEN 'Not OK. Hit ' + CONVERT(VARCHAR,MaxLettersCount) + ' max letters limit' -- Applicable to Not Sent cases only when this 5K Max is effective for the current week
							WHEN DtrLtr40daysDueMonday < GETDATE() AND ViolatorStatusEligRmdy = 'Determination' THEN 'Not OK. Stuck in Determination Eligibility Remedy status'
							ELSE 'Not OK. Why no VRB letter?'
						END 
				ELSE -- SENT
						CASE
							WHEN FirstVrbLetterSendDate <= VrbLetterDueMonday
							THEN 'OK. VRB letter sent on time'
							ELSE 'OK. VRB letter sent late' + CASE WHEN FirstVrbLetterSendDate BETWEEN MaxLetterStartDate AND ML.MaxLetterEndDate THEN '. Hit ' + CONVERT(VARCHAR,MaxLettersCount) + ' max letters limit' ELSE '' END 
						END   
				END VrbLetterAnalysis,
				CASE WHEN HvDate > COALESCE(DefaultedDate, PlanEndDate) THEN 'PP ended before HV Date' 
					 WHEN ActiveAgreementDate > DtrLtr40daysDueMonday THEN 'PP after 40 days due date' 
					 WHEN ActiveAgreementDate <= DtrLtr40daysDueMonday THEN 'PP before 40 days due date' 
					 WHEN ApplyPaymentPlanDate <= DtrLtr40daysDueMonday AND NonHvPaymentPlanID IS NOT NULL THEN 'Non-HV PP before 40 days due date' 
					 WHEN ApplyPaymentPlanDate >  DtrLtr40daysDueMonday AND NonHvPaymentPlanID IS NOT NULL THEN 'Non-HV PP after 40 days due date' 
				END + CASE WHEN DefaultedDate IS NOT NULL THEN '. Default' ELSE '' END PaymentPlanTiming,
				CASE WHEN COALESCE(RITE_PaidInFullDate,PP_PaidInFullDate,TermDate) <= VrbLetterDueMonday THEN 'Paid before due date' WHEN COALESCE(RITE_PaidInFullDate,PP_PaidInFullDate,TermDate) > VrbLetterDueMonday THEN 'Paid after due date' END PaymentTiming,
				CASE WHEN BankruptcyDate < DtrLtr40daysDueMonday THEN 'Bankruptcy before 40 days due date' WHEN BankruptcyDate > DtrLtr40daysDueMonday THEN 'Bankruptcy after 40 days due date' END BankruptcyTiming,
				CASE WHEN VrbLetterDueMonday BETWEEN ML.MaxLetterStartDate AND ML.MaxLetterEndDate THEN 'Max letters limit on due date' 
					 WHEN VrbLetterQueuedDate BETWEEN ML.MaxLetterStartDate AND ML.MaxLetterEndDate THEN 'Max letters limit when queued'
					 WHEN FirstVrbLetterSendDate BETWEEN MaxLetterStartDate AND ML.MaxLetterEndDate THEN 'Max letters limit when sent'
				END MaxLettersThreshold,
				CASE WHEN DallasInvalidResponseDate IS NOT NULL THEN 'Y' ELSE 'N' END RejectedVrbFlag,
				CASE WHEN ExpiringRegVrbQueueDate IS NOT NULL THEN 'Y' ELSE 'N' END QueueLetterExpRegFlag  
		FROM	#HV  
		LEFT JOIN #Max_Letters ML	
				ON	CASE WHEN VrbLetterQueuedDate IS NOT NULL AND VrbLetterQueueCancelDate IS NOT NULL AND FirstVrbLetterSendDate IS NOT NULL THEN FirstVrbLetterSendDate /*Canceled first time and sent later*/ ELSE COALESCE(VrbLetterQueuedDate,FirstVrbLetterSendDate, VrbLetterDueMonday) END
					BETWEEN ML.MaxLetterStartDate AND ML.MaxLetterEndDate
	WHERE	VrbLetterDueMonday <= @CURRENT_WEEK_DUE_DATE -- Check only Letter Due cases 
	)
	SELECT	
			AlertsRunID,
			CONVERT(DATE,VrbLetterDueMonday) VrbLetterDueWeek,
			SentStatus,
			CASE WHEN LAC.VrbLetterAnalysis LIKE '%Not OK%' THEN 'Alert' ELSE 'OK' END AlertLevel,
			CONVERT(VARCHAR(100),REPLACE(REPLACE(LAC.VrbLetterAnalysis,'Not OK. ',''), 'OK. ','')) VrbLetterAnalysis,
			CONVERT(VARCHAR(50),PaymentPlanTiming) PaymentPlanTiming,
			CONVERT(VARCHAR(50),PaymentTiming) PaymentTiming,
			CONVERT(VARCHAR(50),BankruptcyTiming) BankruptcyTiming,
			CONVERT(VARCHAR(50),MaxLettersThreshold) MaxLettersThreshold,
			CONVERT(VARCHAR(1),RejectedVrbFlag) RejectedVrbFlag,
			CONVERT(VARCHAR(1),QueueLetterExpRegFlag) QueueLetterExpRegFlag,
			#HV.*, 
			MaxLetterStartDate, 
			MaxLetterEndDate,
			GETDATE() GenerationDate 
	FROM	VRB_Letter_Analysis_CTE LAC
	JOIN	#HV ON LAC.ViolatorID = #HV.ViolatorID AND LAC.VidSeq = #HV.VidSeq
		LEFT JOIN #Max_Letters ML	
				ON	CASE WHEN VrbLetterQueuedDate IS NOT NULL AND VrbLetterQueueCancelDate IS NOT NULL AND FirstVrbLetterSendDate IS NOT NULL THEN FirstVrbLetterSendDate /*Canceled first time and sent later*/ ELSE COALESCE(VrbLetterQueuedDate,FirstVrbLetterSendDate, VrbLetterDueMonday) END
					BETWEEN ML.MaxLetterStartDate AND ML.MaxLetterEndDate
	WHERE	NOT (LAC.VrbLetterAnalysis LIKE 'OK%' 
				 AND VrbLetterDueMonday < @CURRENT_WEEK_DUE_DATE) -- Current Week: All, Prior Weeks: Not Sent.
			OR
				(LAC.VrbLetterAnalysis LIKE 'OK%' 
				 AND VrbLetterDueMonday < @CURRENT_WEEK_DUE_DATE 
				 AND EXISTS (SELECT 1 
							 FROM	dbo.TER_LETTER_ALERTS_VRB LA 
							 WHERE	LA.ViolatorID = LAC.ViolatorID
									AND LA.VidSeq = LAC.VidSeq
									AND LA.AlertLevel = 'Alert'
									AND LA.SentStatus = 'Not Sent'
									AND LA.AlertsRunID = (SELECT MAX(AlertsRunID) FROM dbo.TER_LETTER_ALERTS_VRB) -- Prior Weeks: Sent (Not Sent Alert in the previous run) 
							)
				)
	UNION ALL
	SELECT * FROM dbo.TER_LETTER_ALERTS_VRB
	
	EXEC	dbo.LAST_ROW_COUNT @ROW_COUNT OUTPUT
	SELECT	@NEW_ROW_COUNT = @ROW_COUNT - @TABLE_ROW_COUNT

	CREATE STATISTICS STATS_TER_LETTER_ALERTS_VRB_01 ON dbo.TER_LETTER_ALERTS_VRB_STAGE (ViolatorID,VidSeq)
	CREATE STATISTICS STATS_TER_LETTER_ALERTS_VRB_02 ON dbo.TER_LETTER_ALERTS_VRB_STAGE (VrbLetterDueWeek)
	CREATE STATISTICS STATS_TER_LETTER_ALERTS_VRB_03 ON dbo.TER_LETTER_ALERTS_VRB_STAGE (VrbLetterAnalysis)

	IF OBJECT_ID('dbo.TER_LETTER_ALERTS_VRB_OLD')  IS NOT NULL DROP TABLE dbo.TER_LETTER_ALERTS_VRB_OLD;
	IF OBJECT_ID('dbo.TER_LETTER_ALERTS_VRB')  IS NOT NULL RENAME OBJECT::dbo.TER_LETTER_ALERTS_VRB TO TER_LETTER_ALERTS_VRB_OLD;
	RENAME OBJECT::dbo.TER_LETTER_ALERTS_VRB_STAGE TO TER_LETTER_ALERTS_VRB;
	IF OBJECT_ID('dbo.TER_LETTER_ALERTS_VRB_OLD')  IS NOT NULL DROP TABLE dbo.TER_LETTER_ALERTS_VRB_OLD;
	
	SELECT @ALERTS_RUN_ID = MAX(AlertsRunID) FROM dbo.TER_LETTER_ALERTS_VRB
	SELECT @ALERTS_COUNT = COUNT(1) FROM dbo.TER_LETTER_ALERTS_VRB WHERE AlertLevel = 'Alert' AND CONVERT(DATE,GenerationDate) = CONVERT(DATE,GETDATE()) AND AlertsRunID = (SELECT MAX(AlertsRunID) FROM dbo.TER_LETTER_ALERTS_VRB)
	SET @LOG_MESSAGE = @PROCEDURE_NAME + ' finished Alerts Run ID ' + ISNULL(CONVERT(VARCHAR,@ALERTS_RUN_ID),'?')
					   + '. Monitored VRB Letters for ' + CONVERT(VARCHAR, ISNULL(@NEW_ROW_COUNT,0)) + ' HVs and sent ' + CONVERT(VARCHAR, ISNULL(@ALERTS_COUNT,0)) + ' Alerts for the current week'
	EXEC dbo.LOG_PROCESS @SOURCE, @LOG_START_DATE, @LOG_MESSAGE, @NEW_ROW_COUNT

	/*
	--:: Alerts output.  
	SELECT	VrbLetterDueWeek, SentStatus, VrbLetterAnalysis, ViolatorID,VidSeq,HvDate,DeterminationLetterDate 
	FROM	dbo.TER_LETTER_ALERTS_VRB
	WHERE	AlertLevel = 'Alert' 
			AND CONVERT(DATE,GenerationDate) = CONVERT(DATE,GETDATE()) 
			AND AlertsRunID = (SELECT MAX(AlertsRunID) FROM dbo.TER_LETTER_ALERTS_VRB) 
	ORDER BY VrbLetterDueWeek DESC, VrbLetterAnalysis, HvDate DESC  
	*/

END

/*
--:: Testing

DELETE dbo.TER_LETTER_ALERTS_VRB

EXEC dbo.TER_LETTER_ALERTS_VRB_LOAD
SELECT * FROM dbo.PROCESS_LOG ORDER BY 1 DESC

--:: Alerts output summary  
SELECT	VrbLetterDueWeek, SentStatus, AlertLevel, VrbLetterAnalysis, COUNT(1) RowsCount, 
		CONVERT(VARCHAR(10),MIN(HvDate),121) HvDateFrom, CONVERT(VARCHAR(10),MAX(HvDate),121) HvDateTo 
FROM	dbo.TER_LETTER_ALERTS_VRB
WHERE	AlertLevel = 'Alert' AND CONVERT(DATE,GenerationDate) = CONVERT(DATE,GETDATE())  
GROUP BY VrbLetterDueWeek, SentStatus, AlertLevel, VrbLetterAnalysis
ORDER BY VrbLetterDueWeek DESC, VrbLetterAnalysis  

SELECT	AlertsRunID, VrbLetterDueWeek, SentStatus, AlertLevel, VrbLetterAnalysis, COUNT(1) RowsCount,
		CONVERT(VARCHAR(10),MIN(HvDate),121) HvDateFrom, CONVERT(VARCHAR(10),MAX(HvDate),121) HvDateTo 
FROM	dbo.TER_LETTER_ALERTS_VRB 
GROUP BY AlertsRunID, VrbLetterDueWeek, SentStatus, AlertLevel, VrbLetterAnalysis
ORDER BY AlertsRunID DESC, VrbLetterDueWeek DESC, RowsCount DESC, VrbLetterAnalysis  

SELECT	AlertsRunID, SentStatus, AlertLevel, VrbLetterAnalysis, COUNT(1) RowsCount, 
		CONVERT(VARCHAR(10),MIN(VrbLetterDueMonday),121) VrbLetterDueMondayFrom, CONVERT(VARCHAR(10),MAX(VrbLetterDueMonday),121) VrbLetterDueMondayTo 
FROM	dbo.TER_LETTER_ALERTS_VRB
GROUP BY AlertsRunID, SentStatus, AlertLevel, VrbLetterAnalysis
ORDER BY AlertsRunID desc, RowsCount DESC, VrbLetterAnalysis  

--:: Testing
--INSERT #Max_Letters  
--SELECT 2, 5000, '4/29/2019',@CURRENT_WEEK_DUE_DATE, 3
--UPDATE #HV SET FirstVrbLetterSendDate = NULL WHERE ViolatorID IN (799618255, 797576246, 801719799,794818396)

SELECT	*
FROM	dbo.TER_LETTER_ALERTS_VRB  
WHERE	AlertsRunID = 3
ORDER BY VrbLetterDueWeek DESC

SELECT	*
FROM	dbo.TER_LETTER_ALERTS_VRB  
WHERE	ViolatorID in (794818396,799618255,797576246,801719799) and AlertsRunID = 2
ORDER BY AlertsRunID DESC, VrbLetterDueMonday DESC

SELECT * 
FROM 
	(
		SELECT	*, ROW_NUMBER() OVER (PARTITION BY SentStatus, AlertLevel, VrbLetterAnalysis ORDER BY HvDate DESC) RN
		FROM	dbo.TER_LETTER_ALERTS_VRB
		WHERE	AlertsRunID = (SELECT MAX(AlertsRunID) FROM dbo.TER_LETTER_ALERTS_VRB)
	) T
WHERE RN <= 100
ORDER BY VrbLetterAnalysis, T.RN

*/


