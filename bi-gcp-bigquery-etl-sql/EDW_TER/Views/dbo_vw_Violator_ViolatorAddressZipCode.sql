CREATE VIEW [dbo].[vw_Violator_ViolatorAddressZipCode] AS SELECT 
	  ZIPCODE AS ViolatorAddressZipCode
	, ZIPCODE_LATITUDE As ViolatorAddressZipCode_Latitude
	, ZIPCODE_LONGITUDE As ViolatorAddressZipCode_Longitude
	, COUNTY
	, COUNTY_GROUP
FROM dbo.DIM_ZIPCODE

UNION ALL 

SELECT DISTINCT 
	  ViolatorAddressZipCode
	, 33.015926 As ViolatorAddressZipCode_Latitude
	, -96.823378 As ViolatorAddressZipCode_Longitude
	, '(Null)' AS COUNTY
	, '(Null)' AS COUNTY_GROUP
FROM dbo.Violator A
LEFT JOIN DIM_ZIPCODE B ON A.ViolatorADdressZipCode = B.ZIPCODE
WHERE B.ZIPCODE IS NULL;
