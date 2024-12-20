CREATE VIEW [dbo].[vw_ViolatorContact] AS SELECT 
	  ViolatorID, VidSeq, ISNULL(PhoneNbr,'(Null)') AS PhoneNbr, ISNULL(WorkPhoneNbr,'(Null)') AS WorkPhoneNbr
	, ISNULL(OtherPhoneNbr,'(Null)') AS OtherPhoneNbr, ISNULL(EmailAddress,'(Null)') AS EmailAddress
FROM dbo.ViolatorContact;
