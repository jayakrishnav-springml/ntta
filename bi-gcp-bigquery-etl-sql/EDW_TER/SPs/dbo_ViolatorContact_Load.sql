CREATE PROC [dbo].[ViolatorContact_Load] AS

UPDATE dbo.ViolatorContact  
	SET 
		  dbo.ViolatorContact.ViolatorContactID = B.ViolatorContactID
		, dbo.ViolatorContact.VidSeq = B.VidSeq
		, dbo.ViolatorContact.PhoneNbr = B.PhoneNbr
		, dbo.ViolatorContact.WorkPhoneNbr = B.WorkPhoneNbr
		, dbo.ViolatorContact.OtherPhoneNbr = B.OtherPhoneNbr
		, dbo.ViolatorContact.EmailAddress = B.EmailAddress
		, dbo.ViolatorContact.LAST_UPDATE_DATE = B.LAST_UPDATE_DATE
FROM dbo.ViolatorContact_Stage B
WHERE 
	dbo.ViolatorContact.ViolatorContactID = B.ViolatorContactID
	AND 
	LAST_UPDATE_TYPE = 'U'

INSERT INTO dbo.ViolatorContact 
	(
		  ViolatorContactID
		, ViolatorID
		, VidSeq
		, PhoneNbr
		, WorkPhoneNbr
		, OtherPhoneNbr
		, EmailAddress
		, INSERT_DATE
		, LAST_UPDATE_DATE
	)
SELECT 
	  A.ViolatorContactID
	, A.ViolatorID
	, A.VidSeq
	, A.PhoneNbr
	, A.WorkPhoneNbr
	, A.OtherPhoneNbr
	, A.EmailAddress
	, A.LAST_UPDATE_DATE
	, A.LAST_UPDATE_DATE

FROM dbo.ViolatorContact_Stage A
LEFT JOIN DBO.ViolatorContact B ON A.ViolatorContactID = B.ViolatorContactID
WHERE 
	B.ViolatorContactID IS NULL
	AND 
	LAST_UPDATE_TYPE = 'I'




