CREATE PROC [dbo].[ViolatorStatusLetterBanLookup_Load] AS 

	DECLARE @LAST_UPDATE_DATE datetime2(2) 
	exec dbo.GetLoadStartDatetime 'LND_TER.dbo.ViolatorStatusLetterBanLookup', @LAST_UPDATE_DATE OUTPUT

	IF OBJECT_ID('dbo.ViolatorStatusLetterBanLookup_Stage')>0
		DROP TABLE dbo.ViolatorStatusLetterBanLookup_Stage

	CREATE TABLE dbo.ViolatorStatusLetterBanLookup_Stage WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (ViolatorStatusLetterBanLookupID)) 
	AS 
	SELECT  ViolatorStatusLetterBanLookupID, Descr, LAST_UPDATE_TYPE, LAST_UPDATE_DATE
	FROM LND_TER.dbo.ViolatorStatusLetterBanLookup A
	WHERE A.LAST_UPDATE_DATE >= @LAST_UPDATE_DATE 
	OPTION (LABEL = 'ViolatorStatusLetterBanLookup_Stage_Load: ViolatorStatusLetterBanLookup_Stage');

	CREATE STATISTICS STATS_ViolatorStatusLetterBanLookup_Stage_001 ON ViolatorStatusLetterBanLookup_Stage (ViolatorStatusLetterBanLookupID)

	UPDATE dbo.ViolatorStatusLetterBanLookup
	SET	 Descr = b.Descr
		,LAST_UPDATE_DATE = b.LAST_UPDATE_DATE
	FROM dbo.ViolatorStatusLetterBanLookup_Stage b 
	WHERE 
		ViolatorStatusLetterBanLookup.ViolatorStatusLetterBanLookupID = b.ViolatorStatusLetterBanLookupID
		AND 
		b.LAST_UPDATE_TYPE = 'U'
	OPTION (LABEL = 'ViolatorStatusLetterBanLookup_Stage_Load: UPDATE dbo.ViolatorStatusLetterBanLookup');

	INSERT INTO dbo.ViolatorStatusLetterBanLookup (ViolatorStatusLetterBanLookupID, Descr, INSERT_DATE, LAST_UPDATE_DATE)
	SELECT a.ViolatorStatusLetterBanLookupID, a.Descr, a.LAST_UPDATE_DATE, a.LAST_UPDATE_DATE
	FROM dbo.ViolatorStatusLetterBanLookup_Stage a
	LEFT JOIN dbo.ViolatorStatusLetterBanLookup b 
		ON  a.ViolatorStatusLetterBanLookupID = b.ViolatorStatusLetterBanLookupID
	WHERE 
		b.ViolatorStatusLetterBanLookupID IS NULL
		AND 
		a.LAST_UPDATE_TYPE = 'I'
	OPTION (LABEL = 'ViolatorStatusLetterBanLookup_Stage_Load: INSERT INTO dbo.ViolatorStatusLetterBanLookup');
	

