CREATE PROC [dbo].[TER_LETTER_ALERTS_DETERMINATION_LOAD] AS
BEGIN
	--#1    Shankar Metla    2019-05-16  Created

	DECLARE @SOURCE VARCHAR(50), @LOG_START_DATE DATETIME2 (0), @PROCEDURE_NAME VARCHAR(100), @LOG_MESSAGE VARCHAR(3000), @ROW_COUNT BIGINT, @TABLE_ROW_COUNT BIGINT, @NEW_ROW_COUNT BIGINT, @ALERTS_COUNT BIGINT, @ALERTS_RUN_ID INT
	SELECT  @SOURCE = 'TER_LETTER_ALERTS_DETERMINATION', @LOG_START_DATE = SYSDATETIME(), @PROCEDURE_NAME = 'TER_LETTER_ALERTS_DETERMINATION_LOAD'

	DECLARE @CURRENT_WEEK_DUE_DATE DATETIME =  CASE WHEN DATEPART(DW,GETDATE()) > 2 THEN DATEADD(SECOND, -1, DATEADD(DAY, 1, DATEADD(WEEK,DATEDIFF(WEEK,0,GETDATE()),0))) ELSE DATEADD(SECOND, -1, DATEADD(DAY, 1, DATEADD(WEEK,DATEDIFF(WEEK,7,GETDATE()),0))) END,
			@HV_DATE_FROM DATETIME = '1/1/2019'
 
	SET @LOG_MESSAGE = @PROCEDURE_NAME + ' started for the current week due date ' + CONVERT(VARCHAR(19),@CURRENT_WEEK_DUE_DATE,121)
	EXEC dbo.LOG_PROCESS @SOURCE, @LOG_START_DATE, @LOG_MESSAGE, NULL

	--::===========================================================================================
	--:: Get HV data for Determination Letters Analysis
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
				MIN(CASE WHEN ViolatorStatusLetterDeterminationLookupID = 1 THEN CreatedDate END) DeterminationLetterQueuedDate,
				MIN(CASE WHEN ViolatorStatusLetterDeterminationLookupID = 4 THEN UpdatedDate END) DeterminationLetterQueueCancelDate, 
				MIN(CASE WHEN UpdatedBy = 'QuestMark_Send_Determination_XML' THEN UpdatedDate END) DeterminationLetterSendDate, 
				MIN(CASE WHEN UpdatedBy = 'QuestMark_Receive_Determination_XML' THEN UpdatedDate END) QuestMarkDetLetterAckDate, 
				MIN(CASE WHEN UpdatedBy = 'UpdateViolatorStatusPaidInFullInRite' THEN UpdatedDate END) RITE_PaidInFullDate, 
				MIN(CASE WHEN UpdatedBy = 'UpdatePaymentPlanPaidInFull' THEN UpdatedDate END) PP_PaidInFullDate,
				MIN(CASE WHEN UpdatedBy = 'UpdateViolatorStatusBankruptcy' THEN UpdatedDate END) BankruptcyDate, 
				MIN(CASE WHEN UpdatedBy = 'UpdateViolatorStatusBankruptcyDismissed' THEN UpdatedDate END) BankruptcyDismissedDate,
				MIN(CASE WHEN ViolatorStatusEligRmdyLookupID = 5 THEN UpdatedDate END) AdminHearingDate, 
				MIN(CASE WHEN ViolatorStatusEligRmdyLookupID = 2 THEN UpdatedDate END) ApplyPaymentPlanDate,			
				MIN(CASE WHEN UpdatedBy LIKE 'NTTA\%' AND ViolatorStatusLetterDeterminationLookupID = 4 THEN UpdatedDate END) UserCancelDate
			
		FROM	(
					SELECT ViolatorID, VidSeq, ViolatorStatusEligRmdyLookupID, DeterminationLetterFlag, ViolatorStatusLetterDeterminationLookupID, DeterminationLetterDate, CreatedDate, UpdatedBy, UpdatedDate FROM LND_TER.dbo.ViolatorStatus WHERE HvDate >= @HV_DATE_FROM 
					UNION													   
					SELECT ViolatorID, VidSeq, ViolatorStatusEligRmdyLookupID, DeterminationLetterFlag, ViolatorStatusLetterDeterminationLookupID, DeterminationLetterDate, CreatedDate, UpdatedBy, UpdatedDate FROM LND_TER.dbo.ViolatorStatusHistory WHERE HvDate >= @HV_DATE_FROM
				) V
		GROUP BY ViolatorID, VidSeq
	)
	SELECT  
			VS.ViolatorID, 
			VS.VidSeq,
			VS.HvDate, 
			V.CreatedDate ViolatorCreatedDate,
			DATEADD(SECOND, -1,DATEADD(WEEK,DATEDIFF(WEEK,0,V.CreatedDate), CASE WHEN DATENAME(DW,V.CreatedDate) = 'Monday' THEN 1 ELSE 8 END)) DeterminationLetterDueMonday,
			VS.DeterminationLetterDate,
			VSC.DeterminationLetterQueuedDate,
			VSC.DeterminationLetterQueueCancelDate,
			VSC.DeterminationLetterSendDate,
			VSC.QuestMarkDetLetterAckDate,
			VSC.UserCancelDate,
			LVL.Descr DeterminationLetterStatus,
			VSL.Descr ViolatorStatus,
			EL.Descr ViolatorStatusEligRmdy,
			VSC.ApplyPaymentPlanDate,
			PP.ActiveAgreementDate,
			PP.DefaultedDate,
			VSC.RITE_PaidInFullDate, 
			VSC.PP_PaidInFullDate,
			VS.TermDate, 
			VSC.BankruptcyDate,
			VSC.BankruptcyDismissedDate,
			VSC.AdminHearingDate,
			VS.HvFlag, 
			VS.EligRmdyFlag,
			VS.DeterminationLetterFlag, 
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
	LEFT JOIN LND_TER.dbo.ViolatorStatusLetterDeterminationLookup  LVL ON LVL.ViolatorStatusLetterDeterminationLookupID = VS.ViolatorStatusLetterDeterminationLookupID 
	WHERE	VS.HvDate >= @HV_DATE_FROM

	--::===========================================================================================
	--:: Load Determination Letters status as of current week due date
	--::===========================================================================================
	SELECT @TABLE_ROW_COUNT = COUNT(1) FROM dbo.TER_LETTER_ALERTS_DETERMINATION
	
	IF  OBJECT_ID('dbo.TER_LETTER_ALERTS_DETERMINATION_STAGE') IS NOT NULL DROP TABLE dbo.TER_LETTER_ALERTS_DETERMINATION_STAGE;	
	CREATE TABLE dbo.TER_LETTER_ALERTS_DETERMINATION_STAGE WITH (HEAP, DISTRIBUTION = HASH(ViolatorID)) AS	
	WITH Determination_Letter_Analysis_CTE AS
	(
		SELECT	
				ISNULL((SELECT MAX(AlertsRunID ) + 1 FROM dbo.TER_LETTER_ALERTS_DETERMINATION),1) AlertsRunID,
				ViolatorID, 
				VidSeq,
				CASE WHEN DeterminationLetterSendDate IS NOT NULL THEN 'Sent ' 
						  + CASE WHEN DeterminationLetterSendDate <= DeterminationLetterDueMonday THEN 'on time' 
								 WHEN DeterminationLetterSendDate > DeterminationLetterDueMonday THEN 'late'  
							END
				ELSE 'Not Sent' 
				END SentStatus,
				CASE WHEN DeterminationLetterSendDate IS NULL THEN -- NOT SENT
						CASE
							WHEN AdminHearingDate IS NOT NULL THEN 'OK. Admin Hearing'
							WHEN BankruptcyDate IS NOT NULL AND BankruptcyDismissedDate IS NULL THEN 'OK. Bankruptcy' 
							WHEN ActiveAgreementDate > HvDate THEN 'OK. Payment Plan'
							WHEN TermDate IS NOT NULL THEN 'OK. Termination'
							WHEN COALESCE(RITE_PaidInFullDate,PP_PaidInFullDate) IS NOT NULL THEN 'OK. Paid In Full'
							WHEN UserCancelDate IS NOT NULL THEN 'OK. User canceled Determination letter'
							WHEN DeterminationLetterStatus = 'Q Cancel' THEN 'OK. Q Cancel?'
							WHEN BankruptcyDismissedDate BETWEEN HvDate AND DeterminationLetterDueMonday AND COALESCE(RITE_PaidInFullDate,PP_PaidInFullDate) IS NULL AND GETDATE() > DeterminationLetterDueMonday THEN 'Not OK. Bankruptcy Dismissed'
							WHEN ActiveAgreementDate IS NULL AND NonHvPaymentPlanID IS NOT NULL THEN 'OK. Non HV Payment Plan'
						ELSE 'Not OK. Why no Determination letter?'
						END 
				ELSE -- SENT
						CASE
							WHEN DeterminationLetterSendDate <= DeterminationLetterDueMonday
							THEN 'OK. Determination letter sent on time'
							ELSE 'OK. Determination letter sent late' 
						END   
				END DeterminationLetterAnalysis,
				CASE WHEN HvDate > COALESCE(DefaultedDate, PlanEndDate) THEN 'PP ended before HV Date' 
					 WHEN ActiveAgreementDate > DeterminationLetterDueMonday THEN 'PP after due date' 
					 WHEN ActiveAgreementDate <= DeterminationLetterDueMonday THEN 'PP before due date' 
					 WHEN ApplyPaymentPlanDate <= DeterminationLetterDueMonday AND NonHvPaymentPlanID IS NOT NULL THEN 'Non-HV PP before due date' 
					 WHEN ApplyPaymentPlanDate >  DeterminationLetterDueMonday AND NonHvPaymentPlanID IS NOT NULL THEN 'Non-HV PP after due date' 
				END + CASE WHEN DefaultedDate IS NOT NULL THEN '. Default' ELSE '' END PaymentPlanTiming,
				CASE WHEN COALESCE(RITE_PaidInFullDate,PP_PaidInFullDate,TermDate) <= DeterminationLetterDueMonday THEN 'Paid before due date' WHEN COALESCE(RITE_PaidInFullDate,PP_PaidInFullDate,TermDate) > DeterminationLetterDueMonday THEN 'Paid after due date' END PaymentTiming,
				CASE WHEN BankruptcyDate < DeterminationLetterDueMonday THEN 'Bankruptcy before due date' WHEN BankruptcyDate > DeterminationLetterDueMonday THEN 'Bankruptcy after due date' END BankruptcyTiming
		FROM	#HV  
	WHERE	DeterminationLetterDueMonday <= @CURRENT_WEEK_DUE_DATE -- Check only Letter Due cases 
	)
	SELECT	
			AlertsRunID,
			CONVERT(DATE,DeterminationLetterDueMonday) DeterminationLetterDueWeek,
			SentStatus,
			CASE WHEN LAC.DeterminationLetterAnalysis LIKE '%Not OK%' THEN 'Alert' ELSE 'OK' END AlertLevel,
			CONVERT(VARCHAR(100),REPLACE(REPLACE(LAC.DeterminationLetterAnalysis,'Not OK. ',''), 'OK. ','')) DeterminationLetterAnalysis,
			CONVERT(VARCHAR(50),PaymentPlanTiming) PaymentPlanTiming,
			CONVERT(VARCHAR(50),PaymentTiming) PaymentTiming,
			CONVERT(VARCHAR(50),BankruptcyTiming) BankruptcyTiming,
			#HV.*, 
			GETDATE() GenerationDate 
	FROM	Determination_Letter_Analysis_CTE LAC
	JOIN	#HV ON LAC.ViolatorID = #HV.ViolatorID AND LAC.VidSeq = #HV.VidSeq
	WHERE	NOT (LAC.DeterminationLetterAnalysis LIKE 'OK%' 
				 AND DeterminationLetterDueMonday < @CURRENT_WEEK_DUE_DATE) -- Current Week: All, Prior Weeks: Not Sent.
			OR
				(LAC.DeterminationLetterAnalysis LIKE 'OK%' 
				 AND DeterminationLetterDueMonday < @CURRENT_WEEK_DUE_DATE 
				 AND EXISTS (SELECT 1 
							 FROM	dbo.TER_LETTER_ALERTS_DETERMINATION LA 
							 WHERE	LA.ViolatorID = LAC.ViolatorID
									AND LA.VidSeq = LAC.VidSeq
									AND LA.AlertLevel = 'Alert'
									AND LA.SentStatus = 'Not Sent'
									AND LA.AlertsRunID = (SELECT MAX(AlertsRunID) FROM dbo.TER_LETTER_ALERTS_DETERMINATION) -- Prior Weeks: Sent (Not Sent Alert in the previous run) 
							)
				)
	UNION ALL
	SELECT * FROM dbo.TER_LETTER_ALERTS_DETERMINATION
	
	EXEC	dbo.LAST_ROW_COUNT @ROW_COUNT OUTPUT
	SELECT	@NEW_ROW_COUNT = @ROW_COUNT - @TABLE_ROW_COUNT

	CREATE STATISTICS STATS_TER_LETTER_ALERTS_DETERMINATION_01 ON dbo.TER_LETTER_ALERTS_DETERMINATION_STAGE (ViolatorID,VidSeq)
	CREATE STATISTICS STATS_TER_LETTER_ALERTS_DETERMINATION_02 ON dbo.TER_LETTER_ALERTS_DETERMINATION_STAGE (DeterminationLetterDueWeek)
	CREATE STATISTICS STATS_TER_LETTER_ALERTS_DETERMINATION_03 ON dbo.TER_LETTER_ALERTS_DETERMINATION_STAGE (DeterminationLetterAnalysis)

	IF OBJECT_ID('dbo.TER_LETTER_ALERTS_DETERMINATION_OLD')  IS NOT NULL DROP TABLE dbo.TER_LETTER_ALERTS_DETERMINATION_OLD;
	IF OBJECT_ID('dbo.TER_LETTER_ALERTS_DETERMINATION')  IS NOT NULL RENAME OBJECT::dbo.TER_LETTER_ALERTS_DETERMINATION TO TER_LETTER_ALERTS_DETERMINATION_OLD;
	RENAME OBJECT::dbo.TER_LETTER_ALERTS_DETERMINATION_STAGE TO TER_LETTER_ALERTS_DETERMINATION;
	IF OBJECT_ID('dbo.TER_LETTER_ALERTS_DETERMINATION_OLD')  IS NOT NULL DROP TABLE dbo.TER_LETTER_ALERTS_DETERMINATION_OLD;
	
	SELECT @ALERTS_RUN_ID = MAX(AlertsRunID) FROM dbo.TER_LETTER_ALERTS_DETERMINATION
	SELECT @ALERTS_COUNT = COUNT(1) FROM dbo.TER_LETTER_ALERTS_DETERMINATION WHERE AlertLevel = 'Alert' AND CONVERT(DATE,GenerationDate) = CONVERT(DATE,GETDATE()) AND AlertsRunID = (SELECT MAX(AlertsRunID) FROM dbo.TER_LETTER_ALERTS_DETERMINATION)
	SET @LOG_MESSAGE = @PROCEDURE_NAME + ' finished Alerts Run ID ' + ISNULL(CONVERT(VARCHAR,@ALERTS_RUN_ID),'?')
					   + '. Monitored Determination Letters for ' + CONVERT(VARCHAR, ISNULL(@NEW_ROW_COUNT,0)) + ' HVs and sent ' + CONVERT(VARCHAR, ISNULL(@ALERTS_COUNT,0)) + ' Alerts for the current week'
	EXEC dbo.LOG_PROCESS @SOURCE, @LOG_START_DATE, @LOG_MESSAGE, @NEW_ROW_COUNT

	/*
	--:: Alerts output.  
	SELECT	DeterminationLetterDueWeek, SentStatus, DeterminationLetterAnalysis, ViolatorID,VidSeq,HvDate,DeterminationLetterDate 
	FROM	dbo.TER_LETTER_ALERTS_DETERMINATION
	WHERE	AlertLevel = 'Alert' 
			AND CONVERT(DATE,GenerationDate) = CONVERT(DATE,GETDATE())  
			AND AlertsRunID = (SELECT MAX(AlertsRunID) FROM dbo.TER_LETTER_ALERTS_DETERMINATION)
	ORDER BY DeterminationLetterDueWeek DESC, DeterminationLetterAnalysis, HvDate DESC  
	*/

