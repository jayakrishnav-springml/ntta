CREATE PROC [dbo].[ViolatorCallLogLookup_Load] AS 

	DECLARE @LAST_UPDATE_DATE datetime2(2) 
	exec dbo.GetLoadStartDatetime 'LND_TER.dbo.ViolatorCallLogLookup', @LAST_UPDATE_DATE OUTPUT

	IF OBJECT_ID('dbo.ViolatorCallLogLookup_Stage')>0
		DROP TABLE dbo.ViolatorCallLogLookup_Stage

	CREATE TABLE dbo.ViolatorCallLogLookup_Stage WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (ViolatorCallLogLookupID)) 
	AS 
	SELECT  ViolatorCallLogLookupID, Descr, LAST_UPDATE_TYPE, LAST_UPDATE_DATE
	FROM LND_TER.dbo.ViolatorCallLogLookup A
	WHERE A.LAST_UPDATE_DATE >= @LAST_UPDATE_DATE 
	OPTION (LABEL = 'ViolatorCallLogLookup_Stage_Load: ViolatorCallLogLookup_Stage');

	CREATE STATISTICS STATS_ViolatorCallLogLookup_Stage_001 ON ViolatorCallLogLookup_Stage (ViolatorCallLogLookupID)

	UPDATE dbo.ViolatorCallLogLookup
	SET	 Descr = b.Descr
		,LAST_UPDATE_DATE = b.LAST_UPDATE_DATE
	FROM dbo.ViolatorCallLogLookup_Stage b 
	WHERE 
		ViolatorCallLogLookup.ViolatorCallLogLookupID = b.ViolatorCallLogLookupID
		AND 
		b.LAST_UPDATE_TYPE = 'U'
	OPTION (LABEL = 'ViolatorCallLogLookup_Stage_Load: UPDATE dbo.ViolatorCallLogLookup');

	INSERT INTO dbo.ViolatorCallLogLookup (ViolatorCallLogLookupID, Descr, INSERT_DATE, LAST_UPDATE_DATE)
	SELECT a.ViolatorCallLogLookupID, a.Descr, a.LAST_UPDATE_DATE, a.LAST_UPDATE_DATE
	FROM dbo.ViolatorCallLogLookup_Stage a
	LEFT JOIN dbo.ViolatorCallLogLookup b 
		ON  a.ViolatorCallLogLookupID = b.ViolatorCallLogLookupID
	WHERE 
		b.ViolatorCallLogLookupID IS NULL
		AND 
		a.LAST_UPDATE_TYPE = 'I'
	OPTION (LABEL = 'ViolatorCallLogLookup_Stage_Load: INSERT INTO dbo.ViolatorCallLogLookup');
	

