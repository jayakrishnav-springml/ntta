CREATE VIEW [dbo].[vw_Violator_Bankruptcy] AS SELECT 
	   ViolatorId, VidSeq, BankruptcyInstanceNbr
	, convert(smallint,1) As BankruptcyCount
	, convert(smallint,1) As BankruptcyFlag
	, LastName, FirstName, LastName2, FirstName2, LicensePlate
	, CaseNumber, DateNotified, FilingDate, ConversionDate, ExcusedAmount
	, CollectableAmount, PhoneNumber, DischargeDismissedId, Discharge_Dismissed_Date
	, Assets, CollectionAccounts, LawFirm, AttorneyName, ClaimFilled
	, FilingStatusId
	, Insertdate AS BankruptcyInsertdate
	, InsertByUser AS BankruptcyInsertByUser
	, LastUpdatedate AS BankruptcyLastUpdatedate
	, LastUpdateByUser AS BankruptcyLastUpdateByUser
FROM dbo.Violator_Bankruptcy
UNION ALL 
SELECT 
	   ViolatorId, VidSeq, 0 AS BankruptcyInstanceNbr
	, convert(smallint,0) As BankruptcyCount
	, convert(smallint,0) As BankruptcyFlag
	, '(Null)' AS LastName, '(Null)' AS FirstName, '(Null)' AS LastName2, '(Null)' AS FirstName2, '(Null)' AS LicensePlate
	, '(Null)' AS CaseNumber, '1/1/1900' AS DateNotified, '1/1/1900' AS FilingDate, '1/1/1900' AS ConversionDate, 0 AS ExcusedAmount
	, 0 AS CollectableAmount, '(Null)' AS PhoneNumber, -1 AS DischargeDismissedId, '1/1/1900' AS Discharge_Dismissed_Date
	, -1 AS Assets, -1 AS CollectionAccounts, '(Null)' AS LawFirm, '(Null)' AS AttorneyName, -1 AS ClaimFilled
	, -1 AS FilingStatusId
	, null AS BankruptcyInsertdate
	, null AS BankruptcyInsertByUser
	, null AS BankruptcyLastUpdatedate
	, null AS BankruptcyLastUpdateByUser
FROM dbo.Violator a
WHERE NOT EXISTS (SELECT * FROM dbo.Violator_Bankruptcy b where a.ViolatorID = b.ViolatorID AND a.VidSeq = b.VidSeq);
