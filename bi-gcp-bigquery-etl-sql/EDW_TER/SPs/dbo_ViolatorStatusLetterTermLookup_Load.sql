CREATE PROC [dbo].[ViolatorStatusLetterTermLookup_Load] AS 

	DECLARE @LAST_UPDATE_DATE datetime2(2) 
	exec dbo.GetLoadStartDatetime 'LND_TER.dbo.ViolatorStatusLetterTermLookup', @LAST_UPDATE_DATE OUTPUT

	IF OBJECT_ID('dbo.ViolatorStatusLetterTermLookup_Stage')>0
		DROP TABLE dbo.ViolatorStatusLetterTermLookup_Stage

	CREATE TABLE dbo.ViolatorStatusLetterTermLookup_Stage WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (ViolatorStatusLetterTermLookupID)) 
	AS 
	SELECT  ViolatorStatusLetterTermLookupID, Descr, LAST_UPDATE_TYPE, LAST_UPDATE_DATE
	FROM LND_TER.dbo.ViolatorStatusLetterTermLookup A
	WHERE A.LAST_UPDATE_DATE >= @LAST_UPDATE_DATE 
	OPTION (LABEL = 'ViolatorStatusLetterTermLookup_Stage_Load: ViolatorStatusLetterTermLookup_Stage');

	CREATE STATISTICS STATS_ViolatorStatusLetterTermLookup_Stage_001 ON ViolatorStatusLetterTermLookup_Stage (ViolatorStatusLetterTermLookupID)

	UPDATE dbo.ViolatorStatusLetterTermLookup
	SET	 Descr = b.Descr
		,LAST_UPDATE_DATE = b.LAST_UPDATE_DATE
	FROM dbo.ViolatorStatusLetterTermLookup_Stage b 
	WHERE 
		ViolatorStatusLetterTermLookup.ViolatorStatusLetterTermLookupID = b.ViolatorStatusLetterTermLookupID
		AND 
		b.LAST_UPDATE_TYPE = 'U'
	OPTION (LABEL = 'ViolatorStatusLetterTermLookup_Stage_Load: UPDATE dbo.ViolatorStatusLetterTermLookup');

	INSERT INTO dbo.ViolatorStatusLetterTermLookup (ViolatorStatusLetterTermLookupID, Descr, INSERT_DATE, LAST_UPDATE_DATE)
	SELECT a.ViolatorStatusLetterTermLookupID, a.Descr, a.LAST_UPDATE_DATE, a.LAST_UPDATE_DATE
	FROM dbo.ViolatorStatusLetterTermLookup_Stage a
	LEFT JOIN dbo.ViolatorStatusLetterTermLookup b 
		ON  a.ViolatorStatusLetterTermLookupID = b.ViolatorStatusLetterTermLookupID
	WHERE 
		b.ViolatorStatusLetterTermLookupID IS NULL
		AND 
		a.LAST_UPDATE_TYPE = 'I'
	OPTION (LABEL = 'ViolatorStatusLetterTermLookup_Stage_Load: INSERT INTO dbo.ViolatorStatusLetterTermLookup');
	

