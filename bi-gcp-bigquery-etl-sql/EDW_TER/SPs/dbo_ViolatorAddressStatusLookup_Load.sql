CREATE PROC [dbo].[ViolatorAddressStatusLookup_Load] AS 

	DECLARE @LAST_UPDATE_DATE datetime2(2) 
	exec dbo.GetLoadStartDatetime 'LND_TER.dbo.ViolatorAddressStatusLookup', @LAST_UPDATE_DATE OUTPUT

	IF OBJECT_ID('dbo.ViolatorAddressStatusLookup_Stage')>0
		DROP TABLE dbo.ViolatorAddressStatusLookup_Stage

	CREATE TABLE dbo.ViolatorAddressStatusLookup_Stage WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (ViolatorAddressStatusLookupID)) 
	AS 
	SELECT  ViolatorAddressStatusLookupID, Descr, LAST_UPDATE_TYPE, LAST_UPDATE_DATE
	FROM LND_TER.dbo.ViolatorAddressStatusLookup A
	WHERE A.LAST_UPDATE_DATE >= @LAST_UPDATE_DATE 
	OPTION (LABEL = 'ViolatorAddressStatusLookup_Stage_Load: ViolatorAddressStatusLookup_Stage');

	CREATE STATISTICS STATS_ViolatorAddressStatusLookup_Stage_001 ON ViolatorAddressStatusLookup_Stage (ViolatorAddressStatusLookupID)

	UPDATE dbo.ViolatorAddressStatusLookup
	SET	 Descr = b.Descr
		,LAST_UPDATE_DATE = b.LAST_UPDATE_DATE
	FROM dbo.ViolatorAddressStatusLookup_Stage b 
	WHERE 
		ViolatorAddressStatusLookup.ViolatorAddressStatusLookupID = b.ViolatorAddressStatusLookupID
		AND 
		b.LAST_UPDATE_TYPE = 'U'
	OPTION (LABEL = 'ViolatorAddressStatusLookup_Stage_Load: UPDATE dbo.ViolatorAddressStatusLookup');

	INSERT INTO dbo.ViolatorAddressStatusLookup (ViolatorAddressStatusLookupID, Descr, INSERT_DATE, LAST_UPDATE_DATE)
	SELECT a.ViolatorAddressStatusLookupID, a.Descr, a.LAST_UPDATE_DATE, a.LAST_UPDATE_DATE
	FROM dbo.ViolatorAddressStatusLookup_Stage a
	LEFT JOIN dbo.ViolatorAddressStatusLookup b 
		ON  a.ViolatorAddressStatusLookupID = b.ViolatorAddressStatusLookupID
	WHERE 
		b.ViolatorAddressStatusLookupID IS NULL
		AND 
		a.LAST_UPDATE_TYPE = 'I'
	OPTION (LABEL = 'ViolatorAddressStatusLookup_Stage_Load: INSERT INTO dbo.ViolatorAddressStatusLookup');
	

