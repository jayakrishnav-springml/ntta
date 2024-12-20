CREATE PROC [dbo].[BanLocationLookup_Load] AS 

	DECLARE @LAST_UPDATE_DATE datetime2(2) 
	exec dbo.GetLoadStartDatetime 'LND_TER.dbo.BanLocationLookup', @LAST_UPDATE_DATE OUTPUT

	IF OBJECT_ID('dbo.BanLocationLookup_Stage')>0
		DROP TABLE dbo.BanLocationLookup_Stage

	CREATE TABLE dbo.BanLocationLookup_Stage WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (BanLocationLookupID)) 
	AS 
	SELECT  BanLocationLookupID, Descr, LAST_UPDATE_TYPE, LAST_UPDATE_DATE
	FROM LND_TER.dbo.BanLocationLookup A
	WHERE A.LAST_UPDATE_DATE >= @LAST_UPDATE_DATE 
	OPTION (LABEL = 'BanLocationLookup_Stage_Load: BanLocationLookup_Stage');

	CREATE STATISTICS STATS_BanLocationLookup_Stage_001 ON BanLocationLookup_Stage (BanLocationLookupID)

	UPDATE dbo.BanLocationLookup
	SET	 Descr = b.Descr
		,LAST_UPDATE_DATE = b.LAST_UPDATE_DATE
	FROM dbo.BanLocationLookup_Stage b 
	WHERE 
		BanLocationLookup.BanLocationLookupID = b.BanLocationLookupID
		AND 
		b.LAST_UPDATE_TYPE = 'U'
	OPTION (LABEL = 'BanLocationLookup_Stage_Load: UPDATE dbo.BanLocationLookup');

	INSERT INTO dbo.BanLocationLookup (BanLocationLookupID, Descr, INSERT_DATE, LAST_UPDATE_DATE)
	SELECT a.BanLocationLookupID, a.Descr, a.LAST_UPDATE_DATE, a.LAST_UPDATE_DATE
	FROM dbo.BanLocationLookup_Stage a
	LEFT JOIN dbo.BanLocationLookup b 
		ON  a.BanLocationLookupID = b.BanLocationLookupID
	WHERE 
		b.BanLocationLookupID IS NULL
		AND 
		a.LAST_UPDATE_TYPE = 'I'
	OPTION (LABEL = 'BanLocationLookup_Stage_Load: INSERT INTO dbo.BanLocationLookup');
	

