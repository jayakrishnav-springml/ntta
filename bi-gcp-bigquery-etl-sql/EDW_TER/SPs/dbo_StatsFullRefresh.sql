CREATE PROC [dbo].[StatsFullRefresh] AS

exec DropStats 'DIM_DATE'
CREATE STATISTICS STATS_DIM_DATE_001 ON [dbo].DIM_DATE (DATE, DATE_FULL)
CREATE STATISTICS STATS_DIM_DATE_002 ON [dbo].DIM_DATE (DATE,MONTH_WEEK)
CREATE STATISTICS STATS_DIM_DATE_003 ON [dbo].DIM_DATE (DATE,DATE_MONTH)
CREATE STATISTICS STATS_DIM_DATE_004 ON [dbo].DIM_DATE (DATE,DATE_YEAR_MONTH)
CREATE STATISTICS STATS_DIM_DATE_005 ON [dbo].DIM_DATE (DATE,DATE_QUARTER)
CREATE STATISTICS STATS_DIM_DATE_006 ON [dbo].DIM_DATE (DATE,DATE_YEAR)

 exec DropStats 'DIM_TIME' 
--  exec CreateStats 'DIM_TIME'
CREATE STATISTICS STATS_DIM_TIME_001 ON [dbo].DIM_TIME (TIME_ID)
CREATE STATISTICS STATS_DIM_TIME_002 ON [dbo].DIM_TIME (TIME_ID, HOUR)
CREATE STATISTICS STATS_DIM_TIME_003 ON [dbo].DIM_TIME (TIME_ID, MINUTE)
CREATE STATISTICS STATS_DIM_TIME_004 ON [dbo].DIM_TIME (TIME_ID, SECOND)

 exec DropStats 'CountyLookup'  
--exec CreateStats 'CountyLookup'
 
CREATE STATISTICS STATS_CountyLookup_001 ON [dbo].CountyLookup (CountyLookupID,Descr)
CREATE STATISTICS STATS_CountyLookup_002 ON [dbo].CountyLookup (CountyLookupID,ParticipatingCounty)

exec DropStats 'DIM_INDICATOR' 
-- exec CreateStats 'DIM_INDICATOR'
CREATE STATISTICS STATS_DIM_INDICATOR_001 ON [dbo].DIM_INDICATOR (INDICATOR_ID)
CREATE STATISTICS STATS_DIM_INDICATOR_002 ON [dbo].DIM_INDICATOR (INDICATOR_ID,YES_NO_ABBREV)
CREATE STATISTICS STATS_DIM_INDICATOR_003 ON [dbo].DIM_INDICATOR (INDICATOR_ID,INDICATOR)
 


exec DropStats 'DIM_VEHICLE' 
-- exec CreateStats 'DIM_VEHICLE'
CREATE STATISTICS STATS_DIM_VEHICLE_001 ON [dbo].DIM_VEHICLE (VEHICLE_ID,VEHICLE_MAKE)
CREATE STATISTICS STATS_DIM_VEHICLE_002 ON [dbo].DIM_VEHICLE (VEHICLE_ID,VEHICLE_MODEL)
CREATE STATISTICS STATS_DIM_VEHICLE_003 ON [dbo].DIM_VEHICLE (VEHICLE_ID,VEHICLE_YEAR)

 exec DropStats 'DIM_YEAR'  
-- exec CreateStats 'DIM_YEAR'
 
CREATE STATISTICS STATS_DIM_YEAR_001 ON [dbo].DIM_YEAR (YEAR_ID, [YEAR])

--exec DropStats 'PaymentAgreement'  
----exec CreateStats 'PaymentAgreement'
 
--CREATE STATISTICS STATS_PaymentAgreement_001 ON [dbo].PaymentAgreement (ID)
--CREATE STATISTICS STATS_PaymentAgreement_002 ON [dbo].PaymentAgreement (Last_Name)
--CREATE STATISTICS STATS_PaymentAgreement_003 ON [dbo].PaymentAgreement (First_Name)
--CREATE STATISTICS STATS_PaymentAgreement_004 ON [dbo].PaymentAgreement (Phone_Number)
--CREATE STATISTICS STATS_PaymentAgreement_005 ON [dbo].PaymentAgreement (License_Plate)
--CREATE STATISTICS STATS_PaymentAgreement_006 ON [dbo].PaymentAgreement ([State])
--CREATE STATISTICS STATS_PaymentAgreement_007 ON [dbo].PaymentAgreement (Violator_ID)
--CREATE STATISTICS STATS_PaymentAgreement_008 ON [dbo].PaymentAgreement (Agent_ID)
--CREATE STATISTICS STATS_PaymentAgreement_009 ON [dbo].PaymentAgreement (Indicator)
--CREATE STATISTICS STATS_PaymentAgreement_010 ON [dbo].PaymentAgreement (Settlement_Amount)
--CREATE STATISTICS STATS_PaymentAgreement_011 ON [dbo].PaymentAgreement (Down_Payment)
--CREATE STATISTICS STATS_PaymentAgreement_012 ON [dbo].PaymentAgreement (Due_Date)
--CREATE STATISTICS STATS_PaymentAgreement_013 ON [dbo].PaymentAgreement (Agreement_Type)
--CREATE STATISTICS STATS_PaymentAgreement_014 ON [dbo].PaymentAgreement (Todays_Date)
--CREATE STATISTICS STATS_PaymentAgreement_015 ON [dbo].PaymentAgreement (Collections)
--CREATE STATISTICS STATS_PaymentAgreement_016 ON [dbo].PaymentAgreement (Remaining_Balance_Due)
--CREATE STATISTICS STATS_PaymentAgreement_017 ON [dbo].PaymentAgreement (Payment_Plan_Due_Date)
--CREATE STATISTICS STATS_PaymentAgreement_018 ON [dbo].PaymentAgreement (Check_Number)
--CREATE STATISTICS STATS_PaymentAgreement_019 ON [dbo].PaymentAgreement (Paid_in_Full)
--CREATE STATISTICS STATS_PaymentAgreement_020 ON [dbo].PaymentAgreement ([Default])
--CREATE STATISTICS STATS_PaymentAgreement_021 ON [dbo].PaymentAgreement (Spanish_Only)
--CREATE STATISTICS STATS_PaymentAgreement_022 ON [dbo].PaymentAgreement (Amnesty_Account)
--CREATE STATISTICS STATS_PaymentAgreement_023 ON [dbo].PaymentAgreement (Comments)
--CREATE STATISTICS STATS_PaymentAgreement_024 ON [dbo].PaymentAgreement (Tolltag_Acct_Id)
--CREATE STATISTICS STATS_PaymentAgreement_025 ON [dbo].PaymentAgreement (AdminFees)
--CREATE STATISTICS STATS_PaymentAgreement_026 ON [dbo].PaymentAgreement (CitationFees)

