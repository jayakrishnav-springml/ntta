CREATE PROC [dbo].[ViolatorStatusLetterVrbLookup_Load] AS 

	DECLARE @LAST_UPDATE_DATE datetime2(2) 
	exec dbo.GetLoadStartDatetime 'LND_TER.dbo.ViolatorStatusLetterVrbLookup', @LAST_UPDATE_DATE OUTPUT

	IF OBJECT_ID('dbo.ViolatorStatusLetterVrbLookup_Stage')>0
		DROP TABLE dbo.ViolatorStatusLetterVrbLookup_Stage

	CREATE TABLE dbo.ViolatorStatusLetterVrbLookup_Stage WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (ViolatorStatusLetterVrbLookupID)) 
	AS 
	SELECT  ViolatorStatusLetterVrbLookupID, Descr, LAST_UPDATE_TYPE, LAST_UPDATE_DATE
	FROM LND_TER.dbo.ViolatorStatusLetterVrbLookup A
	WHERE A.LAST_UPDATE_DATE >= @LAST_UPDATE_DATE 
	OPTION (LABEL = 'ViolatorStatusLetterVrbLookup_Stage_Load: ViolatorStatusLetterVrbLookup_Stage');

	CREATE STATISTICS STATS_ViolatorStatusLetterVrbLookup_Stage_001 ON ViolatorStatusLetterVrbLookup_Stage (ViolatorStatusLetterVrbLookupID)

	UPDATE dbo.ViolatorStatusLetterVrbLookup
	SET	 Descr = b.Descr
		,LAST_UPDATE_DATE = b.LAST_UPDATE_DATE
	FROM dbo.ViolatorStatusLetterVrbLookup_Stage b 
	WHERE 
		ViolatorStatusLetterVrbLookup.ViolatorStatusLetterVrbLookupID = b.ViolatorStatusLetterVrbLookupID
		AND 
		b.LAST_UPDATE_TYPE = 'U'
	OPTION (LABEL = 'ViolatorStatusLetterVrbLookup_Stage_Load: UPDATE dbo.ViolatorStatusLetterVrbLookup');

	INSERT INTO dbo.ViolatorStatusLetterVrbLookup (ViolatorStatusLetterVrbLookupID, Descr, INSERT_DATE, LAST_UPDATE_DATE)
	SELECT a.ViolatorStatusLetterVrbLookupID, a.Descr, a.LAST_UPDATE_DATE, a.LAST_UPDATE_DATE
	FROM dbo.ViolatorStatusLetterVrbLookup_Stage a
	LEFT JOIN dbo.ViolatorStatusLetterVrbLookup b 
		ON  a.ViolatorStatusLetterVrbLookupID = b.ViolatorStatusLetterVrbLookupID
	WHERE 
		b.ViolatorStatusLetterVrbLookupID IS NULL
		AND 
		a.LAST_UPDATE_TYPE = 'I'
	OPTION (LABEL = 'ViolatorStatusLetterVrbLookup_Stage_Load: INSERT INTO dbo.ViolatorStatusLetterVrbLookup');
	

