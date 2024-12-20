CREATE VIEW [dbo].[vw_Fact_VRB] AS SELECT V.VRBID,
       V.HVID,
       V.CustomerID,
       V.VehicleID,	
       V.VRBStatusID,
	   V.VRBAgencyID,
	   V.VRBRejectReasonID,
	   V.VRBRemovalReasonID,
	   VRBLetterDeliverStatusID,
	   
	   HV.LicensePlateNumber,
	   HV.LicensePlateState,	
	   DV.County VehicleRegistrationCounty,   
	   DC.State ViolatorState,
	   DC.ZipCode ViolatorZip,
	   
	   VS.VRBStatusDescription,
	   A.VRBAgencyDescription,     
	   RjR.VRBRejectReasonDescription,       
	   RR.VRBRemovalReasonDescription,       
       LetterDeliverStatusDesc,
	   HV.HVDeterminationdate HVDeterminationdate,
	   HV.HVTerminationdate,
	   CAST( CAST( VRBRequesteddayID AS char(8)) AS date ) VRBRequesteddate,
	   CAST( CAST( VRBAppliedDayID AS char(8)) AS date ) VRBApplieddate,
       CAST( CAST( VRBRemovedDayID AS char(8)) AS date ) VRBRemoveddate,
       VRBCreatedDate,
       VRBLetterMailedDate,
       VRBLetterDeliveredDate,
       V.EDW_UpdateDate 
FROM dbo.Fact_VRB V 
JOIN dbo.dim_habitualViolator HV ON HV.HVID=V.HVID
LEFT JOIN dbo.dim_TER_Letterdeliverstatus LDS ON V.VRBLetterDeliverStatusID=LDS.LetterDeliverStatusID
LEFT JOIN dbo.dim_VRBRemovalReason RR ON RR.VRBRemovalreasonID=V.VRBRemovalReasonID
LEFT JOIN dbo.dim_VRBRejectReason RjR ON RjR.VRBRejectreasonID=V.VRBRejectReasonID
LEFT JOIN dbo.dim_VRBAgency A ON A.VRBAgencyID=V.VRBAgencyID
LEFT JOIN dbo.dim_VRBStatus VS ON VS.VRBStatusID=V.VRBStatusID
LEFT JOIN dbo.dim_vehicle DV ON DV.VehicleID = HV.VehicleID
LEFT JOIN dbo.Dim_Customer DC ON DC.CustomerID = HV.CustomerID;