exec DropStats 'StateLookup'   
-- exec CreateStats 'StateLookup'
CREATE STATISTICS STATS_StateLookup_001 ON [dbo].StateLookup (StateLookupID,StateCode,Descr)
CREATE STATISTICS STATS_StateLookup_002 ON [dbo].StateLookup (StateLookupID, STATE_LATITUDE, STATE_LONGITUDE)

 exec DropStats 'Violator'  
-- exec CreateStats 'Violator'
CREATE STATISTICS STATS_Violator_000 ON [dbo].[Violator] (ID)
CREATE STATISTICS STATS_Violator_001 ON [dbo].[Violator] (ViolatorID,VidSeq)
CREATE STATISTICS STATS_Violator_031 ON [dbo].[Violator] (ViolatorID,CURRENT_IND)
CREATE STATISTICS STATS_Violator_002 ON [dbo].Violator (LicPlateNbr)
CREATE STATISTICS STATS_Violator_003 ON [dbo].Violator (LicPlateStateLookupID)
CREATE STATISTICS STATS_Violator_004 ON [dbo].Violator (VEHICLE_ID)
CREATE STATISTICS STATS_Violator_005 ON [dbo].Violator (DocNum)
CREATE STATISTICS STATS_Violator_006 ON [dbo].Violator (Vin)
CREATE STATISTICS STATS_Violator_007 ON [dbo].Violator (PrimaryViolatorFname)
CREATE STATISTICS STATS_Violator_008 ON [dbo].Violator (PrimaryViolatorLname)
CREATE STATISTICS STATS_Violator_009 ON [dbo].Violator (SecondaryViolatorFname)
CREATE STATISTICS STATS_Violator_010 ON [dbo].Violator (SecondaryViolatorLname)
CREATE STATISTICS STATS_Violator_011 ON [dbo].Violator (DriversLicense)
CREATE STATISTICS STATS_Violator_012 ON [dbo].Violator (DriversLicenseStateLookupID)
CREATE STATISTICS STATS_Violator_013 ON [dbo].Violator (SecondaryDriversLicense)
CREATE STATISTICS STATS_Violator_014 ON [dbo].Violator (SecondaryDriversLicenseStateLookupID)
CREATE STATISTICS STATS_Violator_015 ON [dbo].Violator (EarliestHvTranDate)
CREATE STATISTICS STATS_Violator_016 ON [dbo].Violator (LatestHvTranDate)
CREATE STATISTICS STATS_Violator_017 ON [dbo].Violator (AdminCountyLookupID)
CREATE STATISTICS STATS_Violator_018 ON [dbo].Violator (RegistrationCountyLookupID)
CREATE STATISTICS STATS_Violator_019 ON [dbo].Violator (RegistrationDateNextMonth)
CREATE STATISTICS STATS_Violator_020 ON [dbo].Violator (RegistrationDateNextYear)
CREATE STATISTICS STATS_Violator_021 ON [dbo].Violator (ViolatorAgencyLookupID)
CREATE STATISTICS STATS_Violator_022 ON [dbo].Violator (ViolatorAddressSourceLookupID)
CREATE STATISTICS STATS_Violator_023 ON [dbo].Violator (ViolatorAddressStatusLookupID)
CREATE STATISTICS STATS_Violator_024 ON [dbo].Violator (ViolatorAddressActiveFlag)
CREATE STATISTICS STATS_Violator_025 ON [dbo].Violator (ViolatorAddressConfirmedFlag)
CREATE STATISTICS STATS_Violator_026 ON [dbo].Violator (ViolatorID,VidSeq,ViolatorAddress1,ViolatorAddress2)
CREATE STATISTICS STATS_Violator_027 ON [dbo].Violator (ViolatorAddressCity)
CREATE STATISTICS STATS_Violator_028 ON [dbo].Violator (ViolatorAddressStateLookupID)
CREATE STATISTICS STATS_Violator_029 ON [dbo].Violator (ViolatorAddressZipCode, ViolatorAddressPlus4)
CREATE STATISTICS STATS_Violator_030 ON [dbo].Violator (LAST_UPDATE_DATE)
CREATE STATISTICS STATS_Violator_032 ON [dbo].Violator (ViolatorID,VidSeq,AdminCountyLookupID)



exec DropStats 'ViolatorAgencyLookup' 
--   exec CreateStats 'ViolatorAgencyLookup'
CREATE STATISTICS STATS_ViolatorAgencyLookup_001 ON [dbo].ViolatorAgencyLookup (ViolatorAgencyLookupID, Descr)
CREATE STATISTICS STATS_ViolatorAgencyLookup_002 ON [dbo].ViolatorAgencyLookup (LAST_UPDATE_DATE)


exec DropStats 'ViolatorContact'  
-- exec CreateStats 'ViolatorContact'
CREATE STATISTICS STATS_ViolatorContact_001 ON [dbo].ViolatorContact (ViolatorID,VidSeq)
CREATE STATISTICS STATS_ViolatorContact_002 ON [dbo].ViolatorContact (ViolatorID,VidSeq,PhoneNbr)
CREATE STATISTICS STATS_ViolatorContact_003 ON [dbo].ViolatorContact (ViolatorID,VidSeq,WorkPhoneNbr)
CREATE STATISTICS STATS_ViolatorContact_004 ON [dbo].ViolatorContact (ViolatorID,VidSeq,OtherPhoneNbr)
CREATE STATISTICS STATS_ViolatorContact_005 ON [dbo].ViolatorContact (ViolatorID,VidSeq,EmailAddress)
CREATE STATISTICS STATS_ViolatorContact_006 ON [dbo].ViolatorContact (LAST_UPDATE_DATE)


exec DropStats 'ViolatorStatus' 
-- exec CreateStats 'ViolatorStatus'

