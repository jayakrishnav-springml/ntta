CREATE PROC [dbo].[BanOfficerLookup_Load] AS 

	DECLARE @LAST_UPDATE_DATE datetime2(2) 
	exec dbo.GetLoadStartDatetime 'LND_TER.dbo.BanOfficerLookup', @LAST_UPDATE_DATE OUTPUT

	IF OBJECT_ID('dbo.BanOfficerLookup_Stage')>0
		DROP TABLE dbo.BanOfficerLookup_Stage

	CREATE TABLE dbo.BanOfficerLookup_Stage WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (BanOfficerLookupID)) 
	AS 
	SELECT 
	   BanOfficerLookupID, LastName, FirstName, PhoneNbr, RadioNbr
	 , Unit, Registration, PatrolCar, Area
	 , LAST_UPDATE_TYPE, LAST_UPDATE_DATE
	FROM LND_TER.dbo.BanOfficerLookup A
	WHERE A.LAST_UPDATE_DATE >= @LAST_UPDATE_DATE 
	OPTION (LABEL = 'BanOfficerLookup_Stage_Load: BanOfficerLookup_Stage');

	CREATE STATISTICS STATS_BanOfficerLookup_Stage_001 ON BanOfficerLookup_Stage (BanOfficerLookupID)

	UPDATE dbo.BanOfficerLookup
	SET	  dbo.BanOfficerLookup.BanOfficerLookupID = B.BanOfficerLookupID
		, dbo.BanOfficerLookup.LastName = B.LastName
		, dbo.BanOfficerLookup.FirstName = B.FirstName
		, dbo.BanOfficerLookup.PhoneNbr = B.PhoneNbr
		, dbo.BanOfficerLookup.RadioNbr = B.RadioNbr
		, dbo.BanOfficerLookup.Unit = B.Unit
		, dbo.BanOfficerLookup.Registration = B.Registration
		, dbo.BanOfficerLookup.PatrolCar = B.PatrolCar
		, dbo.BanOfficerLookup.Area = B.Area
		, dbo.BanOfficerLookup.LAST_UPDATE_DATE = B.LAST_UPDATE_DATE
	FROM dbo.BanOfficerLookup_Stage b 
	WHERE 
		BanOfficerLookup.BanOfficerLookupID = b.BanOfficerLookupID
		AND 
		b.LAST_UPDATE_TYPE = 'U'
	OPTION (LABEL = 'BanOfficerLookup_Stage_Load: UPDATE dbo.BanOfficerLookup');


	INSERT INTO dbo.BanOfficerLookup 
		( BanOfficerLookupID, LastName, FirstName, PhoneNbr, RadioNbr
		 , Unit, Registration, PatrolCar, Area
		 , INSERT_DATE, LAST_UPDATE_DATE)
	SELECT a.BanOfficerLookupID, a.LastName, a.FirstName, a.PhoneNbr, a.RadioNbr
		 , a.Unit, a.Registration, a.PatrolCar, a.Area
		 , a.LAST_UPDATE_DATE, a.LAST_UPDATE_DATE
	FROM dbo.BanOfficerLookup_Stage a
	LEFT JOIN dbo.BanOfficerLookup b 
		ON  a.BanOfficerLookupID = b.BanOfficerLookupID
	WHERE 
		b.BanOfficerLookupID IS NULL
		AND 
		a.LAST_UPDATE_TYPE = 'I'
	OPTION (LABEL = 'BanOfficerLookup_Stage_Load: INSERT INTO dbo.BanOfficerLookup');
	

