CREATE PROC [dbo].[ViolatorStatusLetterDeterminationLookup_Load] AS 

	DECLARE @LAST_UPDATE_DATE datetime2(2) 
	exec dbo.GetLoadStartDatetime 'LND_TER.dbo.ViolatorStatusLetterDeterminationLookup', @LAST_UPDATE_DATE OUTPUT

	IF OBJECT_ID('dbo.ViolatorStatusLetterDeterminationLookup_Stage')>0
		DROP TABLE dbo.ViolatorStatusLetterDeterminationLookup_Stage

	CREATE TABLE dbo.ViolatorStatusLetterDeterminationLookup_Stage WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (ViolatorStatusLetterDeterminationLookupID)) 
	AS 
	SELECT  ViolatorStatusLetterDeterminationLookupID, Descr, LAST_UPDATE_TYPE, LAST_UPDATE_DATE
	FROM LND_TER.dbo.ViolatorStatusLetterDeterminationLookup A
	WHERE A.LAST_UPDATE_DATE >= @LAST_UPDATE_DATE 
	OPTION (LABEL = 'ViolatorStatusLetterDeterminationLookup_Stage_Load: ViolatorStatusLetterDeterminationLookup_Stage');

	CREATE STATISTICS STATS_ViolatorStatusLetterDeterminationLookup_Stage_001 ON ViolatorStatusLetterDeterminationLookup_Stage (ViolatorStatusLetterDeterminationLookupID)

	UPDATE dbo.ViolatorStatusLetterDeterminationLookup
	SET	 Descr = b.Descr
		,LAST_UPDATE_DATE = b.LAST_UPDATE_DATE
	FROM dbo.ViolatorStatusLetterDeterminationLookup_Stage b 
	WHERE 
		ViolatorStatusLetterDeterminationLookup.ViolatorStatusLetterDeterminationLookupID = b.ViolatorStatusLetterDeterminationLookupID
		AND 
		b.LAST_UPDATE_TYPE = 'U'
	OPTION (LABEL = 'ViolatorStatusLetterDeterminationLookup_Stage_Load: UPDATE dbo.ViolatorStatusLetterDeterminationLookup');

	INSERT INTO dbo.ViolatorStatusLetterDeterminationLookup (ViolatorStatusLetterDeterminationLookupID, Descr, INSERT_DATE, LAST_UPDATE_DATE)
	SELECT a.ViolatorStatusLetterDeterminationLookupID, a.Descr, a.LAST_UPDATE_DATE, a.LAST_UPDATE_DATE
	FROM dbo.ViolatorStatusLetterDeterminationLookup_Stage a
	LEFT JOIN dbo.ViolatorStatusLetterDeterminationLookup b 
		ON  a.ViolatorStatusLetterDeterminationLookupID = b.ViolatorStatusLetterDeterminationLookupID
	WHERE 
		b.ViolatorStatusLetterDeterminationLookupID IS NULL
		AND 
		a.LAST_UPDATE_TYPE = 'I'
	OPTION (LABEL = 'ViolatorStatusLetterDeterminationLookup_Stage_Load: INSERT INTO dbo.ViolatorStatusLetterDeterminationLookup');
	