CREATE STATISTICS STATS_ViolatorStatus_001 ON [dbo].[ViolatorStatus] (ViolatorID,VidSeq)
CREATE STATISTICS STATS_ViolatorStatus_002 ON [dbo].ViolatorStatus (ViolatorID)
CREATE STATISTICS STATS_ViolatorStatus_003 ON [dbo].ViolatorStatus (VidSeq)
CREATE STATISTICS STATS_ViolatorStatus_004 ON [dbo].ViolatorStatus (ViolatorID,VidSeq,HvFlag)
CREATE STATISTICS STATS_ViolatorStatus_005 ON [dbo].ViolatorStatus (ViolatorID,VidSeq,HvDate)
CREATE STATISTICS STATS_ViolatorStatus_006 ON [dbo].ViolatorStatus (ViolatorID,VidSeq,ViolatorStatusLookupID)
CREATE STATISTICS STATS_ViolatorStatus_007 ON [dbo].ViolatorStatus (ViolatorID,VidSeq,HvExemptFlag)
CREATE STATISTICS STATS_ViolatorStatus_008 ON [dbo].ViolatorStatus (ViolatorID,VidSeq,HvExemptDate)
CREATE STATISTICS STATS_ViolatorStatus_009 ON [dbo].ViolatorStatus (ViolatorID,VidSeq,ViolatorStatusTermLookupID)
CREATE STATISTICS STATS_ViolatorStatus_010 ON [dbo].ViolatorStatus (ViolatorID,VidSeq,TermFlag)
CREATE STATISTICS STATS_ViolatorStatus_011 ON [dbo].ViolatorStatus (ViolatorID,VidSeq,TermDate)
CREATE STATISTICS STATS_ViolatorStatus_012 ON [dbo].ViolatorStatus (ViolatorID,VidSeq,ViolatorStatusEligRmdyLookupID)
CREATE STATISTICS STATS_ViolatorStatus_013 ON [dbo].ViolatorStatus (ViolatorID,VidSeq,EligRmdyFlag)
CREATE STATISTICS STATS_ViolatorStatus_014 ON [dbo].ViolatorStatus (ViolatorID,VidSeq,EligRmdyDate)
CREATE STATISTICS STATS_ViolatorStatus_015 ON [dbo].ViolatorStatus (ViolatorID,VidSeq,BanFlag)
CREATE STATISTICS STATS_ViolatorStatus_016 ON [dbo].ViolatorStatus (ViolatorID,VidSeq,BanDate)
CREATE STATISTICS STATS_ViolatorStatus_017 ON [dbo].ViolatorStatus (ViolatorID,VidSeq,BanStartDate)
CREATE STATISTICS STATS_ViolatorStatus_018 ON [dbo].ViolatorStatus (ViolatorID,VidSeq,BanCiteWarnFlag)
CREATE STATISTICS STATS_ViolatorStatus_019 ON [dbo].ViolatorStatus (ViolatorID,VidSeq,BanCiteWarnDate)
CREATE STATISTICS STATS_ViolatorStatus_020 ON [dbo].ViolatorStatus (ViolatorID,VidSeq,BanCiteWarnCount)
CREATE STATISTICS STATS_ViolatorStatus_021 ON [dbo].ViolatorStatus (ViolatorID,VidSeq,BanImpoundFlag)
CREATE STATISTICS STATS_ViolatorStatus_022 ON [dbo].ViolatorStatus (ViolatorID,VidSeq,BanImpoundDate)
CREATE STATISTICS STATS_ViolatorStatus_023 ON [dbo].ViolatorStatus (ViolatorID,VidSeq,VrbFlag)
CREATE STATISTICS STATS_ViolatorStatus_024 ON [dbo].ViolatorStatus (ViolatorID,VidSeq,VrbDate)
CREATE STATISTICS STATS_ViolatorStatus_025 ON [dbo].ViolatorStatus (ViolatorID,VidSeq,ViolatorStatusLetterDeterminationLookupID)
CREATE STATISTICS STATS_ViolatorStatus_026 ON [dbo].ViolatorStatus (ViolatorID,VidSeq,DeterminationLetterFlag)
CREATE STATISTICS STATS_ViolatorStatus_027 ON [dbo].ViolatorStatus (ViolatorID,VidSeq,DeterminationLetterDate)
CREATE STATISTICS STATS_ViolatorStatus_028 ON [dbo].ViolatorStatus (ViolatorID,VidSeq,ViolatorStatusLetterBanLookupID)
CREATE STATISTICS STATS_ViolatorStatus_029 ON [dbo].ViolatorStatus (ViolatorID,VidSeq,BanLetterFlag)
CREATE STATISTICS STATS_ViolatorStatus_030 ON [dbo].ViolatorStatus (ViolatorID,VidSeq,BanLetterDate)
CREATE STATISTICS STATS_ViolatorStatus_031 ON [dbo].ViolatorStatus (ViolatorID,VidSeq,ViolatorStatusLetterTermLookupID)
CREATE STATISTICS STATS_ViolatorStatus_032 ON [dbo].ViolatorStatus (ViolatorID,VidSeq,TermLetterFlag)
CREATE STATISTICS STATS_ViolatorStatus_033 ON [dbo].ViolatorStatus (ViolatorID,VidSeq,TermLetterDate)  
CREATE STATISTICS STATS_ViolatorStatus_034 ON [dbo].ViolatorStatus (LAST_UPDATE_DATE)  


--exec DropStats 'ViolatorAddress' 
---- exec CreateStats 'ViolatorAddress'

--CREATE STATISTICS STATS_ViolatorAddress_001 ON [dbo].ViolatorAddress (ViolatorID,VidSeq)
--CREATE STATISTICS STATS_ViolatorAddress_002 ON [dbo].ViolatorAddress (ViolatorID,VidSeq,ViolatorAddressSourceLookupID)
--CREATE STATISTICS STATS_ViolatorAddress_003 ON [dbo].ViolatorAddress (ViolatorID,VidSeq,ViolatorAddressStatusLookupID)
----CREATE STATISTICS STATS_ViolatorAddress_004 ON [dbo].ViolatorAddress (ActiveFlag)
--CREATE STATISTICS STATS_ViolatorAddress_005 ON [dbo].ViolatorAddress (ViolatorID,VidSeq,ConfirmedFlag)
--CREATE STATISTICS STATS_ViolatorAddress_006 ON [dbo].ViolatorAddress (ViolatorID,VidSeq,Address1,Address2)
--CREATE STATISTICS STATS_ViolatorAddress_007 ON [dbo].ViolatorAddress (ViolatorID,VidSeq,City)
--CREATE STATISTICS STATS_ViolatorAddress_008 ON [dbo].ViolatorAddress (ViolatorID,VidSeq,StateLookupID)
--CREATE STATISTICS STATS_ViolatorAddress_009 ON [dbo].ViolatorAddress (ViolatorID,VidSeq,ZipCode)
 
 
 
exec DropStats 'ViolatorAddressStatusLookup' 
-- exec CreateStats 'ViolatorAddressStatusLookup'
CREATE STATISTICS STATS_ViolatorAddressStatusLookup_001 ON [dbo].ViolatorAddressStatusLookup (ViolatorAddressStatusLookupID,Descr)
CREATE STATISTICS STATS_ViolatorAddressStatusLookup_002 ON [dbo].ViolatorAddressStatusLookup (LAST_UPDATE_DATE)  

