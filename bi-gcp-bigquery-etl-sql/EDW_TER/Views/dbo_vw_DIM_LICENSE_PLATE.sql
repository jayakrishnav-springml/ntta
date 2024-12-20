CREATE VIEW [dbo].[vw_DIM_LICENSE_PLATE] AS select	
	  A.LICENSE_PLATE_ID	as LicensePlateID
	, A.LICENSE_PLATE_NBR	as LicensePlateNumber
	, A.LICENSE_PLATE_STATE	as LicensePlateState
	, B.StateLookupID	as LicensePlateStateId
from dbo.DIM_LICENSE_PLATE A
LEFT JOIN dbo.StateLookup B ON A.LICENSE_PLATE_STATE = B.StateCode;
