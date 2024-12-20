CREATE PROC [dbo].[ViolatorStatusEligRmdyLookup_Load] AS 

	DECLARE @LAST_UPDATE_DATE datetime2(2) 
	exec dbo.GetLoadStartDatetime 'LND_TER.dbo.ViolatorStatusEligRmdyLookup', @LAST_UPDATE_DATE OUTPUT

	IF OBJECT_ID('dbo.ViolatorStatusEligRmdyLookup_Stage')>0
		DROP TABLE dbo.ViolatorStatusEligRmdyLookup_Stage

	CREATE TABLE dbo.ViolatorStatusEligRmdyLookup_Stage WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (ViolatorStatusEligRmdyLookupID)) 
	AS 
	SELECT  ViolatorStatusEligRmdyLookupID, Descr, LAST_UPDATE_TYPE, LAST_UPDATE_DATE
	FROM LND_TER.dbo.ViolatorStatusEligRmdyLookup A
	WHERE A.LAST_UPDATE_DATE >= @LAST_UPDATE_DATE 
	OPTION (LABEL = 'ViolatorStatusEligRmdyLookup_Stage_Load: ViolatorStatusEligRmdyLookup_Stage');

	CREATE STATISTICS STATS_ViolatorStatusEligRmdyLookup_Stage_001 ON ViolatorStatusEligRmdyLookup_Stage (ViolatorStatusEligRmdyLookupID)

	UPDATE dbo.ViolatorStatusEligRmdyLookup
	SET	 Descr = b.Descr
		,LAST_UPDATE_DATE = b.LAST_UPDATE_DATE
	FROM dbo.ViolatorStatusEligRmdyLookup_Stage b 
	WHERE 
		ViolatorStatusEligRmdyLookup.ViolatorStatusEligRmdyLookupID = b.ViolatorStatusEligRmdyLookupID
		AND 
		b.LAST_UPDATE_TYPE = 'U'
	OPTION (LABEL = 'ViolatorStatusEligRmdyLookup_Stage_Load: UPDATE dbo.ViolatorStatusEligRmdyLookup');

	INSERT INTO dbo.ViolatorStatusEligRmdyLookup (ViolatorStatusEligRmdyLookupID, Descr, INSERT_DATE, LAST_UPDATE_DATE)
	SELECT a.ViolatorStatusEligRmdyLookupID, a.Descr, a.LAST_UPDATE_DATE, a.LAST_UPDATE_DATE
	FROM dbo.ViolatorStatusEligRmdyLookup_Stage a
	LEFT JOIN dbo.ViolatorStatusEligRmdyLookup b 
		ON  a.ViolatorStatusEligRmdyLookupID = b.ViolatorStatusEligRmdyLookupID
	WHERE 
		b.ViolatorStatusEligRmdyLookupID IS NULL
		AND 
		a.LAST_UPDATE_TYPE = 'I'
	OPTION (LABEL = 'ViolatorStatusEligRmdyLookup_Stage_Load: INSERT INTO dbo.ViolatorStatusEligRmdyLookup');
	

