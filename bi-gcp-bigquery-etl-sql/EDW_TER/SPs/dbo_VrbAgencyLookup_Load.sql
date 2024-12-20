CREATE PROC [dbo].[VrbAgencyLookup_Load] AS 

	DECLARE @LAST_UPDATE_DATE datetime2(2) 
	exec dbo.GetLoadStartDatetime 'LND_TER.dbo.VrbAgencyLookup', @LAST_UPDATE_DATE OUTPUT

	IF OBJECT_ID('dbo.VrbAgencyLookup_Stage')>0
		DROP TABLE dbo.VrbAgencyLookup_Stage

	CREATE TABLE dbo.VrbAgencyLookup_Stage WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (VrbAgencyLookupID)) 
	AS 
	SELECT  VrbAgencyLookupID, Descr, LAST_UPDATE_TYPE, LAST_UPDATE_DATE
	FROM LND_TER.dbo.VrbAgencyLookup A
	WHERE A.LAST_UPDATE_DATE >= @LAST_UPDATE_DATE 
	OPTION (LABEL = 'VrbAgencyLookup_Stage_Load: VrbAgencyLookup_Stage');

	CREATE STATISTICS STATS_VrbAgencyLookup_Stage_001 ON VrbAgencyLookup_Stage (VrbAgencyLookupID)

	UPDATE dbo.VrbAgencyLookup
	SET	 Descr = b.Descr
		,LAST_UPDATE_DATE = b.LAST_UPDATE_DATE
	FROM dbo.VrbAgencyLookup_Stage b 
	WHERE 
		VrbAgencyLookup.VrbAgencyLookupID = b.VrbAgencyLookupID
		AND 
		b.LAST_UPDATE_TYPE = 'U'
	OPTION (LABEL = 'VrbAgencyLookup_Stage_Load: UPDATE dbo.VrbAgencyLookup');

	INSERT INTO dbo.VrbAgencyLookup (VrbAgencyLookupID, Descr, INSERT_DATE, LAST_UPDATE_DATE)
	SELECT a.VrbAgencyLookupID, a.Descr, a.LAST_UPDATE_DATE, a.LAST_UPDATE_DATE
	FROM dbo.VrbAgencyLookup_Stage a
	LEFT JOIN dbo.VrbAgencyLookup b 
		ON  a.VrbAgencyLookupID = b.VrbAgencyLookupID
	WHERE 
		b.VrbAgencyLookupID IS NULL
		AND 
		a.LAST_UPDATE_TYPE = 'I'
	OPTION (LABEL = 'VrbAgencyLookup_Stage_Load: INSERT INTO dbo.VrbAgencyLookup');
	

