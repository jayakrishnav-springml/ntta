CREATE PROC [dbo].[ViolatorAgencyLookup_Load] AS 

	DECLARE @LAST_UPDATE_DATE datetime2(2) 
	exec dbo.GetLoadStartDatetime 'LND_TER.dbo.ViolatorAgencyLookup', @LAST_UPDATE_DATE OUTPUT

	IF OBJECT_ID('dbo.ViolatorAgencyLookup_Stage')>0
		DROP TABLE dbo.ViolatorAgencyLookup_Stage

	CREATE TABLE dbo.ViolatorAgencyLookup_Stage WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (ViolatorAgencyLookupID)) 
	AS 
	SELECT  ViolatorAgencyLookupID, Descr, LAST_UPDATE_TYPE, LAST_UPDATE_DATE
	FROM LND_TER.dbo.ViolatorAgencyLookup A
	WHERE A.LAST_UPDATE_DATE >= @LAST_UPDATE_DATE 
	OPTION (LABEL = 'ViolatorAgencyLookup_Stage_Load: ViolatorAgencyLookup_Stage');

	CREATE STATISTICS STATS_ViolatorAgencyLookup_Stage_001 ON ViolatorAgencyLookup_Stage (ViolatorAgencyLookupID)

	UPDATE dbo.ViolatorAgencyLookup
	SET	 Descr = b.Descr
		,LAST_UPDATE_DATE = b.LAST_UPDATE_DATE
	FROM dbo.ViolatorAgencyLookup_Stage b 
	WHERE 
		ViolatorAgencyLookup.ViolatorAgencyLookupID = b.ViolatorAgencyLookupID
		AND 
		b.LAST_UPDATE_TYPE = 'U'
	OPTION (LABEL = 'ViolatorAgencyLookup_Stage_Load: UPDATE dbo.ViolatorAgencyLookup');

	INSERT INTO dbo.ViolatorAgencyLookup (ViolatorAgencyLookupID, Descr, INSERT_DATE, LAST_UPDATE_DATE)
	SELECT a.ViolatorAgencyLookupID, a.Descr, a.LAST_UPDATE_DATE, a.LAST_UPDATE_DATE
	FROM dbo.ViolatorAgencyLookup_Stage a
	LEFT JOIN dbo.ViolatorAgencyLookup b 
		ON  a.ViolatorAgencyLookupID = b.ViolatorAgencyLookupID
	WHERE 
		b.ViolatorAgencyLookupID IS NULL
		AND 
		a.LAST_UPDATE_TYPE = 'I'
	OPTION (LABEL = 'ViolatorAgencyLookup_Stage_Load: INSERT INTO dbo.ViolatorAgencyLookup');
	

