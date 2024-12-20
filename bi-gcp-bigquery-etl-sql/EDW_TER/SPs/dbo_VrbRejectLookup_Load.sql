CREATE PROC [dbo].[VrbRejectLookup_Load] AS 

	DECLARE @LAST_UPDATE_DATE datetime2(2) 
	exec dbo.GetLoadStartDatetime 'LND_TER.dbo.VrbRejectLookup', @LAST_UPDATE_DATE OUTPUT

	IF OBJECT_ID('dbo.VrbRejectLookup_Stage')>0
		DROP TABLE dbo.VrbRejectLookup_Stage

	CREATE TABLE dbo.VrbRejectLookup_Stage WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (VrbRejectLookupID)) 
	AS 
	SELECT  VrbRejectLookupID, Descr, LAST_UPDATE_TYPE, LAST_UPDATE_DATE
	FROM LND_TER.dbo.VrbRejectLookup A
	WHERE A.LAST_UPDATE_DATE >= @LAST_UPDATE_DATE 
	OPTION (LABEL = 'VrbRejectLookup_Stage_Load: VrbRejectLookup_Stage');

	CREATE STATISTICS STATS_VrbRejectLookup_Stage_001 ON VrbRejectLookup_Stage (VrbRejectLookupID)

	UPDATE dbo.VrbRejectLookup
	SET	 Descr = b.Descr
		,LAST_UPDATE_DATE = b.LAST_UPDATE_DATE
	FROM dbo.VrbRejectLookup_Stage b 
	WHERE 
		VrbRejectLookup.VrbRejectLookupID = b.VrbRejectLookupID
		AND 
		b.LAST_UPDATE_TYPE = 'U'
	OPTION (LABEL = 'VrbRejectLookup_Stage_Load: UPDATE dbo.VrbRejectLookup');

	INSERT INTO dbo.VrbRejectLookup (VrbRejectLookupID, Descr, INSERT_DATE, LAST_UPDATE_DATE)
	SELECT a.VrbRejectLookupID, a.Descr, a.LAST_UPDATE_DATE, a.LAST_UPDATE_DATE
	FROM dbo.VrbRejectLookup_Stage a
	LEFT JOIN dbo.VrbRejectLookup b 
		ON  a.VrbRejectLookupID = b.VrbRejectLookupID
	WHERE 
		b.VrbRejectLookupID IS NULL
		AND 
		a.LAST_UPDATE_TYPE = 'I'
	OPTION (LABEL = 'VrbRejectLookup_Stage_Load: INSERT INTO dbo.VrbRejectLookup');
	

