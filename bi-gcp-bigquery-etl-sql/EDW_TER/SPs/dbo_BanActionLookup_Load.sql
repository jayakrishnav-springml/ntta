CREATE PROC [dbo].[BanActionLookup_Load] AS 

	DECLARE @LAST_UPDATE_DATE datetime2(2) 
	exec dbo.GetLoadStartDatetime 'LND_TER.dbo.BanActionLookup', @LAST_UPDATE_DATE OUTPUT

	IF OBJECT_ID('dbo.BanActionLookup_Stage')>0
		DROP TABLE dbo.BanActionLookup_Stage

	CREATE TABLE dbo.BanActionLookup_Stage WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (BanActionLookupID)) 
	AS 
	SELECT  BanActionLookupID, Descr, LAST_UPDATE_TYPE, LAST_UPDATE_DATE
	FROM LND_TER.dbo.BanActionLookup A
	WHERE A.LAST_UPDATE_DATE >= @LAST_UPDATE_DATE 
	OPTION (LABEL = 'BanActionLookup_Stage_Load: BanActionLookup_Stage');

	CREATE STATISTICS STATS_BanActionLookup_Stage_001 ON BanActionLookup_Stage (BanActionLookupID)

	UPDATE dbo.BanActionLookup
	SET	 Descr = b.Descr
		,LAST_UPDATE_DATE = b.LAST_UPDATE_DATE
	FROM dbo.BanActionLookup_Stage b 
	WHERE 
		BanActionLookup.BanActionLookupID = b.BanActionLookupID
		AND 
		b.LAST_UPDATE_TYPE = 'U'
	OPTION (LABEL = 'BanActionLookup_Stage_Load: UPDATE dbo.BanActionLookup');

	INSERT INTO dbo.BanActionLookup (BanActionLookupID, Descr, INSERT_DATE, LAST_UPDATE_DATE)
	SELECT a.BanActionLookupID, a.Descr, a.LAST_UPDATE_DATE, a.LAST_UPDATE_DATE
	FROM dbo.BanActionLookup_Stage a
	LEFT JOIN dbo.BanActionLookup b 
		ON  a.BanActionLookupID = b.BanActionLookupID
	WHERE 
		b.BanActionLookupID IS NULL
		AND 
		a.LAST_UPDATE_TYPE = 'I'
	OPTION (LABEL = 'BanActionLookup_Stage_Load: INSERT INTO dbo.BanActionLookup');
	