exec DropStats 'ViolatorAddressSourceLookup' 
-- exec CreateStats 'ViolatorAddressSourceLookup'
CREATE STATISTICS STATS_ViolatorAddressSourceLookup_001 ON [dbo].ViolatorAddressSourceLookup (ViolatorAddressSourceLookupID,Descr)
CREATE STATISTICS STATS_ViolatorAddressSourceLookup_002 ON [dbo].ViolatorAddressSourceLookup (LAST_UPDATE_DATE)


exec DropStats 'ViolatorStatusLookup' 
-- exec CreateStats 'ViolatorStatusLookup'
CREATE STATISTICS STATS_ViolatorStatusLookup_001 ON [dbo].ViolatorStatusLookup (ViolatorStatusLookupID, Descr)
CREATE STATISTICS STATS_ViolatorStatusLookup_002 ON [dbo].ViolatorStatusLookup (LAST_UPDATE_DATE)


exec DropStats 'ViolatorStatusTermLookup' 
-- exec CreateStats 'ViolatorStatusTermLookup'
CREATE STATISTICS STATS_ViolatorStatusTermLookup_001 ON [dbo].ViolatorStatusTermLookup (ViolatorStatusTermLookupID,Descr)
CREATE STATISTICS STATS_ViolatorStatusTermLookup_002 ON [dbo].ViolatorStatusTermLookup (LAST_UPDATE_DATE)

exec DropStats 'ViolatorStatusEligRmdyLookup' 
-- exec CreateStats 'ViolatorStatusEligRmdyLookup'
CREATE STATISTICS STATS_ViolatorStatusEligRmdyLookup_001 ON [dbo].ViolatorStatusEligRmdyLookup (ViolatorStatusEligRmdyLookupID,Descr)
CREATE STATISTICS STATS_ViolatorStatusEligRmdyLookup_002 ON [dbo].ViolatorStatusEligRmdyLookup (LAST_UPDATE_DATE)


exec DropStats 'ViolatorStatusLetterDeterminationLookup' 
-- exec CreateStats 'ViolatorStatusLetterDeterminationLookup'
CREATE STATISTICS STATS_ViolatorStatusLetterDeterminationLookup_001 ON [dbo].ViolatorStatusLetterDeterminationLookup (ViolatorStatusLetterDeterminationLookupID,Descr)
CREATE STATISTICS STATS_ViolatorStatusLetterDeterminationLookup_002 ON [dbo].ViolatorStatusLetterDeterminationLookup (LAST_UPDATE_DATE)

exec DropStats 'ViolatorStatusLetterTermLookup' 
-- exec CreateStats 'ViolatorStatusLetterTermLookup'
CREATE STATISTICS STATS_ViolatorStatusLetterTermLookup_001 ON [dbo].ViolatorStatusLetterTermLookup (ViolatorStatusLetterTermLookupID,Descr)
CREATE STATISTICS STATS_ViolatorStatusLetterTermLookup_002 ON [dbo].ViolatorStatusLetterTermLookup (LAST_UPDATE_DATE)

exec DropStats 'ViolatorStatusLetterBanLookup' 
-- exec CreateStats 'ViolatorStatusLetterBanLookup'
CREATE STATISTICS STATS_ViolatorStatusLetterBanLookup_001 ON [dbo].ViolatorStatusLetterBanLookup (ViolatorStatusLetterBanLookupID,Descr)
CREATE STATISTICS STATS_ViolatorStatusLetterBanLookup_002 ON [dbo].ViolatorStatusLetterBanLookup (LAST_UPDATE_DATE)


exec DropStats 'Ban' 
-- exec CreateStats 'Ban'
CREATE STATISTICS STATS_Ban_001 ON [dbo].Ban (BanID)
CREATE STATISTICS STATS_Ban_002 ON [dbo].Ban (ViolatorID, VidSeq)
CREATE STATISTICS STATS_Ban_003 ON [dbo].Ban (ActiveFlag)
CREATE STATISTICS STATS_Ban_004 ON [dbo].Ban (BanActionLookupID)
CREATE STATISTICS STATS_Ban_005 ON [dbo].Ban (ActionDate)
CREATE STATISTICS STATS_Ban_006 ON [dbo].Ban (BanStartDate)
CREATE STATISTICS STATS_Ban_007 ON [dbo].Ban (BanLocationLookupID)
CREATE STATISTICS STATS_Ban_008 ON [dbo].Ban (BanOfficerLookupID)
CREATE STATISTICS STATS_Ban_009 ON [dbo].Ban (BanImpoundServiceLookupID)
CREATE STATISTICS STATS_Ban_010 ON [dbo].Ban (LAST_UPDATE_DATE)
 

 
exec DropStats 'BanActionLookup' 
-- exec CreateStats 'BanActionLookup'
CREATE STATISTICS STATS_BanActionLookup_001 ON [dbo].BanActionLookup (BanActionLookupID,Descr)
CREATE STATISTICS STATS_BanActionLookup_002 ON [dbo].BanActionLookup (LAST_UPDATE_DATE)

exec DropStats 'BanImpoundServiceLookup' 
-- exec CreateStats 'BanImpoundServiceLookup'
CREATE STATISTICS STATS_BanImpoundServiceLookup_001 ON [dbo].BanImpoundServiceLookup (BanImpoundServiceLookupID,Descr)
CREATE STATISTICS STATS_BanImpoundServiceLookup_002 ON [dbo].BanImpoundServiceLookup (LAST_UPDATE_DATE)

exec DropStats 'BanLocationLookup' 
-- exec CreateStats 'BanLocationLookup'
CREATE STATISTICS STATS_BanLocationLookup_001 ON [dbo].BanLocationLookup (BanLocationLookupID,Descr)
CREATE STATISTICS STATS_BanLocationLookup_002 ON [dbo].BanLocationLookup (LAST_UPDATE_DATE)

exec DropStats 'BanOfficerLookup' 
-- exec CreateStats 'BanOfficerLookup'

