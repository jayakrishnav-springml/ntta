CREATE PROC [dbo].[CountyLookup_Load] AS 

	DECLARE @LAST_UPDATE_DATE datetime2(2) 
	exec dbo.GetLoadStartDatetime 'LND_TER.dbo.CountyLookup', @LAST_UPDATE_DATE OUTPUT
--	select @LAST_UPDATE_DATE

	IF OBJECT_ID('dbo.CountyLookup_Stage')>0
		DROP TABLE dbo.CountyLookup_Stage

	CREATE TABLE dbo.CountyLookup_Stage WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (CountyLookupID)) 
	AS 
	SELECT  CountyLookupID, Descr
		,ParticipatingCounty
		, CASE WHEN a.Descr IN ('COLLIN','DALLAS','DENTON','ELLIS','GRAYSON','JOHNSON','ROCKKWALL','TARRANT') THEN a.Descr ELSE 'OTHER' END AS CountyGroup
--		, CASE WHEN ParticipatingCounty = 1 then 'Yes' ELSE 'No' END AS ParticipatingCounty
		, LAST_UPDATE_TYPE, LAST_UPDATE_DATE
	FROM LND_TER.dbo.CountyLookup A
	WHERE A.LAST_UPDATE_DATE >= @LAST_UPDATE_DATE 
	OPTION (LABEL = 'CountyLookup_Stage_Load: CountyLookup_Stage');

	CREATE STATISTICS STATS_CountyLookup_Stage_001 ON CountyLookup_Stage (CountyLookupID)
	
	UPDATE dbo.CountyLookup
	SET	 Descr = b.Descr
		,ParticipatingCounty = b.ParticipatingCounty
		,CountyGroup = b.CountyGroup
		,LAST_UPDATE_DATE = b.LAST_UPDATE_DATE
	FROM dbo.CountyLookup_Stage b 
	WHERE 
		CountyLookup.CountyLookupID = b.CountyLookupID
		AND 
		b.LAST_UPDATE_TYPE = 'U'
	OPTION (LABEL = 'CountyLookup_Stage_Load: UPDATE dbo.CountyLookup');

	INSERT INTO dbo.CountyLookup (CountyLookupID, Descr, ParticipatingCounty, CountyGroup, INSERT_DATE, LAST_UPDATE_DATE)
	SELECT 
		a.CountyLookupID, a.Descr, a.ParticipatingCounty
		, a.CountyGroup
		, a.LAST_UPDATE_DATE, a.LAST_UPDATE_DATE
	FROM dbo.CountyLookup_Stage a
	LEFT JOIN dbo.CountyLookup b 
		ON  a.CountyLookupID = b.CountyLookupID
	WHERE 
		b.CountyLookupID IS NULL
		AND 
		a.LAST_UPDATE_TYPE = 'I'
	OPTION (LABEL = 'CountyLookup_Stage_Load: INSERT INTO dbo.CountyLookup');
	

