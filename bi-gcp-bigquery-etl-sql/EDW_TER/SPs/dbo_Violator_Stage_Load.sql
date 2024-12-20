CREATE PROC [dbo].[Violator_Stage_Load] AS 

DECLARE @LAST_UPDATE_DATE datetime2(2) 
exec dbo.GetLoadStartDatetime 'dbo.Violator', @LAST_UPDATE_DATE OUTPUT

IF OBJECT_ID('dbo.Violator_Stage')>0
	DROP TABLE dbo.Violator_Stage

CREATE TABLE dbo.Violator_Stage WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (ViolatorID, VidSeq)) 
AS 
SELECT 
   --ID, --03/31/2017 TER Removed these Columns
   V.ViolatorID, V.VidSeq, LicPlateNbr, LicPlateStateLookupID
 , ISNULL(VehicleMake,'(Null)') AS VehicleMake, ISNULL(VehicleModel,'(Null)') AS VehicleModel, ISNULL(VehicleYear,'(Null)') AS VehicleYear
 , DocNum, Vin, PrimaryViolatorFname, PrimaryViolatorLname
 , SecondaryViolatorFname, SecondaryViolatorLname
 , DriversLicense, DriversLicenseStateLookupID
 , SecondaryDriversLicense, SecondaryDriversLicenseStateLookupID
 , EarliestHvTranDate, LatestHvTranDate
 , AdminCountyLookupID, RegistrationCountyLookupID, ISNULL(RegistrationDateNextMonth,-1) AS RegistrationDateNextMonth
 , ISNULL(RegistrationDateNextYear,-1) AS RegistrationDateNextYear, ViolatorAgencyLookupID
 , ViolatorAddressSourceLookupID, ViolatorAddressStatusLookupID
 , ActiveFlag, ConfirmedFlag
 , Address1, Address2, City
 , StateLookupID, ZipCode, Plus4
 , VA.CreatedDate as ViolatorAddressCreateDate
 , VA.CreatedBy as ViolatorAddressCreatedBy
 , VA.UpdatedDate as ViolatorAddressUpdateDate
 , VA.UpdatedBy as ViolatorAddressUpdatedBy
 --, V.LAST_UPDATE_TYPE AS VIOLATOR_LAST_UPDATE_TYPE, V.LAST_UPDATE_DATE As VIOLATOR_LAST_UPDATE_DATE--03/31 TER Removed these Columns
 , VA.LAST_UPDATE_TYPE AS ViolAddr_LAST_UPDATE_TYPE, VA.LAST_UPDATE_DATE As ViolAddr_LAST_UPDATE_DATE
 
 FROM LND_TER.dbo.Violator V
 INNER JOIN 
	(
		SELECT VA1.* FROM LND_TER.dbo.ViolatorAddress VA1
		INNER JOIN 
			(
			 SELECT MAX(ViolatorAddressId) AS ViolatorAddressId, ViolatorId, VidSeq
			 FROM LND_TER.dbo.ViolatorAddress VA2
			 GROUP BY ViolatorId, VidSeq
			) LastAddr
		ON LastAddr.ViolatorAddressId = VA1.ViolatorAddressId
	) VA
	ON V.ViolatorID = VA.ViolatorID AND V.VidSeq = VA.VidSeq
  --WHERE V.LAST_UPDATE_DATE >= @LAST_UPDATE_DATE 
		--OR 
		--VA.LAST_UPDATE_DATE >= @LAST_UPDATE_DATE 
  OPTION (LABEL = 'Violator_Stage_LOAD: Violator_Stage');

CREATE STATISTICS STATS_Violator_Stage_LOAD_001 ON dbo.Violator_Stage (ViolatorID, VidSeq)

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- DIM_VEHICLE NEW ROWS NEVER UPDATE 
--		THIS Dimension is Add Only
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
DECLARE @MAX_VEHICLE_ID int = ISNULL((SELECT MAX(VEHICLE_ID) FROM DBO.DIM_VEHICLE),1);

INSERT INTO DBO.DIM_VEHICLE (VEHICLE_ID, VEHICLE_MAKE, VEHICLE_MODEL, VEHICLE_YEAR, INSERT_DATETIME)
SELECT ROW_NUMBER()OVER(ORDER BY (SELECT 1))+ @MAX_VEHICLE_ID, VehicleMake, VehicleModel, VehicleYEAR, GETDATE() AS INSERT_DATETIME
FROM 
(
	SELECT DISTINCT VehicleMake, VehicleModel, VehicleYEAR
	FROM dbo.Violator_Stage
) A
LEFT JOIN DBO.DIM_VEHICLE B
	ON A.VehicleMake = B.VEHICLE_MAKE AND A.VehicleModel = B.VEHICLE_MODEL AND A.VehicleYEAR = B.VEHICLE_YEAR
