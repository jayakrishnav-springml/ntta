CREATE VIEW [dbo].[vw_Ban_BanOfficerLookup] AS SELECT  
	     BanOfficerLookupID
	   , LastName
	   , FirstName
	   , PhoneNbr
	   , RadioNbr
	   , Unit
	   , Registration
	   , PatrolCar
	   , Area
FROM dbo.BanOfficerLookup;
