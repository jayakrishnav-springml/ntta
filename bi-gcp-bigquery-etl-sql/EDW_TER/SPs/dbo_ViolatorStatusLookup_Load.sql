CREATE PROC [dbo].[ViolatorStatusLookup_Load] AS 

	DECLARE @LAST_UPDATE_DATE datetime2(2) 
	exec dbo.GetLoadStartDatetime 'LND_TER.dbo.ViolatorStatusLookup', @LAST_UPDATE_DATE OUTPUT

	IF OBJECT_ID('dbo.ViolatorStatusLookup_Stage')>0
		DROP TABLE dbo.ViolatorStatusLookup_Stage

	CREATE TABLE dbo.ViolatorStatusLookup_Stage WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (ViolatorStatusLookupID)) 
	AS 
	SELECT  ViolatorStatusLookupID, Descr, LAST_UPDATE_TYPE, LAST_UPDATE_DATE
	FROM LND_TER.dbo.ViolatorStatusLookup A
	WHERE A.LAST_UPDATE_DATE >= @LAST_UPDATE_DATE 
	OPTION (LABEL = 'ViolatorStatusLookup_Stage_Load: ViolatorStatusLookup_Stage');

	CREATE STATISTICS STATS_ViolatorStatusLookup_Stage_001 ON ViolatorStatusLookup_Stage (ViolatorStatusLookupID)

	UPDATE dbo.ViolatorStatusLookup
	SET	 Descr = b.Descr
		,LAST_UPDATE_DATE = b.LAST_UPDATE_DATE
	FROM dbo.ViolatorStatusLookup_Stage b 
	WHERE 
		ViolatorStatusLookup.ViolatorStatusLookupID = b.ViolatorStatusLookupID
		AND 
		b.LAST_UPDATE_TYPE = 'U'
	OPTION (LABEL = 'ViolatorStatusLookup_Stage_Load: UPDATE dbo.ViolatorStatusLookup');

	INSERT INTO dbo.ViolatorStatusLookup (ViolatorStatusLookupID, Descr, INSERT_DATE, LAST_UPDATE_DATE)
	SELECT a.ViolatorStatusLookupID, a.Descr, a.LAST_UPDATE_DATE, a.LAST_UPDATE_DATE
	FROM dbo.ViolatorStatusLookup_Stage a
	LEFT JOIN dbo.ViolatorStatusLookup b 
		ON  a.ViolatorStatusLookupID = b.ViolatorStatusLookupID
	WHERE 
		b.ViolatorStatusLookupID IS NULL
		AND 
		a.LAST_UPDATE_TYPE = 'I'
	OPTION (LABEL = 'ViolatorStatusLookup_Stage_Load: INSERT INTO dbo.ViolatorStatusLookup');
	