CREATE STATISTICS STATS_BanOfficerLookup_001 ON [dbo].BanOfficerLookup (BanOfficerLookupID)
CREATE STATISTICS STATS_BanOfficerLookup_002 ON [dbo].BanOfficerLookup (BanOfficerLookupID, LastName, FirstName)
CREATE STATISTICS STATS_BanOfficerLookup_003 ON [dbo].BanOfficerLookup (BanOfficerLookupID, PhoneNbr)
CREATE STATISTICS STATS_BanOfficerLookup_004 ON [dbo].BanOfficerLookup (BanOfficerLookupID, RadioNbr)
CREATE STATISTICS STATS_BanOfficerLookup_005 ON [dbo].BanOfficerLookup (BanOfficerLookupID, Unit)
CREATE STATISTICS STATS_BanOfficerLookup_006 ON [dbo].BanOfficerLookup (BanOfficerLookupID, Registration)
CREATE STATISTICS STATS_BanOfficerLookup_007 ON [dbo].BanOfficerLookup (BanOfficerLookupID, PatrolCar)
CREATE STATISTICS STATS_BanOfficerLookup_008 ON [dbo].BanOfficerLookup (BanOfficerLookupID, Area)
CREATE STATISTICS STATS_BanOfficerLookup_010 ON [dbo].BanOfficerLookup (INSERT_DATE)
CREATE STATISTICS STATS_BanOfficerLookup_011 ON [dbo].BanOfficerLookup (LAST_UPDATE_DATE)
 


--exec DropStats 'DIM_AGREEMENT_TYPE' 
---- exec CreateStats 'DIM_AGREEMENT_TYPE'
--CREATE STATISTICS STATS_DIM_AGREEMENT_TYPE_001 ON [dbo].DIM_AGREEMENT_TYPE (AGREEMENT_TYPE_ID,AGREEMENT_TYPE)


exec DropStats 'DIM_MONTH' 
-- exec CreateStats 'DIM_MONTH'
CREATE STATISTICS STATS_DIM_MONTH_001 ON [dbo].DIM_MONTH (MONTH_ID, [MONTH])


exec DropStats 'DIM_STATE'
-- exec CreateStats 'DIM_STATE'
CREATE STATISTICS STATS_DIM_STATE_001 ON [dbo].DIM_STATE (STATE_CODE,STATE_NAME)
CREATE STATISTICS STATS_DIM_STATE_002 ON [dbo].DIM_STATE (STATE_CODE,STATE_LATITUDE,STATE_LONGITUDE)


exec DropStats 'DIM_ZIPCODE'
-- exec CreateStats 'DIM_ZIPCODE'
CREATE STATISTICS STATS_DIM_ZIPCODE_001 ON [dbo].DIM_ZIPCODE (ZIPCODE)
CREATE STATISTICS STATS_DIM_ZIPCODE_002 ON [dbo].DIM_ZIPCODE (ZIPCODE,ZIPCODE_LATITUDE,ZIPCODE_LONGITUDE)
CREATE STATISTICS STATS_DIM_ZIPCODE_003 ON [dbo].DIM_ZIPCODE (ZIPCODE, COUNTY)

exec DropStats 'ViolatorCallLog'
-- exec CreateStats 'ViolatorCallLog'
CREATE STATISTICS STATS_ViolatorCallLog_001 ON [dbo].ViolatorCallLog (ViolatorCallLogID)
CREATE STATISTICS STATS_ViolatorCallLog_002 ON [dbo].ViolatorCallLog (ViolatorID,VidSeq)
CREATE STATISTICS STATS_ViolatorCallLog_003 ON [dbo].ViolatorCallLog (ViolatorCallLogLookupID)
CREATE STATISTICS STATS_ViolatorCallLog_004 ON [dbo].ViolatorCallLog (OutgoingCallFlag)
CREATE STATISTICS STATS_ViolatorCallLog_005 ON [dbo].ViolatorCallLog (PhoneNbr)
CREATE STATISTICS STATS_ViolatorCallLog_006 ON [dbo].ViolatorCallLog (ConnectedFlag)
CREATE STATISTICS STATS_ViolatorCallLog_007 ON [dbo].ViolatorCallLog (LAST_UPDATE_DATE)



exec DropStats 'ViolatorCallLog'
-- exec CreateStats 'ViolatorCallLog'
CREATE STATISTICS STATS_ViolatorCallLog_001 ON [dbo].ViolatorCallLog (ViolatorCallLogID)
CREATE STATISTICS STATS_ViolatorCallLog_002 ON [dbo].ViolatorCallLog (LAST_UPDATE_DATE)


exec DropStats 'ViolatorCallLogLookup' 
-- exec CreateStats 'ViolatorCallLogLookup'
CREATE STATISTICS STATS_ViolatorCallLogLookup_001 ON [dbo].ViolatorCallLogLookup (ViolatorCallLogLookupID,Descr)
CREATE STATISTICS STATS_ViolatorCallLogLookup_002 ON [dbo].ViolatorCallLogLookup (LAST_UPDATE_DATE)

exec DropStats 'VrbAgencyLookup' 
-- exec CreateStats 'VrbAgencyLookup'
CREATE STATISTICS STATS_VrbAgencyLookup_001 ON [dbo].VrbAgencyLookup (VrbAgencyLookupID,Descr)
CREATE STATISTICS STATS_VrbAgencyLookup_002 ON [dbo].VrbAgencyLookup (LAST_UPDATE_DATE)

exec DropStats 'VrbRejectLookup' 
-- exec CreateStats 'VrbRejectLookup'
CREATE STATISTICS STATS_VrbRejectLookup_001 ON [dbo].VrbRejectLookup (VrbRejectLookupID,Descr)
CREATE STATISTICS STATS_VrbRejectLookup_002 ON [dbo].VrbRejectLookup (LAST_UPDATE_DATE)


exec DropStats 'VrbRemovalLookup' 
-- exec CreateStats 'VrbRemovalLookup'
CREATE STATISTICS STATS_VrbRemovalLookup_001 ON [dbo].VrbRemovalLookup (VrbRemovalLookupID,Descr)
CREATE STATISTICS STATS_VrbRemovalLookup_002 ON [dbo].VrbRemovalLookup (LAST_UPDATE_DATE)

exec DropStats 'VrbStatusLookup' 
-- exec CreateStats 'VrbStatusLookup'
CREATE STATISTICS STATS_VrbStatusLookup_001 ON [dbo].VrbStatusLookup (VrbStatusLookupID,Descr)
CREATE STATISTICS STATS_VrbStatusLookup_002 ON [dbo].VrbStatusLookup (LAST_UPDATE_DATE)


exec DropStats 'Vrb' 
-- exec CreateStats 'Vrb'