WHERE 
	B.VEHICLE_MAKE IS NULL AND B.VEHICLE_MODEL IS NULL AND B.VEHICLE_YEAR IS NULL
OPTION (LABEL = 'Violator_Stage_LOAD: INSERT INTO DBO.DIM_VEHICLE');

UPDATE STATISTICS DBO.DIM_VEHICLE WITH FULLSCAN;


-- -- -- -- -- -- -- -- -- -- -- 
-- DIM_MONTH NEW ROWS NEVER UPDATE 
--		THIS Dimension is Add Only
-- -- -- -- -- -- -- -- -- -- -- 
INSERT INTO DBO.DIM_MONTH (MONTH_ID, [MONTH], INSERT_DATETIME)
SELECT DISTINCT
	  RegistrationDateNextMonth
	, RIGHT('00'+ convert(varchar(15),RegistrationDateNextMonth),2)
	, GETDATE() AS INSERT_DATETIME
FROM dbo.Violator_Stage A
LEFT JOIN DBO.DIM_MONTH B
	ON A.RegistrationDateNextMonth = B.MONTH_ID 
WHERE B.MONTH_ID IS NULL AND A.RegistrationDateNextMonth IS NOT NULL
OPTION (LABEL = 'Violator_Stage_WITH_VEHICLE_ID_LOAD: DIM_MONTH');

UPDATE STATISTICS DBO.DIM_MONTH WITH FULLSCAN;


-- -- -- -- -- -- -- -- -- -- -- 
-- DIM_YEAR NEW ROWS NEVER UPDATE 
--		THIS Dimension is Add Only
-- -- -- -- -- -- -- -- -- -- -- 
INSERT INTO DBO.DIM_YEAR (YEAR_ID, [YEAR], INSERT_DATETIME)
SELECT DISTINCT
	  RegistrationDateNextYEAR
	, convert(varchar(15),RegistrationDateNextYear)
	, GETDATE() AS INSERT_DATETIME
FROM dbo.Violator_Stage A
LEFT JOIN DBO.DIM_YEAR B
	ON A.RegistrationDateNextYEAR = B.YEAR_ID 
WHERE B.YEAR_ID IS NULL AND A.RegistrationDateNextYear IS NOT NULL
OPTION (LABEL = 'Violator_Stage_WITH_VEHICLE_ID_LOAD: DIM_YEAR');

UPDATE STATISTICS DBO.DIM_YEAR WITH FULLSCAN;


-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --
-- FINAL Violator_Stage WITH VEHICLE ID  
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

IF OBJECT_ID('dbo.Violator_Stage_WITH_VEHICLE_ID')>0
	DROP TABLE dbo.Violator_Stage_WITH_VEHICLE_ID

CREATE TABLE dbo.Violator_Stage_WITH_VEHICLE_ID WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (ViolatorID, VidSeq)) 
AS 
SELECT 
	   --ID, --03/31/2017 TER Removed these Columns
	   ViolatorID, VidSeq, LicPlateNbr, LicPlateStateLookupID
	 , B.VEHICLE_ID
	 , DocNum, Vin, PrimaryViolatorFname, PrimaryViolatorLname
	 , SecondaryViolatorFname, SecondaryViolatorLname
	 , DriversLicense, DriversLicenseStateLookupID
	 , SecondaryDriversLicense, SecondaryDriversLicenseStateLookupID
	 , EarliestHvTranDate, LatestHvTranDate
	 , AdminCountyLookupID, RegistrationCountyLookupID, RegistrationDateNextMonth
	 , RegistrationDateNextYear, ViolatorAgencyLookupID
	 , ViolatorAddressSourceLookupID, ViolatorAddressStatusLookupID
	 , ActiveFlag, ConfirmedFlag
	 , Address1, Address2, City
	 , StateLookupID, ZipCode, Plus4
	 , ViolatorAddressCreatedBy, ViolatorAddressCreateDate
	 , ViolatorAddressUpdatedBy, ViolatorAddressUpdateDate
	 --, VIOLATOR_LAST_UPDATE_TYPE, VIOLATOR_LAST_UPDATE_DATE--03/31/2017 TER Removed these Columns
	 , ViolAddr_LAST_UPDATE_TYPE, ViolAddr_LAST_UPDATE_DATE
-- select COUNT(*) 
FROM dbo.Violator_Stage A
INNER JOIN dbo.DIM_VEHICLE B ON A.VehicleMake = B.VEHICLE_MAKE AND A.VehicleModel = B.VEHICLE_MODEL AND A.VehicleYear = B.VEHICLE_YEAR
OPTION (LABEL = 'Violator_Stage_WITH_VEHICLE_ID_LOAD: Violator_Stage_WITH_VEHICLE_ID');

CREATE STATISTICS STATS_Violator_Stage_WITH_VEHICLE_ID_LOAD_001 ON dbo.Violator_Stage_WITH_VEHICLE_ID (ViolatorID, VidSeq)



