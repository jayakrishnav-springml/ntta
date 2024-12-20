CREATE PROC [dbo].[TER_LETTER_ALERTS_BAN_LOAD] AS
BEGIN

	--#1    Shankar Metla    2019-05-16  Created

	DECLARE @SOURCE VARCHAR(50), @LOG_START_DATE DATETIME2 (0), @PROCEDURE_NAME VARCHAR(100), @LOG_MESSAGE VARCHAR(3000), @ROW_COUNT BIGINT, @TABLE_ROW_COUNT BIGINT, @NEW_ROW_COUNT BIGINT, @ALERTS_COUNT BIGINT, @ALERTS_RUN_ID INT
	SELECT  @SOURCE = 'TER_LETTER_ALERTS_BAN', @LOG_START_DATE = SYSDATETIME(), @PROCEDURE_NAME = 'TER_LETTER_ALERTS_BAN_LOAD'

	DECLARE @CURRENT_WEEK_DUE_DATE DATETIME =  CASE WHEN DATEPART(DW,GETDATE()) > 2 THEN DATEADD(SECOND, -1, DATEADD(DAY, 1, DATEADD(WEEK,DATEDIFF(WEEK,0,GETDATE()),0))) ELSE DATEADD(SECOND, -1, DATEADD(DAY, 1, DATEADD(WEEK,DATEDIFF(WEEK,7,GETDATE()),0))) END,
			@HV_DATE_FROM DATETIME = '1/1/2019'
 
	SET @LOG_MESSAGE = @PROCEDURE_NAME + ' started for the current week due date ' + CONVERT(VARCHAR(19),@CURRENT_WEEK_DUE_DATE,121)
	EXEC dbo.LOG_PROCESS @SOURCE, @LOG_START_DATE, @LOG_MESSAGE, NULL

	--::===========================================================================================
	--:: Get HV data for Ban Letters Analysis
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
		SELECT	ViolatorID, VidSeq, MIN(VrbLetterDate) FirstVrbLetterDate, MAX(VrbLetterDate) LastVrbLetterDate, COUNT(DISTINCT VrbLetterDate) VrbLetterCount, MIN(BanLetterDate) BanLetterDate, 
				MIN(CASE WHEN UpdatedBy = 'QuestMark_Send_Ban_XML' THEN UpdatedDate END) BanLetterSendDate, 
				MIN(CASE WHEN UpdatedBy = 'UpdateViolatorStatusPaidInFullInRite' THEN UpdatedDate END) RITE_PaidInFullDate, 
				MIN(CASE WHEN UpdatedBy = 'UpdatePaymentPlanPaidInFull' THEN UpdatedDate END) PP_PaidInFullDate,
				MIN(CASE WHEN UpdatedBy = 'QuestMark_Receive_Determination_XML' THEN UpdatedDate END) QuestMarkDetLetterAckDate,
				MIN(CASE WHEN UpdatedBy = 'UpdateViolatorStatusApplyRemedies3' THEN UpdatedDate END) RejectedVrbBanLetterDate,
				MIN(CASE WHEN UpdatedBy LIKE 'NTTA\%' AND ViolatorStatusLetterBanLookupID = 4 THEN UpdatedDate END) UserCancelDate,
				MIN(CASE WHEN UpdatedBy = 'UpdateViolatorStatusBankruptcy' THEN UpdatedDate END) BankruptcyDate, 
				MIN(CASE WHEN UpdatedBy = 'UpdateViolatorStatusBankruptcyDismissed' THEN UpdatedDate END) BankruptcyDismissedDate,
				MIN(CASE WHEN ViolatorStatusEligRmdyLookupID = 5 THEN UpdatedDate END) AdminHearingDate, 
				MIN(CASE WHEN ViolatorStatusEligRmdyLookupID = 2 THEN UpdatedDate END) ApplyPaymentPlanDate,			
				MIN(CASE WHEN ViolatorStatusLetterBanLookupID = 1 THEN UpdatedDate END) BanLetterQueuedDate,
				MIN(CASE WHEN ViolatorStatusLetterBanLookupID = 4 THEN UpdatedDate END) BanLetterQueueCancelDate 
			
		FROM	(
					SELECT ViolatorID, VidSeq, ViolatorStatusEligRmdyLookupID, ViolatorStatusLetterVrbLookupID, VrbLetterDate, BanLetterFlag, ViolatorStatusLetterBanLookupID, BanLetterDate, ViolatorStatusLetterBan2ndLookupID, UpdatedBy, UpdatedDate FROM LND_TER.dbo.ViolatorStatus WHERE HvDate >= @HV_DATE_FROM 
					UNION
					SELECT ViolatorID, VidSeq, ViolatorStatusEligRmdyLookupID, ViolatorStatusLetterVrbLookupID, VrbLetterDate, BanLetterFlag, ViolatorStatusLetterBanLookupID, BanLetterDate, ViolatorStatusLetterBan2ndLookupID, UpdatedBy, UpdatedDate FROM LND_TER.dbo.ViolatorStatusHistory WHERE HvDate >= @HV_DATE_FROM
				) V
		GROUP BY ViolatorID, VidSeq
	)
	SELECT  
			VS.ViolatorID, 
			VS.VidSeq,
			SL.StateCode LicPlateState, 
			VS.HvDate, 
			VS.DeterminationLetterDate,
			DATEADD(DAY,30, VSC.FirstVrbLetterDate) VrbLtr30daysDate,
			DATEADD(DAY, 40, VS.DeterminationLetterDate) DtrLtr40daysDate,
			DATEADD(SECOND, -1,
				DATEADD(WEEK,
					DATEDIFF(WEEK,0,
								CASE WHEN SL.StateCode = 'TX'
									 THEN COALESCE(DATEADD(DAY,30, VSC.FirstVrbLetterDate), RejectedVrbBanLetterDate)
								ELSE DATEADD(DAY, 40, VS.DeterminationLetterDate) 
								END
							),  CASE WHEN DATENAME(DW,
									 CASE WHEN SL.StateCode = 'TX'
									 	  THEN COALESCE(DATEADD(DAY,30, VSC.FirstVrbLetterDate), RejectedVrbBanLetterDate)
									 ELSE DATEADD(DAY, 40, VS.DeterminationLetterDate) 
									END
									) = 'Monday' THEN 1 ELSE 8 END
				)
			) BanLetterDueMonday, -- Ban letter queued when Dallas VRB is rejected
			DATEADD(SECOND, -1,
				DATEADD(WEEK,
					DATEDIFF(WEEK,0,
									CASE WHEN SL.StateCode = 'TX'
										 THEN CASE WHEN HvDate < VSC.BankruptcyDismissedDate AND VSC.BankruptcyDismissedDate > DATEADD(DAY,30, VSC.FirstVrbLetterDate) THEN VSC.BankruptcyDismissedDate
												   WHEN HvDate < ActiveAgreementDate AND PP.DefaultedDate > DATEADD(DAY,30, VSC.FirstVrbLetterDate) THEN PP.DefaultedDate
												   ELSE COALESCE(DATEADD(DAY,30, VSC.FirstVrbLetterDate), RejectedVrbBanLetterDate) 
											  END 
									ELSE      CASE WHEN HvDate < VSC.BankruptcyDismissedDate AND VSC.BankruptcyDismissedDate > DATEADD(DAY, 40, VS.DeterminationLetterDate) THEN VSC.BankruptcyDismissedDate
												   WHEN HvDate < ActiveAgreementDate AND PP.DefaultedDate > DATEADD(DAY, 40, VS.DeterminationLetterDate) THEN PP.DefaultedDate
												   ELSE DATEADD(DAY, 40, VS.DeterminationLetterDate)
											  END 
									END
							), CASE WHEN DATENAME(DW,
									CASE WHEN SL.StateCode = 'TX'
										 THEN CASE WHEN HvDate < VSC.BankruptcyDismissedDate AND VSC.BankruptcyDismissedDate > DATEADD(DAY,30, VSC.FirstVrbLetterDate) THEN VSC.BankruptcyDismissedDate
												   WHEN HvDate < ActiveAgreementDate AND PP.DefaultedDate > DATEADD(DAY,30, VSC.FirstVrbLetterDate) THEN PP.DefaultedDate
												   ELSE COALESCE(DATEADD(DAY,30, VSC.FirstVrbLetterDate), RejectedVrbBanLetterDate) 
											  END 
									ELSE      CASE WHEN HvDate < VSC.BankruptcyDismissedDate AND VSC.BankruptcyDismissedDate > DATEADD(DAY, 40, VS.DeterminationLetterDate) THEN VSC.BankruptcyDismissedDate
												   WHEN HvDate < ActiveAgreementDate AND PP.DefaultedDate > DATEADD(DAY, 40, VS.DeterminationLetterDate) THEN PP.DefaultedDate
												   ELSE DATEADD(DAY, 40, VS.DeterminationLetterDate)
											  END 
									END
							) = 'Monday' THEN 1 ELSE 8 END
				)
			) BanLetterFinalDueMonday,  
			VSC.BanLetterQueuedDate,
			VSC.BanLetterSendDate,
			VSC.BanLetterQueueCancelDate,
			VSC.BanLetterDate, 
			PP.ActiveAgreementDate,
			PP.DefaultedDate,
			VSC.RejectedVrbBanLetterDate,
			VSC.ApplyPaymentPlanDate,
			VSC.RITE_PaidInFullDate, 
			VSC.PP_PaidInFullDate,
			VS.TermDate, 
			VSC.BankruptcyDate,
			VSC.BankruptcyDismissedDate,
			VSC.AdminHearingDate,
			VSC.UserCancelDate,
			V.CreatedDate ViolatorCreatedDate,
			VSC.QuestMarkDetLetterAckDate,
			LVL.Descr BanLetterStatus,
			VSL.Descr ViolatorStatus,
			EL.Descr ViolatorStatusEligRmdy,
			VS.HvFlag, 
			VS.EligRmdyFlag,
			VS.BanLetterFlag, 
			PPV0.PaymentPlanID NonHvPaymentPlanID,
			PPV.PaymentPlanID,
			pp.PlanStartDate, 
			CASE WHEN PP.DefaultedDate < pp.LastPaymentDate THEN PP.DefaultedDate ELSE pp.LastPaymentDate END PlanEndDate, 
			PPS.Descr PaymentPlanStatus,
			PPV.PaymentPlanCount,
			PP.TotalNoOfMonths 
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
	LEFT JOIN LND_TER.dbo.ViolatorStatusLetterBanLookup  LVL ON LVL.ViolatorStatusLetterBanLookupID = VS.ViolatorStatusLetterBanLookupID 
	LEFT JOIN LND_TER.dbo.StateLookup  SL ON V.LicPlateStateLookupID = SL.StateLookupID
	WHERE	VS.HvDate >= @HV_DATE_FROM
			AND VS.DeterminationLetterFlag = 1
			AND CASE WHEN SL.StateCode = 'TX' 
						 THEN COALESCE(DATEADD(DAY,30, VSC.FirstVrbLetterDate), RejectedVrbBanLetterDate) 
					ELSE DATEADD(DAY, 40, VS.DeterminationLetterDate) 
					END
				<= @CURRENT_WEEK_DUE_DATE

	--:: Get the range of weeks affected by the max letters threshold 
 
	IF OBJECT_ID('tempdb..#Max_Letters') IS NOT NULL DROP TABLE #Max_Letters;
	WITH Max_Letters_CTE AS 
	(
		SELECT LetterDate, MAX(Value) MaxLettersCount, (1 + ROW_NUMBER() OVER(ORDER BY LetterDate) * 7) i 
		  FROM LND_TER.dbo.LetterQuestMarkRequestHeader RH
		  JOIN LND_TER.dbo.BatchProcessConfig BC ON BC.Descr = 'GetLetterViolatorsBan'
		 WHERE RH.LetterType = 'TERLETBAN'   
		   AND RH.LetterCount  >= Value 
		   AND LetterDate > @HV_DATE_FROM
		GROUP BY LetterDate
	)
	SELECT ROW_NUMBER() OVER(ORDER BY MIN(LetterDate)) RangeID, MAX(MaxLettersCount) MaxLettersCount, DATEADD(DAY,-6,MIN(LetterDate)) MaxLetterStartDate, DATEADD(SECOND, -1, DATEADD(DAY, DATEDIFF(DAY, 0, DATEADD(WEEK,1,MAX(LetterDate)))+1, 0)) MaxLetterEndDate, DATEDIFF(WEEK, MIN(LetterDate), DATEADD(WEEK,1,MAX(LetterDate))) + 1 WeeksAffected
	INTO #Max_Letters
	FROM Max_Letters_CTE
	GROUP BY DATEDIFF(DAY,i,LetterDate)

	--::===========================================================================================
	--:: Load BAN Letters status as of current week due date
	--::===========================================================================================
	SELECT @TABLE_ROW_COUNT = COUNT(1) FROM dbo.TER_LETTER_ALERTS_BAN
	IF  OBJECT_ID('dbo.TER_LETTER_ALERTS_BAN_STAGE') IS NOT NULL DROP TABLE dbo.TER_LETTER_ALERTS_BAN_STAGE;	
	CREATE TABLE dbo.TER_LETTER_ALERTS_BAN_STAGE WITH (HEAP, DISTRIBUTION = HASH(ViolatorID)) AS	
	WITH Ban_Letter_Analysis_CTE AS
	(
		SELECT	
				ISNULL((SELECT MAX(AlertsRunID ) + 1 FROM TER_LETTER_ALERTS_BAN),1) AlertsRunID,
				ViolatorID, 
				VidSeq,
				CASE WHEN BanLetterSendDate IS NOT NULL THEN 'Sent ' 
						  + CASE WHEN BanLetterSendDate <= BanLetterFinalDueMonday THEN 'on time' 
								 WHEN BanLetterSendDate > BanLetterFinalDueMonday THEN 'late'  
							END
				ELSE 'Not Sent' 
				END SentStatus,
				CASE WHEN BanLetterSendDate IS NULL THEN -- NOT SENT
						CASE
							WHEN LicPlateState = 'TX' AND VrbLtr30daysDate IS NULL THEN 'OK. No VRB Letter'
							WHEN AdminHearingDate IS NOT NULL THEN 'OK. Admin Hearing'
							WHEN BankruptcyDate IS NOT NULL AND BankruptcyDismissedDate IS NULL THEN 'OK. Bankruptcy' 
							WHEN ActiveAgreementDate > HvDate THEN 'OK. Payment Plan'
							WHEN TermDate IS NOT NULL THEN 'OK. Termination'
							WHEN COALESCE(RITE_PaidInFullDate,PP_PaidInFullDate) IS NOT NULL THEN 'OK. Paid In Full'
							WHEN UserCancelDate IS NOT NULL THEN 'OK. User canceled Ban letter'
							WHEN BanLetterQueueCancelDate BETWEEN ML.MaxLetterStartDate AND ML.MaxLetterEndDate AND BanLetterStatus = 'Q Cancel' THEN 'OK. Q Cancel during max letters limit'
							WHEN BankruptcyDismissedDate BETWEEN HvDate AND BanLetterFinalDueMonday AND COALESCE(RITE_PaidInFullDate,PP_PaidInFullDate) IS NULL AND GETDATE() > BanLetterDueMonday THEN 'Not OK. Bankruptcy Dismissed' -- Bankruptcy Dismissed, Not PIF, Past Letter Due Date
							WHEN ActiveAgreementDate IS NULL AND NonHvPaymentPlanID IS NOT NULL THEN 'OK. Non HV Payment Plan'
							WHEN COALESCE(BanLetterSendDate, BanLetterQueuedDate) BETWEEN ML.MaxLetterStartDate AND ML.MaxLetterEndDate THEN 'Not OK. Hit ' + CONVERT(VARCHAR,MaxLettersCount) + ' max letters limit' -- Applicable to Not Sent cases only when this 5K Max is effective for the current week
							WHEN BanLetterFinalDueMonday < GETDATE() AND ViolatorStatusEligRmdy = 'Determination' THEN 'Not OK. Stuck in Determination Eligibility Remedy status'
							ELSE 'Not OK. Why no Ban letter?'
						END 
				ELSE -- SENT
						CASE
							WHEN BanLetterSendDate <= BanLetterFinalDueMonday
							THEN 'OK. Ban letter sent on time'
							ELSE 'OK. Ban letter sent late' + CASE WHEN BanLetterSendDate BETWEEN MaxLetterStartDate AND ML.MaxLetterEndDate THEN '. Hit ' + CONVERT(VARCHAR,MaxLettersCount) + ' max letters limit' ELSE '' END 
						END   
				END BanLetterAnalysis,
				CASE WHEN HvDate > COALESCE(DefaultedDate, PlanEndDate) THEN 'PP ended before HV Date' 
					 WHEN ActiveAgreementDate > BanLetterDueMonday THEN 'PP after initial due date' 
					 WHEN ActiveAgreementDate <= BanLetterDueMonday THEN 'PP before initial due date' 
					 WHEN ApplyPaymentPlanDate <= BanLetterDueMonday AND NonHvPaymentPlanID IS NOT NULL THEN 'Non-HV PP before initial due date' 
					 WHEN ApplyPaymentPlanDate >  BanLetterDueMonday AND NonHvPaymentPlanID IS NOT NULL THEN 'Non-HV PP after initial due date' 
				END + CASE WHEN DefaultedDate IS NOT NULL THEN '. Default' ELSE '' END PaymentPlanTiming,
				CASE WHEN COALESCE(RITE_PaidInFullDate,PP_PaidInFullDate,TermDate) <= BanLetterFinalDueMonday THEN 'Paid before due date' WHEN COALESCE(RITE_PaidInFullDate,PP_PaidInFullDate,TermDate) > BanLetterFinalDueMonday THEN 'Paid after due date' END PaymentTiming,
				CASE WHEN BankruptcyDate < BanLetterDueMonday THEN 'Bankruptcy before initial due date' WHEN BankruptcyDate > BanLetterDueMonday THEN 'Bankruptcy after initial due date' END BankruptcyTiming,
				CASE WHEN BanLetterFinalDueMonday BETWEEN ML.MaxLetterStartDate AND ML.MaxLetterEndDate THEN 'Max Letters limit on due date' 
					 WHEN BanLetterQueuedDate BETWEEN ML.MaxLetterStartDate AND ML.MaxLetterEndDate THEN 'Max Letters limit when queued'
					 WHEN BanLetterSendDate BETWEEN MaxLetterStartDate AND ML.MaxLetterEndDate THEN 'Max Letters limit when sent'
				END MaxLettersThreshold
		FROM	#HV  
		LEFT JOIN #Max_Letters ML	
				ON	CASE WHEN BanLetterQueuedDate IS NOT NULL AND BanLetterQueueCancelDate IS NOT NULL AND BanLetterSendDate IS NOT NULL THEN BanLetterSendDate /*Canceled first time and sent later*/ ELSE COALESCE(BanLetterQueuedDate,BanLetterSendDate, BanLetterDueMonday) END
					BETWEEN ML.MaxLetterStartDate AND ML.MaxLetterEndDate
	WHERE	BanLetterDueMonday <= @CURRENT_WEEK_DUE_DATE -- Check only Letter Due cases 
	)
	SELECT	
			AlertsRunID,
			CONVERT(DATE,BanLetterDueMonday) BanLetterDueWeek,
			SentStatus,
			CASE WHEN LAC.BanLetterAnalysis LIKE '%Not OK%' THEN 'Alert' ELSE 'OK' END AlertLevel,
			CONVERT(VARCHAR(100),REPLACE(REPLACE(LAC.BanLetterAnalysis,'Not OK. ',''), 'OK. ','')) BanLetterAnalysis,
			CONVERT(VARCHAR(50),PaymentPlanTiming) PaymentPlanTiming,
			CONVERT(VARCHAR(50),PaymentTiming) PaymentTiming,
			CONVERT(VARCHAR(50),BankruptcyTiming) BankruptcyTiming,
			CONVERT(VARCHAR(50),MaxLettersThreshold) MaxLettersThreshold,
			#HV.*, MaxLetterStartDate, ML.MaxLetterEndDate,
			GETDATE() GenerationDate 
	FROM	Ban_Letter_Analysis_CTE LAC
	JOIN	#HV ON LAC.ViolatorID = #HV.ViolatorID AND LAC.VidSeq = #HV.VidSeq
	LEFT JOIN #Max_Letters ML	
			ON	COALESCE(BanLetterSendDate, BanLetterQueuedDate,BanLetterDueMonday) BETWEEN ML.MaxLetterStartDate AND ML.MaxLetterEndDate
	WHERE	NOT (LAC.BanLetterAnalysis LIKE 'OK%' 
				 AND BanLetterDueMonday < @CURRENT_WEEK_DUE_DATE) -- Current Week: All, Prior Weeks: Not Sent.
			OR
				(LAC.BanLetterAnalysis LIKE 'OK%' 
				 AND BanLetterDueMonday < @CURRENT_WEEK_DUE_DATE 
				 AND EXISTS (SELECT 1 
							 FROM	dbo.TER_LETTER_ALERTS_BAN LA 
							 WHERE	LA.ViolatorID = LAC.ViolatorID
									AND LA.VidSeq = LAC.VidSeq
									AND LA.AlertLevel = 'Alert'
									AND LA.SentStatus = 'Not Sent'
									AND LA.AlertsRunID = (SELECT MAX(AlertsRunID) FROM dbo.TER_LETTER_ALERTS_BAN) -- Prior Weeks: Sent (Not Sent Alert in the previous run) 
							)
				)
	UNION ALL
	SELECT * FROM dbo.TER_LETTER_ALERTS_BAN
	
	EXEC	dbo.LAST_ROW_COUNT @ROW_COUNT OUTPUT
	SELECT	@NEW_ROW_COUNT = @ROW_COUNT - @TABLE_ROW_COUNT

	CREATE STATISTICS STATS_TER_LETTER_ALERTS_BAN_01 ON dbo.TER_LETTER_ALERTS_BAN_STAGE (ViolatorID,VidSeq)
	CREATE STATISTICS STATS_TER_LETTER_ALERTS_BAN_02 ON dbo.TER_LETTER_ALERTS_BAN_STAGE (BanLetterDueWeek)
	CREATE STATISTICS STATS_TER_LETTER_ALERTS_BAN_03 ON dbo.TER_LETTER_ALERTS_BAN_STAGE (BanLetterAnalysis)

	IF OBJECT_ID('dbo.TER_LETTER_ALERTS_BAN_OLD')  IS NOT NULL DROP TABLE dbo.TER_LETTER_ALERTS_BAN_OLD;
	IF OBJECT_ID('dbo.TER_LETTER_ALERTS_BAN')  IS NOT NULL RENAME OBJECT::dbo.TER_LETTER_ALERTS_BAN TO TER_LETTER_ALERTS_BAN_OLD;
	RENAME OBJECT::dbo.TER_LETTER_ALERTS_BAN_STAGE TO TER_LETTER_ALERTS_BAN;
	IF OBJECT_ID('dbo.TER_LETTER_ALERTS_BAN_OLD')  IS NOT NULL DROP TABLE dbo.TER_LETTER_ALERTS_BAN_OLD;

	SELECT @ALERTS_RUN_ID = MAX(AlertsRunID) FROM dbo.TER_LETTER_ALERTS_BAN
	SELECT @ALERTS_COUNT = COUNT(1) FROM dbo.TER_LETTER_ALERTS_BAN WHERE AlertLevel = 'Alert' AND CONVERT(DATE,GenerationDate) = CONVERT(DATE,GETDATE()) AND AlertsRunID = (SELECT MAX(AlertsRunID) FROM dbo.TER_LETTER_ALERTS_BAN)
	SET @LOG_MESSAGE = @PROCEDURE_NAME + ' finished Alerts Run ID ' + ISNULL(CONVERT(VARCHAR,@ALERTS_RUN_ID),'?')
					   + '. Monitored Ban Letters for ' + CONVERT(VARCHAR, ISNULL(@NEW_ROW_COUNT,0)) + ' HVs and sent ' + CONVERT(VARCHAR, ISNULL(@ALERTS_COUNT,0)) + ' Alerts for the current week'
	EXEC dbo.LOG_PROCESS @SOURCE, @LOG_START_DATE, @LOG_MESSAGE, @NEW_ROW_COUNT

	/*
	--:: Alerts output.  
	SELECT	BanLetterDueWeek, SentStatus, BanLetterAnalysis, ViolatorID,VidSeq,HvDate,DeterminationLetterDate 
	FROM	dbo.TER_LETTER_ALERTS_BAN
	WHERE	AlertLevel = 'Alert' 
			AND CONVERT(DATE,GenerationDate) = CONVERT(DATE,GETDATE())  
			AND AlertsRunID = (SELECT MAX(AlertsRunID) FROM dbo.TER_LETTER_ALERTS_BAN)
	ORDER BY BanLetterDueWeek DESC, BanLetterAnalysis, HvDate DESC  
	*/

