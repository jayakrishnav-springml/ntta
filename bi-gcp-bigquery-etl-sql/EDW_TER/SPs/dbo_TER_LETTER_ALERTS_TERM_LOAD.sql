CREATE PROC [dbo].[TER_LETTER_ALERTS_TERM_LOAD] AS
BEGIN
	--#1    Shankar Metla    2019-05-16  Created

	DECLARE @SOURCE VARCHAR(50), @LOG_START_DATE DATETIME2 (0), @PROCEDURE_NAME VARCHAR(100), @LOG_MESSAGE VARCHAR(3000), @ROW_COUNT BIGINT, @TABLE_ROW_COUNT BIGINT, @NEW_ROW_COUNT BIGINT, @ALERTS_COUNT BIGINT, @ALERTS_RUN_ID INT
	SELECT  @SOURCE = 'TER_LETTER_ALERTS_TERM', @LOG_START_DATE = SYSDATETIME(), @PROCEDURE_NAME = 'TER_LETTER_ALERTS_TERM_LOAD'

	DECLARE @CURRENT_WEEK_DUE_DATE DATETIME =  CASE WHEN DATEPART(DW,GETDATE()) > 2 THEN DATEADD(SECOND, -1, DATEADD(DAY, 1, DATEADD(WEEK,DATEDIFF(WEEK,0,GETDATE()),0))) ELSE DATEADD(SECOND, -1, DATEADD(DAY, 1, DATEADD(WEEK,DATEDIFF(WEEK,7,GETDATE()),0))) END,
			@HV_DATE_FROM DATETIME = '1/1/2019'
 
	SET @LOG_MESSAGE = @PROCEDURE_NAME + ' started for the current week due date ' + CONVERT(VARCHAR(19),@CURRENT_WEEK_DUE_DATE,121)
	EXEC dbo.LOG_PROCESS @SOURCE, @LOG_START_DATE, @LOG_MESSAGE, NULL

	--::===========================================================================================
	--:: Get HV data for Term Letters Analysis
	--::===========================================================================================
	IF OBJECT_ID('tempdb..#HV') IS NOT NULL DROP TABLE #HV;
	WITH VS_CTE AS
	(
		SELECT	ViolatorID, VidSeq,
				MIN(CASE WHEN ViolatorStatusLetterTermLookupID = 1 THEN CreatedDate END) TermLetterQueuedDate,
				MIN(CASE WHEN UpdatedBy = 'QuestMark_Send_Termination_XML' THEN UpdatedDate END) TermLetterSendDate, 
				MIN(CASE WHEN UpdatedBy = 'QuestMark_Receive_Termination_XML' THEN UpdatedDate END) QuestMarkTermLetterAckDate 
			
		FROM	(
					SELECT ViolatorID, VidSeq, ViolatorStatusEligRmdyLookupID, TermLetterFlag, ViolatorStatusLetterTermLookupID, TermLetterDate, CreatedDate, UpdatedBy, UpdatedDate FROM LND_TER.dbo.ViolatorStatus WHERE HvDate >= @HV_DATE_FROM 
					UNION													   
					SELECT ViolatorID, VidSeq, ViolatorStatusEligRmdyLookupID, TermLetterFlag, ViolatorStatusLetterTermLookupID, TermLetterDate, CreatedDate, UpdatedBy, UpdatedDate FROM LND_TER.dbo.ViolatorStatusHistory WHERE HvDate >= @HV_DATE_FROM
				) V
		GROUP BY ViolatorID, VidSeq
	)
	SELECT  
			VS.ViolatorID, 
			VS.VidSeq,
			VS.HvDate, 
			VS.TermDate, 
			DATEADD(SECOND, -1,DATEADD(WEEK,DATEDIFF(WEEK,0,VS.TermDate), CASE WHEN DATENAME(DW,VS.TermDate) = 'Monday' THEN 1 ELSE 8 END)) TermLetterDueMonday,
			VS.TermLetterDate,
			VSC.TermLetterQueuedDate,
			VSC.TermLetterSendDate,
			VSC.QuestMarkTermLetterAckDate,
			LVL.Descr TermLetterStatus,
			VSL.Descr ViolatorStatus,
			EL.Descr ViolatorStatusEligRmdy,
			VS.HvFlag, 
			VS.EligRmdyFlag,
			VS.TermLetterFlag 
	INTO #HV
	FROM LND_TER.dbo.ViolatorStatus VS
	LEFT JOIN VS_CTE VSC ON VS.VIOLATORID = VSC.VIOLATORID AND VSC.VIDSEQ = VS.VIDSEQ
	LEFT JOIN LND_TER.dbo.ViolatorStatusLookup VSL ON VSL.ViolatorStatusLookupID = VS.ViolatorStatusLookupID
	LEFT JOIN LND_TER.dbo.ViolatorStatusEligRmdyLookup  EL ON EL.ViolatorStatusEligRmdyLookupID = VS.ViolatorStatusEligRmdyLookupID 
	LEFT JOIN LND_TER.dbo.ViolatorStatusLetterTermLookup  LVL ON LVL.ViolatorStatusLetterTermLookupID = VS.ViolatorStatusLetterTermLookupID 
	WHERE	VS.HvDate >= @HV_DATE_FROM

	--::===========================================================================================
	--:: Load Term Letters status as of current week due date
	--::===========================================================================================
	SELECT @TABLE_ROW_COUNT = COUNT(1) FROM dbo.TER_LETTER_ALERTS_TERM
	
	IF  OBJECT_ID('dbo.TER_LETTER_ALERTS_TERM_STAGE') IS NOT NULL DROP TABLE dbo.TER_LETTER_ALERTS_TERM_STAGE;	
	CREATE TABLE dbo.TER_LETTER_ALERTS_TERM_STAGE WITH (HEAP, DISTRIBUTION = HASH(ViolatorID)) AS	
	WITH DETERMINATION_Letter_Analysis_CTE AS
	(
		SELECT	
				ISNULL((SELECT MAX(AlertsRunID ) + 1 FROM dbo.TER_LETTER_ALERTS_TERM),1) AlertsRunID,
				ViolatorID, 
				VidSeq,
				CASE WHEN TermLetterSendDate IS NOT NULL THEN 'Sent ' 
						  + CASE WHEN TermLetterSendDate <= TermLetterDueMonday THEN 'on time' 
								 WHEN TermLetterSendDate > TermLetterDueMonday THEN 'late'  
							END
				ELSE 'Not Sent' 
				END SentStatus,
				CASE WHEN TermLetterSendDate IS NULL THEN -- NOT SENT
						'Not OK. Why no Term letter?'
				ELSE -- SENT
						CASE
							WHEN TermLetterSendDate <= TermLetterDueMonday
							THEN 'OK. Term letter sent on time'
							ELSE 'OK. Term letter sent late' 
						END   
				END TermLetterAnalysis
		FROM	#HV  
	WHERE	TermLetterDueMonday <= @CURRENT_WEEK_DUE_DATE -- Check only Letter Due cases 
	)
	SELECT	
			AlertsRunID,
			CONVERT(DATE,TermLetterDueMonday) TermLetterDueWeek,
			SentStatus,
			CASE WHEN LAC.TermLetterAnalysis LIKE '%Not OK%' THEN 'Alert' ELSE 'OK' END AlertLevel,
			CONVERT(VARCHAR(100),REPLACE(REPLACE(LAC.TermLetterAnalysis,'Not OK. ',''), 'OK. ','')) TermLetterAnalysis,
			#HV.*, 
			GETDATE() GenerationDate 
	FROM	DETERMINATION_Letter_Analysis_CTE LAC
	JOIN	#HV ON LAC.ViolatorID = #HV.ViolatorID AND LAC.VidSeq = #HV.VidSeq
	WHERE	NOT (LAC.TermLetterAnalysis LIKE 'OK%' 
				 AND TermLetterDueMonday < @CURRENT_WEEK_DUE_DATE) -- Current Week: All, Prior Weeks: Not Sent.
			OR
				(LAC.TermLetterAnalysis LIKE 'OK%' 
				 AND TermLetterDueMonday < @CURRENT_WEEK_DUE_DATE 
				 AND EXISTS (SELECT 1 
							 FROM	dbo.TER_LETTER_ALERTS_TERM LA 
							 WHERE	LA.ViolatorID = LAC.ViolatorID
									AND LA.VidSeq = LAC.VidSeq
									AND LA.AlertLevel = 'Alert'
									AND LA.SentStatus = 'Not Sent'
									AND LA.AlertsRunID = (SELECT MAX(AlertsRunID) FROM dbo.TER_LETTER_ALERTS_TERM) -- Prior Weeks: Sent (Not Sent Alert in the previous run) 
							)
				)
	UNION ALL
	SELECT * FROM dbo.TER_LETTER_ALERTS_TERM
	
	EXEC	dbo.LAST_ROW_COUNT @ROW_COUNT OUTPUT
	SELECT	@NEW_ROW_COUNT = @ROW_COUNT - @TABLE_ROW_COUNT

	CREATE STATISTICS STATS_TER_LETTER_ALERTS_TERM_01 ON dbo.TER_LETTER_ALERTS_TERM_STAGE (ViolatorID,VidSeq)
	CREATE STATISTICS STATS_TER_LETTER_ALERTS_TERM_02 ON dbo.TER_LETTER_ALERTS_TERM_STAGE (TermLetterDueWeek)
	CREATE STATISTICS STATS_TER_LETTER_ALERTS_TERM_03 ON dbo.TER_LETTER_ALERTS_TERM_STAGE (TermLetterAnalysis)

	IF OBJECT_ID('dbo.TER_LETTER_ALERTS_TERM_OLD')  IS NOT NULL DROP TABLE dbo.TER_LETTER_ALERTS_TERM_OLD;
	IF OBJECT_ID('dbo.TER_LETTER_ALERTS_TERM')  IS NOT NULL RENAME OBJECT::dbo.TER_LETTER_ALERTS_TERM TO TER_LETTER_ALERTS_TERM_OLD;
	RENAME OBJECT::dbo.TER_LETTER_ALERTS_TERM_STAGE TO TER_LETTER_ALERTS_TERM;
	IF OBJECT_ID('dbo.TER_LETTER_ALERTS_TERM_OLD')  IS NOT NULL DROP TABLE dbo.TER_LETTER_ALERTS_TERM_OLD;
	
	SELECT @ALERTS_RUN_ID = MAX(AlertsRunID) FROM dbo.TER_LETTER_ALERTS_TERM
	SELECT @ALERTS_COUNT = COUNT(1) FROM dbo.TER_LETTER_ALERTS_TERM WHERE AlertLevel = 'Alert' AND CONVERT(DATE,GenerationDate) = CONVERT(DATE,GETDATE()) AND AlertsRunID = (SELECT MAX(AlertsRunID) FROM dbo.TER_LETTER_ALERTS_TERM)
	SET @LOG_MESSAGE = @PROCEDURE_NAME + ' finished Alerts Run ID ' + ISNULL(CONVERT(VARCHAR,@ALERTS_RUN_ID),'?')
					   + '. Monitored Term Letters for ' + CONVERT(VARCHAR, ISNULL(@NEW_ROW_COUNT,0)) + ' HVs and sent ' + CONVERT(VARCHAR, ISNULL(@ALERTS_COUNT,0)) + ' Alerts for the current week'
	EXEC dbo.LOG_PROCESS @SOURCE, @LOG_START_DATE, @LOG_MESSAGE, @NEW_ROW_COUNT

	/*
	--:: Alerts output.  
	SELECT	TermLetterDueWeek, SentStatus, TermLetterAnalysis, ViolatorID,VidSeq,HvDate,TermLetterDate 
	FROM	dbo.TER_LETTER_ALERTS_TERM
	WHERE	AlertLevel = 'Alert' 
			AND CONVERT(DATE,GenerationDate) = CONVERT(DATE,GETDATE())  
			AND AlertsRunID = (SELECT MAX(AlertsRunID) FROM dbo.TER_LETTER_ALERTS_TERM)
	ORDER BY TermLetterDueWeek DESC, TermLetterAnalysis, HvDate DESC  
	*/

