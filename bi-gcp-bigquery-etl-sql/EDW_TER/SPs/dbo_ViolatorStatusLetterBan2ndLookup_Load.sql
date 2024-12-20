CREATE PROC [dbo].[ViolatorStatusLetterBan2ndLookup_Load] AS 

	DECLARE @LAST_UPDATE_DATE datetime2(2) 
	exec dbo.GetLoadStartDatetime 'LND_TER.dbo.ViolatorStatusLetterBan2ndLookup', @LAST_UPDATE_DATE OUTPUT

	IF OBJECT_ID('dbo.ViolatorStatusLetterBan2ndLookup_Stage')>0
		DROP TABLE dbo.ViolatorStatusLetterBan2ndLookup_Stage

	CREATE TABLE dbo.ViolatorStatusLetterBan2ndLookup_Stage WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (ViolatorStatusLetterBan2ndLookupID)) 
	AS 
	SELECT  ViolatorStatusLetterBan2ndLookupID, Descr, LAST_UPDATE_TYPE, LAST_UPDATE_DATE
	FROM LND_TER.dbo.ViolatorStatusLetterBan2ndLookup A
	WHERE A.LAST_UPDATE_DATE >= @LAST_UPDATE_DATE 
	OPTION (LABEL = 'ViolatorStatusLetterBan2ndLookup_Stage_Load: ViolatorStatusLetterBan2ndLookup_Stage');

	CREATE STATISTICS STATS_ViolatorStatusLetterBan2ndLookup_Stage_001 ON ViolatorStatusLetterBan2ndLookup_Stage (ViolatorStatusLetterBan2ndLookupID)

	UPDATE dbo.ViolatorStatusLetterBan2ndLookup
	SET	 Descr = b.Descr
		,LAST_UPDATE_DATE = b.LAST_UPDATE_DATE
	FROM dbo.ViolatorStatusLetterBan2ndLookup_Stage b 
	WHERE 
		ViolatorStatusLetterBan2ndLookup.ViolatorStatusLetterBan2ndLookupID = b.ViolatorStatusLetterBan2ndLookupID
		AND 
		b.LAST_UPDATE_TYPE = 'U'
	OPTION (LABEL = 'ViolatorStatusLetterBan2ndLookup_Stage_Load: UPDATE dbo.ViolatorStatusLetterBan2ndLookup');

	INSERT INTO dbo.ViolatorStatusLetterBan2ndLookup (ViolatorStatusLetterBan2ndLookupID, Descr, INSERT_DATE, LAST_UPDATE_DATE)
	SELECT a.ViolatorStatusLetterBan2ndLookupID, a.Descr, a.LAST_UPDATE_DATE, a.LAST_UPDATE_DATE
	FROM dbo.ViolatorStatusLetterBan2ndLookup_Stage a
	LEFT JOIN dbo.ViolatorStatusLetterBan2ndLookup b 
		ON  a.ViolatorStatusLetterBan2ndLookupID = b.ViolatorStatusLetterBan2ndLookupID
	WHERE 
		b.ViolatorStatusLetterBan2ndLookupID IS NULL
		AND 
		a.LAST_UPDATE_TYPE = 'I'
	OPTION (LABEL = 'ViolatorStatusLetterBan2ndLookup_Stage_Load: INSERT INTO dbo.ViolatorStatusLetterBan2ndLookup');
	