END


/*
--:: Testing
DELETE dbo.TER_LETTER_ALERTS_BAN

EXEC dbo.TER_LETTER_ALERTS_BAN_LOAD
SELECT * FROM dbo.PROCESS_LOG ORDER BY 1 DESC

--:: Alerts output summary  
SELECT	BanLetterDueWeek, SentStatus, AlertLevel, BanLetterAnalysis, COUNT(1) RowsCount, 
		CONVERT(VARCHAR(10),MIN(HvDate),121) HvDateFrom, CONVERT(VARCHAR(10),MAX(HvDate),121) HvDateTo 
FROM	dbo.TER_LETTER_ALERTS_BAN
--WHERE	AlertLevel = 'Alert' AND CONVERT(DATE,GenerationDate) = CONVERT(DATE,GETDATE())  
GROUP BY BanLetterDueWeek, SentStatus, AlertLevel, BanLetterAnalysis
ORDER BY BanLetterDueWeek DESC, RowsCount DESC, BanLetterAnalysis  

SELECT	BanLetterDueWeek, SentStatus, AlertLevel, BanLetterAnalysis, COUNT(1) RowsCount,
		CONVERT(VARCHAR(10),MIN(HvDate),121) HvDateFrom, CONVERT(VARCHAR(10),MAX(HvDate),121) HvDateTo 
FROM	dbo.TER_LETTER_ALERTS_BAN
GROUP BY BanLetterDueWeek, SentStatus, AlertLevel, BanLetterAnalysis
ORDER BY BanLetterDueWeek DESC, RowsCount DESC, BanLetterAnalysis  

SELECT	AlertsRunID, SentStatus, AlertLevel, BanLetterAnalysis, COUNT(1) RowsCount, 
		CONVERT(VARCHAR(10),MIN(BanLetterFinalDueMonday),121) BanLetterFinalDueMondayFrom, CONVERT(VARCHAR(10),MAX(BanLetterFinalDueMonday),121) BanLetterFinalDueMondayTo 
FROM	dbo.TER_LETTER_ALERTS_BAN
GROUP BY AlertsRunID, SentStatus, AlertLevel, BanLetterAnalysis
ORDER BY AlertsRunID desc, RowsCount DESC, BanLetterAnalysis  

SELECT	*
FROM	dbo.TER_LETTER_ALERTS_BAN  
WHERE	BanLetterAnalysis = 'Why no Ban letter?'  
ORDER BY BanLetterFinalDueMonday DESC

SELECT	*
FROM	dbo.TER_LETTER_ALERTS_BAN    
WHERE	ViolatorID = 801772917
ORDER BY AlertsRunID DESC, BanLetterDueMonday DESC

SELECT * 
FROM 
	(
		SELECT	*, ROW_NUMBER() OVER (PARTITION BY SentStatus, AlertLevel, BanLetterAnalysis ORDER BY HvDate DESC) RN
		FROM	dbo.TER_LETTER_ALERTS_BAN
		WHERE	AlertsRunID = (SELECT MAX(AlertsRunID) FROM dbo.TER_LETTER_ALERTS_BAN)
	) T
WHERE RN <= 100
ORDER BY BanLetterAnalysis, T.RN

*/


