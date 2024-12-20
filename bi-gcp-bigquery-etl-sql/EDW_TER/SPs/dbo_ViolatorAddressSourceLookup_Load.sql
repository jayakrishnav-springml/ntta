CREATE PROC [dbo].[ViolatorAddressSourceLookup_Load] AS 

	DECLARE @LAST_UPDATE_DATE datetime2(2) 
	exec dbo.GetLoadStartDatetime 'LND_TER.dbo.ViolatorAddressSourceLookup', @LAST_UPDATE_DATE OUTPUT

	IF OBJECT_ID('dbo.ViolatorAddressSourceLookup_Stage')>0
		DROP TABLE dbo.ViolatorAddressSourceLookup_Stage

	CREATE TABLE dbo.ViolatorAddressSourceLookup_Stage WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (ViolatorAddressSourceLookupID)) 
	AS 
	SELECT  ViolatorAddressSourceLookupID, Descr, LAST_UPDATE_TYPE, LAST_UPDATE_DATE
	FROM LND_TER.dbo.ViolatorAddressSourceLookup A
	WHERE A.LAST_UPDATE_DATE >= @LAST_UPDATE_DATE 
	OPTION (LABEL = 'ViolatorAddressSourceLookup_Stage_Load: ViolatorAddressSourceLookup_Stage');

	CREATE STATISTICS STATS_ViolatorAddressSourceLookup_Stage_001 ON ViolatorAddressSourceLookup_Stage (ViolatorAddressSourceLookupID)

	UPDATE dbo.ViolatorAddressSourceLookup
	SET	 Descr = b.Descr
		,LAST_UPDATE_DATE = b.LAST_UPDATE_DATE
	FROM dbo.ViolatorAddressSourceLookup_Stage b 
	WHERE 
		ViolatorAddressSourceLookup.ViolatorAddressSourceLookupID = b.ViolatorAddressSourceLookupID
		AND 
		b.LAST_UPDATE_TYPE = 'U'
	OPTION (LABEL = 'ViolatorAddressSourceLookup_Stage_Load: UPDATE dbo.ViolatorAddressSourceLookup');

	INSERT INTO dbo.ViolatorAddressSourceLookup (ViolatorAddressSourceLookupID, Descr, INSERT_DATE, LAST_UPDATE_DATE)
	SELECT a.ViolatorAddressSourceLookupID, a.Descr, a.LAST_UPDATE_DATE, a.LAST_UPDATE_DATE
	FROM dbo.ViolatorAddressSourceLookup_Stage a
	LEFT JOIN dbo.ViolatorAddressSourceLookup b 
		ON  a.ViolatorAddressSourceLookupID = b.ViolatorAddressSourceLookupID
	WHERE 
		b.ViolatorAddressSourceLookupID IS NULL
		AND 
		a.LAST_UPDATE_TYPE = 'I'
	OPTION (LABEL = 'ViolatorAddressSourceLookup_Stage_Load: INSERT INTO dbo.ViolatorAddressSourceLookup');
	