END

/*

--:: Testing
DELETE dbo.TER_LETTER_ALERTS_DETERMINATION

EXEC dbo.TER_LETTER_ALERTS_DETERMINATION_LOAD
SELECT * FROM dbo.PROCESS_LOG ORDER BY 1 DESC

--:: Alerts output summary  
SELECT	DeterminationLetterDueWeek, SentStatus, AlertLevel, DeterminationLetterAnalysis, COUNT(1) RowsCount, 
		CONVERT(VARCHAR(10),MIN(HvDate),121) HvDateFrom, CONVERT(VARCHAR(10),MAX(HvDate),121) HvDateTo 
FROM	dbo.TER_LETTER_ALERTS_DETERMINATION
--WHERE	AlertLevel = 'Alert' AND CONVERT(DATE,GenerationDate) = CONVERT(DATE,GETDATE())  
GROUP BY DeterminationLetterDueWeek, SentStatus, AlertLevel, DeterminationLetterAnalysis
ORDER BY DeterminationLetterDueWeek DESC, RowsCount DESC, DeterminationLetterAnalysis  

SELECT	DeterminationLetterDueWeek, SentStatus, AlertLevel, DeterminationLetterAnalysis, COUNT(1) RowsCount,
		CONVERT(VARCHAR(10),MIN(HvDate),121) HvDateFrom, CONVERT(VARCHAR(10),MAX(HvDate),121) HvDateTo 
FROM	dbo.TER_LETTER_ALERTS_DETERMINATION
GROUP BY DeterminationLetterDueWeek, SentStatus, AlertLevel, DeterminationLetterAnalysis
ORDER BY DeterminationLetterDueWeek DESC, RowsCount DESC, DeterminationLetterAnalysis  

SELECT	AlertsRunID, SentStatus, AlertLevel, DeterminationLetterAnalysis, COUNT(1) RowsCount, 
		CONVERT(VARCHAR(10),MIN(DeterminationLetterDueMonday),121) DeterminationLetterDueMondayFrom, CONVERT(VARCHAR(10),MAX(DeterminationLetterDueMonday),121) DeterminationLetterDueMondayTo 
FROM	dbo.TER_LETTER_ALERTS_DETERMINATION
GROUP BY AlertsRunID, SentStatus, AlertLevel, DeterminationLetterAnalysis
ORDER BY AlertsRunID desc, RowsCount DESC, DeterminationLetterAnalysis  

SELECT	*
FROM	dbo.TER_LETTER_ALERTS_DETERMINATION  
WHERE	DeterminationLetterAnalysis = 'Why no Determination letter?'  
ORDER BY DeterminationLetterDueMonday DESC

SELECT	*
FROM	dbo.TER_LETTER_ALERTS_DETERMINATION    
WHERE	ViolatorID = 801772917
ORDER BY AlertsRunID DESC, DeterminationLetterDueMonday DESC

SELECT	*
FROM	#HV   
WHERE	ViolatorID = 768589030

SELECT * 
FROM 
	(
		SELECT	*, ROW_NUMBER() OVER (PARTITION BY SentStatus, AlertLevel, DeterminationLetterAnalysis ORDER BY HvDate DESC) RN
		FROM	dbo.TER_LETTER_ALERTS_DETERMINATION
		WHERE	AlertsRunID = (SELECT MAX(AlertsRunID) FROM dbo.TER_LETTER_ALERTS_DETERMINATION)
	) T
WHERE RN <= 100
ORDER BY DeterminationLetterAnalysis, T.RN

*/ 


