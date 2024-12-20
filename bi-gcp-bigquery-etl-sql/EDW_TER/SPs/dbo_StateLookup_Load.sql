CREATE PROC [dbo].[StateLookup_Load] AS 

	DECLARE @LAST_UPDATE_DATE datetime2(2) 
	exec dbo.GetLoadStartDatetime 'LND_TER.dbo.StateLookup', @LAST_UPDATE_DATE OUTPUT

	IF OBJECT_ID('dbo.StateLookup_Stage')>0
		DROP TABLE dbo.StateLookup_Stage

	CREATE TABLE dbo.StateLookup_Stage WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (StateLookupID)) 
	AS 
	SELECT  StateLookupID, Descr, LAST_UPDATE_TYPE, LAST_UPDATE_DATE
	FROM LND_TER.dbo.StateLookup A
	WHERE A.LAST_UPDATE_DATE >= @LAST_UPDATE_DATE 
	OPTION (LABEL = 'StateLookup_Stage_Load: StateLookup_Stage');

	CREATE STATISTICS STATS_StateLookup_Stage_001 ON StateLookup_Stage (StateLookupID)

	UPDATE dbo.StateLookup
	SET	 Descr = b.Descr
		,LAST_UPDATE_DATE = b.LAST_UPDATE_DATE
	FROM dbo.StateLookup_Stage b 
	WHERE 
		StateLookup.StateLookupID = b.StateLookupID
		AND 
		b.LAST_UPDATE_TYPE = 'U'
	OPTION (LABEL = 'StateLookup_Stage_Load: UPDATE dbo.StateLookup');

	INSERT INTO dbo.StateLookup (StateLookupID, Descr, INSERT_DATE, LAST_UPDATE_DATE)
	SELECT a.StateLookupID, a.Descr, a.LAST_UPDATE_DATE, a.LAST_UPDATE_DATE
	FROM dbo.StateLookup_Stage a
	LEFT JOIN dbo.StateLookup b 
		ON  a.StateLookupID = b.StateLookupID
	WHERE 
		b.StateLookupID IS NULL
		AND 
		a.LAST_UPDATE_TYPE = 'I'
	OPTION (LABEL = 'StateLookup_Stage_Load: INSERT INTO dbo.StateLookup');
	