CREATE STATISTICS STATS_Vrb_001 ON [dbo].Vrb (VrbID)
CREATE STATISTICS STATS_Vrb_002 ON [dbo].Vrb (ViolatorID,VidSeq)
CREATE STATISTICS STATS_Vrb_003 ON [dbo].Vrb (ViolatorID,VidSeq,ActiveFlag)
CREATE STATISTICS STATS_Vrb_004 ON [dbo].Vrb (ViolatorID,VidSeq,VrbStatusLookupID)
CREATE STATISTICS STATS_Vrb_005 ON [dbo].Vrb (ViolatorID,VidSeq,AppliedDate)
CREATE STATISTICS STATS_Vrb_006 ON [dbo].Vrb (ViolatorID,VidSeq,VrbAgencyLookupID)
CREATE STATISTICS STATS_Vrb_007 ON [dbo].Vrb (ViolatorID,VidSeq,SentDate)
CREATE STATISTICS STATS_Vrb_008 ON [dbo].Vrb (ViolatorID,VidSeq,AcknowledgedDate)
CREATE STATISTICS STATS_Vrb_009 ON [dbo].Vrb (ViolatorID,VidSeq,RejectionDate)
CREATE STATISTICS STATS_Vrb_010 ON [dbo].Vrb (ViolatorID,VidSeq,VrbRejectLookupID)
CREATE STATISTICS STATS_Vrb_011 ON [dbo].Vrb (ViolatorID,VidSeq,RemovedDate)
CREATE STATISTICS STATS_Vrb_012 ON [dbo].Vrb (ViolatorID,VidSeq,VrbRemovalLookupID)
CREATE STATISTICS STATS_Vrb_013 ON [dbo].Vrb (INSERT_DATE)
CREATE STATISTICS STATS_Vrb_014 ON [dbo].Vrb (LAST_UPDATE_DATE)
 

 

exec DropStats 'Violator_Bankruptcy' 
-- exec CreateStats 'Violator_Bankruptcy'

CREATE STATISTICS STATS_Violator_Bankruptcy_001 ON [dbo].Violator_Bankruptcy (ViolatorId, VidSeq)
CREATE STATISTICS STATS_Violator_Bankruptcy_002 ON [dbo].Violator_Bankruptcy (BankruptcyInstanceNbr)
CREATE STATISTICS STATS_Violator_Bankruptcy_003 ON [dbo].Violator_Bankruptcy (ViolatorId, VidSeq, LastName, FirstName)
CREATE STATISTICS STATS_Violator_Bankruptcy_004 ON [dbo].Violator_Bankruptcy (ViolatorId, VidSeq, LastName2, FirstName2)
CREATE STATISTICS STATS_Violator_Bankruptcy_008 ON [dbo].Violator_Bankruptcy (LicensePlate)
CREATE STATISTICS STATS_Violator_Bankruptcy_009 ON [dbo].Violator_Bankruptcy (CaseNumber)
CREATE STATISTICS STATS_Violator_Bankruptcy_010 ON [dbo].Violator_Bankruptcy (DateNotified)
CREATE STATISTICS STATS_Violator_Bankruptcy_011 ON [dbo].Violator_Bankruptcy (FilingDate)
CREATE STATISTICS STATS_Violator_Bankruptcy_012 ON [dbo].Violator_Bankruptcy (ConversionDate)
CREATE STATISTICS STATS_Violator_Bankruptcy_013 ON [dbo].Violator_Bankruptcy (ExcusedAmount)
CREATE STATISTICS STATS_Violator_Bankruptcy_014 ON [dbo].Violator_Bankruptcy (CollectableAmount)
CREATE STATISTICS STATS_Violator_Bankruptcy_015 ON [dbo].Violator_Bankruptcy (PhoneNumber)
CREATE STATISTICS STATS_Violator_Bankruptcy_016 ON [dbo].Violator_Bankruptcy (DischargeDismissedId)
CREATE STATISTICS STATS_Violator_Bankruptcy_017 ON [dbo].Violator_Bankruptcy (Discharge_Dismissed_Date)
CREATE STATISTICS STATS_Violator_Bankruptcy_018 ON [dbo].Violator_Bankruptcy (Assets)
CREATE STATISTICS STATS_Violator_Bankruptcy_019 ON [dbo].Violator_Bankruptcy (CollectionAccounts)
CREATE STATISTICS STATS_Violator_Bankruptcy_020 ON [dbo].Violator_Bankruptcy (LawFirm)
CREATE STATISTICS STATS_Violator_Bankruptcy_021 ON [dbo].Violator_Bankruptcy (AttorneyName)
CREATE STATISTICS STATS_Violator_Bankruptcy_022 ON [dbo].Violator_Bankruptcy (ClaimFilled)
CREATE STATISTICS STATS_Violator_Bankruptcy_023 ON [dbo].Violator_Bankruptcy (Comments)
CREATE STATISTICS STATS_Violator_Bankruptcy_024 ON [dbo].Violator_Bankruptcy (FilingStatusId)
CREATE STATISTICS STATS_Violator_Bankruptcy_026 ON [dbo].Violator_Bankruptcy (LAST_UPDATE_DATE)



exec DropStats 'Ban' 
-- exec CreateStats 'Ban'
CREATE STATISTICS STATS_Ban_001 ON [dbo].Ban (ViolatorID, VidSeq)
CREATE STATISTICS STATS_Ban_002 ON [dbo].Ban (ActiveFlag)
CREATE STATISTICS STATS_Ban_003 ON [dbo].Ban (BanActionLookupID)
CREATE STATISTICS STATS_Ban_004 ON [dbo].Ban (ActionDate)
CREATE STATISTICS STATS_Ban_005 ON [dbo].Ban (BanStartDate)
CREATE STATISTICS STATS_Ban_006 ON [dbo].Ban (BanLocationLookupID)
CREATE STATISTICS STATS_Ban_007 ON [dbo].Ban (BanOfficerLookupID)
CREATE STATISTICS STATS_Ban_008 ON [dbo].Ban (BanImpoundServiceLookupID)
CREATE STATISTICS STATS_Ban_009 ON [dbo].Ban (LAST_UPDATE_DATE)
 
exec DropStats 'BanActionLookup' 
-- exec CreateStats 'BanActionLookup'
CREATE STATISTICS STATS_BanActionLookup_001 ON [dbo].BanActionLookup (BanActionLookupID,Descr)
CREATE STATISTICS STATS_BanActionLookup_002 ON [dbo].BanActionLookup (LAST_UPDATE_DATE)
 
exec DropStats 'BanImpoundServiceLookup' 
-- exec CreateStats 'BanImpoundServiceLookup'
CREATE STATISTICS STATS_BanImpoundServiceLookup_001 ON [dbo].BanImpoundServiceLookup (BanImpoundServiceLookupID, Descr)
CREATE STATISTICS STATS_BanImpoundServiceLookup_002 ON [dbo].BanImpoundServiceLookup (LAST_UPDATE_DATE)

exec DropStats 'BanLocationLookup' 
-- exec CreateStats 'BanLocationLookup'
CREATE STATISTICS STATS_BanLocationLookup_001 ON [dbo].BanLocationLookup (BanLocationLookupID, Descr)
CREATE STATISTICS STATS_BanLocationLookup_002 ON [dbo].BanLocationLookup (LAST_UPDATE_DATE)

