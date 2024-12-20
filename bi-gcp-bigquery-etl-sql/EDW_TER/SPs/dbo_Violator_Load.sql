CREATE PROC [dbo].[Violator_Load] AS

	UPDATE dbo.Violator  
		SET 
		--  dbo.Violator.ID = B.ID,--03/31/2017 TER Removed these Columns
		  dbo.Violator.LicPlateNbr = B.LicPlateNbr
		, dbo.Violator.LicPlateStateLookupID = B.LicPlateStateLookupID
		, dbo.Violator.VEHICLE_ID = B.VEHICLE_ID
		, dbo.Violator.DocNum = B.DocNum
		, dbo.Violator.Vin = B.Vin
		, dbo.Violator.PrimaryViolatorFname = B.PrimaryViolatorFname
		, dbo.Violator.PrimaryViolatorLname = B.PrimaryViolatorLname
		, dbo.Violator.SecondaryViolatorFname = B.SecondaryViolatorFname
		, dbo.Violator.SecondaryViolatorLname = B.SecondaryViolatorLname
		, dbo.Violator.DriversLicense = B.DriversLicense
		, dbo.Violator.DriversLicenseStateLookupID = B.DriversLicenseStateLookupID
		, dbo.Violator.SecondaryDriversLicense = B.SecondaryDriversLicense
		, dbo.Violator.SecondaryDriversLicenseStateLookupID = B.SecondaryDriversLicenseStateLookupID
		, dbo.Violator.EarliestHvTranDate = B.EarliestHvTranDate
		, dbo.Violator.LatestHvTranDate = B.LatestHvTranDate
		, dbo.Violator.AdminCountyLookupID = B.AdminCountyLookupID
		, dbo.Violator.RegistrationCountyLookupID = B.RegistrationCountyLookupID
		, dbo.Violator.RegistrationDateNextMonth = B.RegistrationDateNextMonth
		, dbo.Violator.RegistrationDateNextYear = B.RegistrationDateNextYear
		, dbo.Violator.ViolatorAgencyLookupID = B.ViolatorAgencyLookupID
		, dbo.Violator.ViolatorAddressSourceLookupID = B.ViolatorAddressSourceLookupID
		, dbo.Violator.ViolatorAddressStatusLookupID = B.ViolatorAddressStatusLookupID
		, dbo.Violator.ViolatorAddressActiveFlag = B.ActiveFlag
		, dbo.Violator.ViolatorAddressConfirmedFlag = B.ConfirmedFlag
		, dbo.Violator.ViolatorAddress1 = B.Address1
		, dbo.Violator.ViolatorAddress2 = B.Address2
		, dbo.Violator.ViolatorAddressCity = B.City
		, dbo.Violator.ViolatorAddressStateLookupID = B.StateLookupID
		, dbo.Violator.ViolatorAddressZipCode = B.ZipCode
		, dbo.Violator.ViolatorAddressPlus4 = B.Plus4
		, dbo.Violator.ViolatorAddressCreatedBy = B.ViolatorAddressCreatedBy
		, dbo.Violator.ViolatorAddressCreateDate = B.ViolatorAddressCreateDate
		, dbo.Violator.ViolatorAddressUpdatedBy = B.ViolatorAddressUpdatedBy
		, dbo.Violator.ViolatorAddressUpdateDate = B.ViolatorAddressUpdateDate
		--, dbo.Violator.LAST_UPDATE_DATE = CASE WHEN B.VIOLATOR_LAST_UPDATE_DATE < B.ViolAddr_LAST_UPDATE_DATE THEN B.VIOLATOR_LAST_UPDATE_DATE ELSE B.ViolAddr_LAST_UPDATE_DATE END --03/31/2017 TER Removed these Columns
		, dbo.Violator.LAST_UPDATE_DATE = B.ViolAddr_LAST_UPDATE_DATE 
	FROM dbo.Violator_Stage_With_Vehicle_Id B
	WHERE 
		dbo.Violator.ViolatorId = B.ViolatorId AND dbo.Violator.VidSeq = B.VidSeq
		--AND --03/31/2017 TER Removed these Columns
		--(VIOLATOR_LAST_UPDATE_TYPE = 'U' OR ViolAddr_LAST_UPDATE_TYPE = 'U')


	INSERT INTO DBO.Violator
		(
			   ID, ViolatorID, VidSeq
			, CURRENT_IND, HV_NON_HV_IND
			, LicPlateNbr, LicPlateStateLookupID
			, VEHICLE_ID, DocNum, Vin, PrimaryViolatorFname, PrimaryViolatorLname
			, SecondaryViolatorFname, SecondaryViolatorLname
			, DriversLicense, DriversLicenseStateLookupID
			, SecondaryDriversLicense, SecondaryDriversLicenseStateLookupID
			, EarliestHvTranDate, LatestHvTranDate
			, AdminCountyLookupID, RegistrationCountyLookupID
			, RegistrationDateNextMonth, RegistrationDateNextYear
			, ViolatorAgencyLookupID
			, ViolatorAddressSourceLookupID
			, ViolatorAddressStatusLookupID
			, ViolatorAddressActiveFlag
			, ViolatorAddressConfirmedFlag
			, ViolatorAddress1
			, ViolatorAddress2
			, ViolatorAddressCity
			, ViolatorAddressStateLookupID
			, ViolatorAddressZipCode
			, ViolatorAddressPlus4
			, ViolatorAddressCreatedBy
			, ViolatorAddressCreateDate
			, ViolatorAddressUpdatedBy
			, ViolatorAddressUpdateDate
			, INSERT_DATE
			, LAST_UPDATE_DATE
			)
	-- EXPLAIN
	SELECT   ROW_NUMBER() OVER(ORDER BY A.ViolatorID ASC) + (SELECT MAX(ID) FROM DBO.Violator) ,
			  --A.ID, --03/31/2017 TER Removed these Columns
			  A.ViolatorID, A.VidSeq
			, 0 AS CURRENT_IND, 1 AS HV_NON_HV_IND
			, A.LicPlateNbr, A.LicPlateStateLookupID
			, A.VEHICLE_ID, A.DocNum, A.Vin, A.PrimaryViolatorFname, A.PrimaryViolatorLname
			, A.SecondaryViolatorFname, A.SecondaryViolatorLname
			, A.DriversLicense, A.DriversLicenseStateLookupID
			, A.SecondaryDriversLicense, A.SecondaryDriversLicenseStateLookupID
			, A.EarliestHvTranDate, A.LatestHvTranDate
			, A.AdminCountyLookupID, A.RegistrationCountyLookupID
			, A.RegistrationDateNextMonth, A.RegistrationDateNextYear
			, A.ViolatorAgencyLookupID
			, A.ViolatorAddressSourceLookupID
			, A.ViolatorAddressStatusLookupID
			, A.ActiveFlag
			, A.ConfirmedFlag
			, A.Address1
			, A.Address2
			, A.City
			, A.StateLookupID
			, A.ZipCode
			, A.Plus4
			, A.ViolatorAddressCreatedBy
			, A.ViolatorAddressCreateDate
			, A.ViolatorAddressUpdatedBy
			, A.ViolatorAddressUpdateDate
			, INSERT_DATE = A.ViolAddr_LAST_UPDATE_DATE--CASE WHEN A.VIOLATOR_LAST_UPDATE_DATE < A.ViolAddr_LAST_UPDATE_DATE THEN A.VIOLATOR_LAST_UPDATE_DATE ELSE A.ViolAddr_LAST_UPDATE_DATE END 
			, LAST_UPDATE_DATE = A.ViolAddr_LAST_UPDATE_DATE--CASE WHEN A.VIOLATOR_LAST_UPDATE_DATE < A.ViolAddr_LAST_UPDATE_DATE THEN A.VIOLATOR_LAST_UPDATE_DATE ELSE A.ViolAddr_LAST_UPDATE_DATE END 
	FROM dbo.Violator_Stage_With_Vehicle_Id A
	LEFT JOIN DBO.Violator B ON A.ViolatorID = B.ViolatorID AND A.VidSeq = B.VidSeq
	WHERE 
		B.ViolatorID IS NULL AND B.VidSeq IS NULL
		--AND 
		--(VIOLATOR_LAST_UPDATE_TYPE = 'I' OR ViolAddr_LAST_UPDATE_TYPE = 'I')


		
	IF OBJECT_ID('dbo.Violator_Stage_Current')>0
		DROP TABLE dbo.Violator_Stage_Current

	CREATE TABLE dbo.Violator_Stage_Current WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (ViolatorID, VidSeq)) 
	AS 
		SELECT A.ViolatorID, A.VidSeq, CASE WHEN B.VidSeq IS NULL THEN 0 ELSE 1 END AS CURRENT_IND
		FROM dbo.Violator A
		LEFT JOIN 
			(
				SELECT ViolatorID, MAX(VidSeq) AS VidSeq
				FROM dbo.Violator A
				GROUP BY ViolatorID
			)
			 B ON A.ViolatorID = B.ViolatorID AND A.VidSeq = B.VidSeq

	UPDATE 	dbo.Violator
		SET CURRENT_IND = B.CURRENT_IND
	FROM dbo.Violator_Stage_Current B 
	WHERE dbo.Violator.ViolatorID = B.ViolatorID AND dbo.Violator.VidSeq = B.VidSeq

	

	IF OBJECT_ID('dbo.VIOLATOR_ADDRESS_AUDIT_STAGE')>0
	DROP TABLE dbo.VIOLATOR_ADDRESS_AUDIT_STAGE

	CREATE TABLE dbo.VIOLATOR_ADDRESS_AUDIT_STAGE WITH (DISTRIBUTION = HASH(VIOLATOR_ID), CLUSTERED INDEX (VIOLATOR_ID)) 
	AS 
	-- EXPLAIN 
	SELECT DISTINCT A.VIOLATOR_ID, VIOLATOR_ADDR_SEQ, ADDRESS1, ADDRESS2, CITY, [STATE], ZIP_CODE, PLUS4
		, CREATED_BY, DATE_CREATED, MODIFIED_BY, DATE_MODIFIED
	FROM LND_LG_VPS.[VP_OWNER].[VIOLATOR_ADDRESS] A
	INNER JOIN dbo.Violator B ON A.VIOLATOR_ID = B.ViolatorId 
		AND A.ADDRESS1 = B.ViolatorAddress1 AND A.CITY = B.ViolatorAddressCity
		AND A.ZIP_CODE = B.ViolatorAddressZipCode
	OPTION (LABEL = 'VIOLATOR_ADDRESS_AUDIT_STAGE_LOAD: VIOLATOR_ADDRESS_AUDIT_STAGE');

	CREATE STATISTICS STATS_VIOLATOR_ADDRESS_AUDIT_STAGE_001 ON VIOLATOR_ADDRESS_AUDIT_STAGE (VIOLATOR_ID)

	UPDATE dbo.Violator
		SET  ViolatorAddressCreatedBy = B.CREATED_BY
			,ViolatorAddressCreateDate = B.DATE_CREATED
			,ViolatorAddressUpdatedBy = B.MODIFIED_BY
			,ViolatorAddressUpdateDate = B.DATE_MODIFIED
	FROM dbo.VIOLATOR_ADDRESS_AUDIT_STAGE B
	WHERE dbo.Violator.ViolatorId = B.VIOLATOR_ID
	AND 
		(
			   ViolatorAddressCreatedBy <> B.CREATED_BY
			OR ViolatorAddressCreateDate <> B.DATE_CREATED
			OR ViolatorAddressUpdatedBy <> B.MODIFIED_BY
			OR ViolatorAddressUpdateDate <> B.DATE_MODIFIED
		) 






