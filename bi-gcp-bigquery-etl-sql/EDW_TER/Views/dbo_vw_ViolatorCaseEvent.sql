CREATE VIEW [dbo].[vw_ViolatorCaseEvent] AS SELECT 
	  ID, ViolatorID, VidSeq, LicPlateNbr, LicPlateStateLookupID, VEHICLE_ID
	, DocNum, Vin, PrimaryViolatorFname, PrimaryViolatorLname
	, SecondaryViolatorFname, SecondaryViolatorLname
	, DriversLicense, DriversLicenseStateLookupID
	, SecondaryDriversLicense, SecondaryDriversLicenseStateLookupID
	, EarliestHvTranDate, LatestHvTranDate
	, AdminCountyLookupID, RegistrationCountyLookupID
	, RegistrationDateNextMonth, RegistrationDateNextYear, ViolatorAgencyLookupID	
	, ISNULL(ViolatorAddressSourceLookupID,-1) AS ViolatorAddressSourceLookupID 
	, ISNULL(ViolatorAddressStatusLookupID,-1) AS ViolatorAddressStatusLookupID
	, ViolatorAddressActiveFlag
	, ViolatorAddressConfirmedFlag
	, ViolatorAddress1
	, ViolatorAddress2
	, ViolatorAddressCity
	, ViolatorAddressStateLookupID
	, ViolatorAddressZipCode
	, ViolatorAddressPlus4
--	, INSERT_DATE
FROM dbo.Violator;