exec DropStats 'BanOfficerLookup' 
-- exec CreateStats 'BanOfficerLookup'

CREATE STATISTICS STATS_BanOfficerLookup_001 ON [dbo].BanOfficerLookup (BanOfficerLookupID)
CREATE STATISTICS STATS_BanOfficerLookup_002 ON [dbo].BanOfficerLookup (BanOfficerLookupID, LastName, FirstName)
CREATE STATISTICS STATS_BanOfficerLookup_003 ON [dbo].BanOfficerLookup (BanOfficerLookupID, PhoneNbr)
CREATE STATISTICS STATS_BanOfficerLookup_004 ON [dbo].BanOfficerLookup (BanOfficerLookupID, RadioNbr)
CREATE STATISTICS STATS_BanOfficerLookup_005 ON [dbo].BanOfficerLookup (BanOfficerLookupID, Unit)
CREATE STATISTICS STATS_BanOfficerLookup_006 ON [dbo].BanOfficerLookup (BanOfficerLookupID, Registration)
CREATE STATISTICS STATS_BanOfficerLookup_007 ON [dbo].BanOfficerLookup (BanOfficerLookupID, PatrolCar)
CREATE STATISTICS STATS_BanOfficerLookup_008 ON [dbo].BanOfficerLookup (BanOfficerLookupID, Area)
CREATE STATISTICS STATS_BanOfficerLookup_009 ON [dbo].BanOfficerLookup (LAST_UPDATE_DATE)
 
 
exec DropStats 'DIM_Agent' 
-- exec CreateStats 'DIM_Agent'
CREATE STATISTICS STATS_DIM_Agent_001 ON [dbo].DIM_Agent (AgentId, Agent)
CREATE STATISTICS STATS_DIM_Agent_002 ON [dbo].DIM_Agent (INSERT_DATETIME)
 
 
exec DropStats 'DIM_AgreementType' 
-- exec CreateStats 'DIM_AgreementType'
CREATE STATISTICS STATS_DIM_AgreementType_001 ON [dbo].DIM_AgreementType (AgreementTypeId, AgreementType)
CREATE STATISTICS STATS_DIM_AgreementType_002 ON [dbo].DIM_AgreementType (INSERT_DATETIME)

exec DropStats 'DIM_DischargeDismissed' 
-- exec CreateStats 'DIM_DischargeDismissed'
CREATE STATISTICS STATS_DIM_DischargeDismissed_001 ON [dbo].DIM_DischargeDismissed (DischargeDismissedId, DischargeDismissed)
CREATE STATISTICS STATS_DIM_DischargeDismissed_002 ON [dbo].DIM_DischargeDismissed (INSERT_DATETIME)

exec DropStats 'DIM_FilingStatus' 
-- exec CreateStats 'DIM_FilingStatus'
CREATE STATISTICS STATS_DIM_FilingStatus_001 ON [dbo].DIM_FilingStatus (FilingStatusId, FilingStatus)
CREATE STATISTICS STATS_DIM_FilingStatus_002 ON [dbo].DIM_FilingStatus (INSERT_DATETIME)

exec DropStats 'DIM_PaymentAgreement_Source' 
-- exec CreateStats 'DIM_PaymentAgreement_Source'
CREATE STATISTICS STATS_DIM_PaymentAgreement_Source_001 ON [dbo].DIM_PaymentAgreement_Source (PaymentAgreement_SourceId,PaymentAgreement_Source)
CREATE STATISTICS STATS_DIM_PaymentAgreement_Source_002 ON [dbo].DIM_PaymentAgreement_Source (INSERT_DATETIME)
 
exec DropStats 'Violator_PaymentAgreement' 
-- exec CreateStats 'Violator_PaymentAgreement'
CREATE STATISTICS STATS_Violator_PaymentAgreement_001 ON [dbo].Violator_PaymentAgreement (ViolatorID, VidSeq)
CREATE STATISTICS STATS_Violator_PaymentAgreement_003 ON [dbo].Violator_PaymentAgreement (ViolatorID, VidSeq, InstanceNbr)
CREATE STATISTICS STATS_Violator_PaymentAgreement_004 ON [dbo].Violator_PaymentAgreement (ViolatorID, VidSeq, LastName, FirstName)
CREATE STATISTICS STATS_Violator_PaymentAgreement_006 ON [dbo].Violator_PaymentAgreement (ViolatorID, VidSeq, PhoneNumber)
CREATE STATISTICS STATS_Violator_PaymentAgreement_007 ON [dbo].Violator_PaymentAgreement (ViolatorID, VidSeq, LicensePlate, [State])
CREATE STATISTICS STATS_Violator_PaymentAgreement_008 ON [dbo].Violator_PaymentAgreement (ViolatorID, VidSeq, [State])
CREATE STATISTICS STATS_Violator_PaymentAgreement_009 ON [dbo].Violator_PaymentAgreement (AgentID)
CREATE STATISTICS STATS_Violator_PaymentAgreement_010 ON [dbo].Violator_PaymentAgreement (PaymentAgreement_SourceId)
CREATE STATISTICS STATS_Violator_PaymentAgreement_011 ON [dbo].Violator_PaymentAgreement (SettlementAmount)
CREATE STATISTICS STATS_Violator_PaymentAgreement_012 ON [dbo].Violator_PaymentAgreement (DownPayment)
CREATE STATISTICS STATS_Violator_PaymentAgreement_013 ON [dbo].Violator_PaymentAgreement (DueDate)
CREATE STATISTICS STATS_Violator_PaymentAgreement_014 ON [dbo].Violator_PaymentAgreement (AgreementTypeId)
CREATE STATISTICS STATS_Violator_PaymentAgreement_015 ON [dbo].Violator_PaymentAgreement (TodaysDate)
CREATE STATISTICS STATS_Violator_PaymentAgreement_016 ON [dbo].Violator_PaymentAgreement (Collections)
CREATE STATISTICS STATS_Violator_PaymentAgreement_017 ON [dbo].Violator_PaymentAgreement (RemainingBalanceDue)
CREATE STATISTICS STATS_Violator_PaymentAgreement_018 ON [dbo].Violator_PaymentAgreement (PaymentPlanDueDate)
CREATE STATISTICS STATS_Violator_PaymentAgreement_019 ON [dbo].Violator_PaymentAgreement (CheckNumber)
CREATE STATISTICS STATS_Violator_PaymentAgreement_020 ON [dbo].Violator_PaymentAgreement (PaidInFull)
CREATE STATISTICS STATS_Violator_PaymentAgreement_021 ON [dbo].Violator_PaymentAgreement (DefaultInd)
CREATE STATISTICS STATS_Violator_PaymentAgreement_022 ON [dbo].Violator_PaymentAgreement (SpanishOnly)
CREATE STATISTICS STATS_Violator_PaymentAgreement_023 ON [dbo].Violator_PaymentAgreement (AmnestyAccount)
CREATE STATISTICS STATS_Violator_PaymentAgreement_024 ON [dbo].Violator_PaymentAgreement (Tolltag_Acct_Id)
CREATE STATISTICS STATS_Violator_PaymentAgreement_025 ON [dbo].Violator_PaymentAgreement (AdminFees)
CREATE STATISTICS STATS_Violator_PaymentAgreement_026 ON [dbo].Violator_PaymentAgreement (CitationFees)
CREATE STATISTICS STATS_Violator_PaymentAgreement_027 ON [dbo].Violator_PaymentAgreement (MonthlyPaymentAmount)
CREATE STATISTICS STATS_Violator_PaymentAgreement_029 ON [dbo].Violator_PaymentAgreement (LAST_UPDATE_DATE)
CREATE STATISTICS STATS_Violator_PaymentAgreement_030 ON [dbo].Violator_PaymentAgreement (ViolatorId, MonthlyPaymentAmount, PaidInFull, DefaultInd, TodaysDate)
CREATE STATISTICS STATS_Violator_PaymentAgreement_031 ON [dbo].Violator_PaymentAgreement (ViolatorId, MonthlyPaymentAmount, PaidInFull, DefaultInd, TodaysDate, DueDate)
 
 

