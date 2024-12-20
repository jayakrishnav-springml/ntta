CREATE PROC [dbo].[BanImpoundServiceLookup_Load] AS 

	DECLARE @LAST_UPDATE_DATE datetime2(2) 
	exec dbo.GetLoadStartDatetime 'LND_TER.dbo.BanImpoundServiceLookup', @LAST_UPDATE_DATE OUTPUT

	IF OBJECT_ID('dbo.BanImpoundServiceLookup_Stage')>0
		DROP TABLE dbo.BanImpoundServiceLookup_Stage

	CREATE TABLE dbo.BanImpoundServiceLookup_Stage WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (BanImpoundServiceLookupID)) 
	AS 
	SELECT  BanImpoundServiceLookupID, Descr, LAST_UPDATE_TYPE, LAST_UPDATE_DATE
	FROM LND_TER.dbo.BanImpoundServiceLookup A
	WHERE A.LAST_UPDATE_DATE >= @LAST_UPDATE_DATE 
	OPTION (LABEL = 'BanImpoundServiceLookup_Stage_Load: BanImpoundServiceLookup_Stage');

	CREATE STATISTICS STATS_BanImpoundServiceLookup_Stage_001 ON BanImpoundServiceLookup_Stage (BanImpoundServiceLookupID)

	UPDATE dbo.BanImpoundServiceLookup
	SET	 Descr = b.Descr
		,LAST_UPDATE_DATE = b.LAST_UPDATE_DATE
	FROM dbo.BanImpoundServiceLookup_Stage b 
	WHERE 
		BanImpoundServiceLookup.BanImpoundServiceLookupID = b.BanImpoundServiceLookupID
		AND 
		b.LAST_UPDATE_TYPE = 'U'
	OPTION (LABEL = 'BanImpoundServiceLookup_Stage_Load: UPDATE dbo.BanImpoundServiceLookup');

	INSERT INTO dbo.BanImpoundServiceLookup (BanImpoundServiceLookupID, Descr, INSERT_DATE, LAST_UPDATE_DATE)
	SELECT a.BanImpoundServiceLookupID, a.Descr, a.LAST_UPDATE_DATE, a.LAST_UPDATE_DATE
	FROM dbo.BanImpoundServiceLookup_Stage a
	LEFT JOIN dbo.BanImpoundServiceLookup b 
		ON  a.BanImpoundServiceLookupID = b.BanImpoundServiceLookupID
	WHERE 
		b.BanImpoundServiceLookupID IS NULL
		AND 
		a.LAST_UPDATE_TYPE = 'I'
	OPTION (LABEL = 'BanImpoundServiceLookup_Stage_Load: INSERT INTO dbo.BanImpoundServiceLookup');
	