END

/*

--:: Testing
DELETE dbo.TER_LETTER_ALERTS_TERM

EXEC dbo.TER_LETTER_ALERTS_TERM_LOAD
SELECT * FROM dbo.PROCESS_LOG ORDER BY 1 DESC

--:: Alerts output summary  
SELECT	TermLetterDueWeek, SentStatus, AlertLevel, TermLetterAnalysis, COUNT(1) RowsCount, 
		CONVERT(VARCHAR(10),MIN(HvDate),121) HvDateFrom, CONVERT(VARCHAR(10),MAX(HvDate),121) HvDateTo 
FROM	dbo.TER_LETTER_ALERTS_TERM
--WHERE	AlertLevel = 'Alert' AND CONVERT(DATE,GenerationDate) = CONVERT(DATE,GETDATE())  
GROUP BY TermLetterDueWeek, SentStatus, AlertLevel, TermLetterAnalysis
ORDER BY TermLetterDueWeek DESC, RowsCount DESC, TermLetterAnalysis  

SELECT	TermLetterDueWeek, SentStatus, AlertLevel, TermLetterAnalysis, COUNT(1) RowsCount,
		CONVERT(VARCHAR(10),MIN(HvDate),121) HvDateFrom, CONVERT(VARCHAR(10),MAX(HvDate),121) HvDateTo 
FROM	dbo.TER_LETTER_ALERTS_TERM
GROUP BY TermLetterDueWeek, SentStatus, AlertLevel, TermLetterAnalysis
ORDER BY TermLetterDueWeek DESC, RowsCount DESC, TermLetterAnalysis  

SELECT	AlertsRunID, SentStatus, AlertLevel, TermLetterAnalysis, COUNT(1) RowsCount, 
		CONVERT(VARCHAR(10),MIN(TermLetterDueMonday),121) TermLetterDueMondayFrom, CONVERT(VARCHAR(10),MAX(TermLetterDueMonday),121) TermLetterDueMondayTo 
FROM	dbo.TER_LETTER_ALERTS_TERM
GROUP BY AlertsRunID, SentStatus, AlertLevel, TermLetterAnalysis
ORDER BY AlertsRunID desc, RowsCount DESC, TermLetterAnalysis  

SELECT	*
FROM	dbo.TER_LETTER_ALERTS_TERM  
WHERE	TermLetterAnalysis = 'Why no Term letter?'  
ORDER BY TermLetterDueMonday DESC

SELECT	*
FROM	dbo.TER_LETTER_ALERTS_TERM    
WHERE	ViolatorID = 801772917
ORDER BY AlertsRunID DESC, TermLetterDueMonday DESC

SELECT	*
FROM	#HV   
WHERE	ViolatorID = 768589030

SELECT * 
FROM 
	(
		SELECT	*, ROW_NUMBER() OVER (PARTITION BY SentStatus, AlertLevel, TermLetterAnalysis ORDER BY HvDate DESC) RN
		FROM	dbo.TER_LETTER_ALERTS_TERM
		WHERE	AlertsRunID = (SELECT MAX(AlertsRunID) FROM dbo.TER_LETTER_ALERTS_TERM)
	) T
WHERE RN <= 100
ORDER BY TermLetterAnalysis, T.RN

*/ 


