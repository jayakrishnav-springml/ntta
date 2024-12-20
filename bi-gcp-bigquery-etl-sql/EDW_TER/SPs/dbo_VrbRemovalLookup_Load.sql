CREATE PROC [dbo].[VrbRemovalLookup_Load] AS 

	DECLARE @LAST_UPDATE_DATE datetime2(2) 
	exec dbo.GetLoadStartDatetime 'LND_TER.dbo.VrbRemovalLookup', @LAST_UPDATE_DATE OUTPUT

	IF OBJECT_ID('dbo.VrbRemovalLookup_Stage')>0
		DROP TABLE dbo.VrbRemovalLookup_Stage

	CREATE TABLE dbo.VrbRemovalLookup_Stage WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (VrbRemovalLookupID)) 
	AS 
	SELECT  VrbRemovalLookupID, Descr, LAST_UPDATE_TYPE, LAST_UPDATE_DATE
	FROM LND_TER.dbo.VrbRemovalLookup A
	WHERE A.LAST_UPDATE_DATE >= @LAST_UPDATE_DATE 
	OPTION (LABEL = 'VrbRemovalLookup_Stage_Load: VrbRemovalLookup_Stage');

	CREATE STATISTICS STATS_VrbRemovalLookup_Stage_001 ON VrbRemovalLookup_Stage (VrbRemovalLookupID)

	UPDATE dbo.VrbRemovalLookup
	SET	 Descr = b.Descr
		,LAST_UPDATE_DATE = b.LAST_UPDATE_DATE
	FROM dbo.VrbRemovalLookup_Stage b 
	WHERE 
		VrbRemovalLookup.VrbRemovalLookupID = b.VrbRemovalLookupID
		AND 
		b.LAST_UPDATE_TYPE = 'U'
	OPTION (LABEL = 'VrbRemovalLookup_Stage_Load: UPDATE dbo.VrbRemovalLookup');

	INSERT INTO dbo.VrbRemovalLookup (VrbRemovalLookupID, Descr, INSERT_DATE, LAST_UPDATE_DATE)
	SELECT a.VrbRemovalLookupID, a.Descr, a.LAST_UPDATE_DATE, a.LAST_UPDATE_DATE
	FROM dbo.VrbRemovalLookup_Stage a
	LEFT JOIN dbo.VrbRemovalLookup b 
		ON  a.VrbRemovalLookupID = b.VrbRemovalLookupID
	WHERE 
		b.VrbRemovalLookupID IS NULL
		AND 
		a.LAST_UPDATE_TYPE = 'I'
	OPTION (LABEL = 'VrbRemovalLookup_Stage_Load: INSERT INTO dbo.VrbRemovalLookup');
	

