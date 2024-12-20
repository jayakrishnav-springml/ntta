CREATE PROC [dbo].[ViolatorStatusTermLookup_Load] AS 

	DECLARE @LAST_UPDATE_DATE datetime2(2) 
	exec dbo.GetLoadStartDatetime 'LND_TER.dbo.ViolatorStatusTermLookup', @LAST_UPDATE_DATE OUTPUT

	IF OBJECT_ID('dbo.ViolatorStatusTermLookup_Stage')>0
		DROP TABLE dbo.ViolatorStatusTermLookup_Stage

	CREATE TABLE dbo.ViolatorStatusTermLookup_Stage WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (ViolatorStatusTermLookupID)) 
	AS 
	SELECT  ViolatorStatusTermLookupID, Descr, LAST_UPDATE_TYPE, LAST_UPDATE_DATE
	FROM LND_TER.dbo.ViolatorStatusTermLookup A
	WHERE A.LAST_UPDATE_DATE >= @LAST_UPDATE_DATE 
	OPTION (LABEL = 'ViolatorStatusTermLookup_Stage_Load: ViolatorStatusTermLookup_Stage');

	CREATE STATISTICS STATS_ViolatorStatusTermLookup_Stage_001 ON ViolatorStatusTermLookup_Stage (ViolatorStatusTermLookupID)

	UPDATE dbo.ViolatorStatusTermLookup
	SET	 Descr = b.Descr
		,LAST_UPDATE_DATE = b.LAST_UPDATE_DATE
	FROM dbo.ViolatorStatusTermLookup_Stage b 
	WHERE 
		ViolatorStatusTermLookup.ViolatorStatusTermLookupID = b.ViolatorStatusTermLookupID
		AND 
		b.LAST_UPDATE_TYPE = 'U'
	OPTION (LABEL = 'ViolatorStatusTermLookup_Stage_Load: UPDATE dbo.ViolatorStatusTermLookup');

	INSERT INTO dbo.ViolatorStatusTermLookup (ViolatorStatusTermLookupID, Descr, INSERT_DATE, LAST_UPDATE_DATE)
	SELECT a.ViolatorStatusTermLookupID, a.Descr, a.LAST_UPDATE_DATE, a.LAST_UPDATE_DATE
	FROM dbo.ViolatorStatusTermLookup_Stage a
	LEFT JOIN dbo.ViolatorStatusTermLookup b 
		ON  a.ViolatorStatusTermLookupID = b.ViolatorStatusTermLookupID
	WHERE 
		b.ViolatorStatusTermLookupID IS NULL
		AND 
		a.LAST_UPDATE_TYPE = 'I'
	OPTION (LABEL = 'ViolatorStatusTermLookup_Stage_Load: INSERT INTO dbo.ViolatorStatusTermLookup');
	