exec DropStats 'ViolatorCallLog' 
-- exec CreateStats 'ViolatorCallLog'
CREATE STATISTICS STATS_ViolatorCallLog_001 ON [dbo].ViolatorCallLog (ViolatorID, VidSeq)
CREATE STATISTICS STATS_ViolatorCallLog_004 ON [dbo].ViolatorCallLog (ViolatorCallLogLookupID)
CREATE STATISTICS STATS_ViolatorCallLog_005 ON [dbo].ViolatorCallLog (OutgoingCallFlag)
CREATE STATISTICS STATS_ViolatorCallLog_006 ON [dbo].ViolatorCallLog (PhoneNbr)
CREATE STATISTICS STATS_ViolatorCallLog_007 ON [dbo].ViolatorCallLog (ConnectedFlag)
CREATE STATISTICS STATS_ViolatorCallLog_009 ON [dbo].ViolatorCallLog (LAST_UPDATE_DATE)

exec DropStats 'ViolatorCallLogLookup' 
-- exec CreateStats 'ViolatorCallLogLookup'
CREATE STATISTICS STATS_ViolatorCallLogLookup_001 ON [dbo].ViolatorCallLogLookup (ViolatorCallLogLookupID,Descr)
CREATE STATISTICS STATS_ViolatorCallLogLookup_004 ON [dbo].ViolatorCallLogLookup (LAST_UPDATE_DATE)

exec DropStats 'Vrb' 
-- exec CreateStats 'Vrb'

CREATE STATISTICS STATS_Vrb_002 ON [dbo].Vrb (ViolatorID,VidSeq)
CREATE STATISTICS STATS_Vrb_004 ON [dbo].Vrb (ActiveFlag)
CREATE STATISTICS STATS_Vrb_005 ON [dbo].Vrb (VrbStatusLookupID)
CREATE STATISTICS STATS_Vrb_006 ON [dbo].Vrb (AppliedDate)
CREATE STATISTICS STATS_Vrb_007 ON [dbo].Vrb (VrbAgencyLookupID)
CREATE STATISTICS STATS_Vrb_008 ON [dbo].Vrb (SentDate)
CREATE STATISTICS STATS_Vrb_009 ON [dbo].Vrb (AcknowledgedDate)
CREATE STATISTICS STATS_Vrb_010 ON [dbo].Vrb (RejectionDate)
CREATE STATISTICS STATS_Vrb_011 ON [dbo].Vrb (VrbRejectLookupID)
CREATE STATISTICS STATS_Vrb_012 ON [dbo].Vrb (RemovedDate)
CREATE STATISTICS STATS_Vrb_013 ON [dbo].Vrb (VrbRemovalLookupID)
CREATE STATISTICS STATS_Vrb_015 ON [dbo].Vrb (LAST_UPDATE_DATE)
 

exec DropStats 'VrbAgencyLookup' 
-- exec CreateStats 'VrbAgencyLookup'
CREATE STATISTICS STATS_VrbAgencyLookup_001 ON [dbo].VrbAgencyLookup (VrbAgencyLookupID, Descr)
CREATE STATISTICS STATS_VrbAgencyLookup_004 ON [dbo].VrbAgencyLookup (LAST_UPDATE_DATE)

exec DropStats 'VrbRejectLookup' 
-- exec CreateStats 'VrbRejectLookup'
CREATE STATISTICS STATS_VrbRejectLookup_001 ON [dbo].VrbRejectLookup (VrbRejectLookupID, Descr)
CREATE STATISTICS STATS_VrbRejectLookup_004 ON [dbo].VrbRejectLookup (LAST_UPDATE_DATE)

exec DropStats 'VrbRemovalLookup' 
-- exec CreateStats 'VrbRemovalLookup'
CREATE STATISTICS STATS_VrbRemovalLookup_001 ON [dbo].VrbRemovalLookup (VrbRemovalLookupID, Descr)
CREATE STATISTICS STATS_VrbRemovalLookup_004 ON [dbo].VrbRemovalLookup (LAST_UPDATE_DATE)

exec DropStats 'VrbStatusLookup' 
-- exec CreateStats 'VrbStatusLookup'
CREATE STATISTICS STATS_VrbStatusLookup_001 ON [dbo].VrbStatusLookup (VrbStatusLookupID, Descr)
CREATE STATISTICS STATS_VrbStatusLookup_004 ON [dbo].VrbStatusLookup (LAST_UPDATE_DATE)


exec DropStats 'ViolatorStatus_Mart' 
-- exec CreateStats 'ViolatorStatus_Mart'
CREATE STATISTICS STATS_ViolatorStatus_Mart_001 ON [dbo].ViolatorStatus_Mart (ReportDate, ViolatorID, VidSeq)
CREATE STATISTICS STATS_ViolatorStatus_Mart_002 ON [dbo].ViolatorStatus_Mart (ReportDate)
CREATE STATISTICS STATS_ViolatorStatus_Mart_003 ON [dbo].ViolatorStatus_Mart (ViolatorID, VidSeq)









