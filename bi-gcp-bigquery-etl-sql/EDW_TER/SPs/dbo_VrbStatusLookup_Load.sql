CREATE PROC [dbo].[VrbStatusLookup_Load] AS 

	DECLARE @LAST_UPDATE_DATE datetime2(2) 
	exec dbo.GetLoadStartDatetime 'LND_TER.dbo.VrbStatusLookup', @LAST_UPDATE_DATE OUTPUT

	IF OBJECT_ID('dbo.VrbStatusLookup_Stage')>0
		DROP TABLE dbo.VrbStatusLookup_Stage

	CREATE TABLE dbo.VrbStatusLookup_Stage WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (VrbStatusLookupID)) 
	AS 
	SELECT  VrbStatusLookupID, Descr, LAST_UPDATE_TYPE, LAST_UPDATE_DATE
	FROM LND_TER.dbo.VrbStatusLookup A
	WHERE A.LAST_UPDATE_DATE >= @LAST_UPDATE_DATE 
	OPTION (LABEL = 'VrbStatusLookup_Stage_Load: VrbStatusLookup_Stage');

	CREATE STATISTICS STATS_VrbStatusLookup_Stage_001 ON VrbStatusLookup_Stage (VrbStatusLookupID)

	UPDATE dbo.VrbStatusLookup
	SET	 Descr = b.Descr
		,LAST_UPDATE_DATE = b.LAST_UPDATE_DATE
	FROM dbo.VrbStatusLookup_Stage b 
	WHERE 
		VrbStatusLookup.VrbStatusLookupID = b.VrbStatusLookupID
		AND 
		b.LAST_UPDATE_TYPE = 'U'
	OPTION (LABEL = 'VrbStatusLookup_Stage_Load: UPDATE dbo.VrbStatusLookup');

	INSERT INTO dbo.VrbStatusLookup (VrbStatusLookupID, Descr, INSERT_DATE, LAST_UPDATE_DATE)
	SELECT a.VrbStatusLookupID, a.Descr, a.LAST_UPDATE_DATE, a.LAST_UPDATE_DATE
	FROM dbo.VrbStatusLookup_Stage a
	LEFT JOIN dbo.VrbStatusLookup b 
		ON  a.VrbStatusLookupID = b.VrbStatusLookupID
	WHERE 
		b.VrbStatusLookupID IS NULL
		AND 
		a.LAST_UPDATE_TYPE = 'I'
	OPTION (LABEL = 'VrbStatusLookup_Stage_Load: INSERT INTO dbo.VrbStatusLookup');
	

