CREATE VIEW [dbo].[vw_ViolationLicensePlate] AS SELECT  
      LICENSE_PLATE_ID			AS ViolationLicensePlateID
    , LICENSE_PLATE_NBR			AS ViolationLicensePlateNbr
    , LICENSE_PLATE_STATE		AS ViolationLicensePlateState
FROM dbo.DIM_LICENSE_PLATE;
