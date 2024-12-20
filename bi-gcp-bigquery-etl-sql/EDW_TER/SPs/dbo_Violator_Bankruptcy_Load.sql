CREATE PROC [dbo].[Violator_Bankruptcy_Load] AS

	UPDATE dbo.Violator_Bankruptcy  
		SET 
		  dbo.Violator_Bankruptcy.ViolatorId = B.ViolatorId
		, dbo.Violator_Bankruptcy.VidSeq = B.VidSeq
		, dbo.Violator_Bankruptcy.BankruptcyInstanceNbr = B.BankruptcyInstanceNbr
		, dbo.Violator_Bankruptcy.LastName = B.LastName
		, dbo.Violator_Bankruptcy.FirstName = B.FirstName
		, dbo.Violator_Bankruptcy.LastName2 = B.LastName2
		, dbo.Violator_Bankruptcy.FirstName2 = B.FirstName2
		, dbo.Violator_Bankruptcy.LicensePlate = B.LicensePlate
		, dbo.Violator_Bankruptcy.CaseNumber = B.CaseNumber
		, dbo.Violator_Bankruptcy.DateNotified = B.DateNotified
		, dbo.Violator_Bankruptcy.FilingDate = B.FilingDate
		, dbo.Violator_Bankruptcy.ConversionDate = B.ConversionDate
		, dbo.Violator_Bankruptcy.ExcusedAmount = B.ExcusedAmount
		, dbo.Violator_Bankruptcy.CollectableAmount = B.CollectableAmount
		, dbo.Violator_Bankruptcy.PhoneNumber = B.PhoneNumber
		, dbo.Violator_Bankruptcy.DischargeDismissedId = B.DischargeDismissedId
		, dbo.Violator_Bankruptcy.Discharge_Dismissed_Date = B.Discharge_Dismissed_Date
		, dbo.Violator_Bankruptcy.Assets = B.Assets
		, dbo.Violator_Bankruptcy.CollectionAccounts = B.CollectionAccounts
		, dbo.Violator_Bankruptcy.LawFirm = B.LawFirm
		, dbo.Violator_Bankruptcy.AttorneyName = B.AttorneyName
		, dbo.Violator_Bankruptcy.ClaimFilled = B.ClaimFilled
		, dbo.Violator_Bankruptcy.Comments = B.Comments
		, dbo.Violator_Bankruptcy.FilingStatusId = B.FilingStatusId
		, dbo.Violator_Bankruptcy.InsertDate = B.InsertDate
		, dbo.Violator_Bankruptcy.InsertByUser = B.InsertByUser
		, dbo.Violator_Bankruptcy.LastUpdateDate = B.LastUpdateDate
		, dbo.Violator_Bankruptcy.LastUpdateByUser = B.LastUpdateByUser
		, dbo.Violator_Bankruptcy.LAST_UPDATE_DATE = B.LAST_UPDATE_DATE 
	FROM dbo.Violator_Bankruptcy_Final_Stage B
	WHERE 
		dbo.Violator_Bankruptcy.ViolatorId = B.ViolatorId AND dbo.Violator_Bankruptcy.VidSeq = B.VidSeq AND dbo.Violator_Bankruptcy.BankruptcyInstanceNbr = B.BankruptcyInstanceNbr
		--AND 
		--B.LAST_UPDATE_TYPE = 'U' 

	INSERT INTO DBO.Violator_Bankruptcy
		(
				ViolatorId, VidSeq, BankruptcyInstanceNbr, LastName, FirstName, LastName2, FirstName2
			, LicensePlate, CaseNumber, DateNotified, FilingDate, ConversionDate, ExcusedAmount
			, CollectableAmount, PhoneNumber, DischargeDismissedId, Discharge_Dismissed_Date, Assets
			, CollectionAccounts, LawFirm, AttorneyName, ClaimFilled, Comments, FilingStatusId
			, InsertDate, InsertByUser, LastUpdateDate, LastUpdateByUser
			, INSERT_DATE, LAST_UPDATE_DATE
		)
	-- EXPLAIN
	SELECT 
			  A.ViolatorId, A.VidSeq, A.BankruptcyInstanceNbr, A.LastName, A.FirstName, A.LastName2, A.FirstName2
			, A.LicensePlate, A.CaseNumber, A.DateNotified, A.FilingDate, A.ConversionDate, A.ExcusedAmount
			, A.CollectableAmount, A.PhoneNumber, A.DischargeDismissedId, A.Discharge_Dismissed_Date, A.Assets
			, A.CollectionAccounts, A.LawFirm, A.AttorneyName, A.ClaimFilled, A.Comments, A.FilingStatusId
			, A.InsertDate, A.InsertByUser, A.LastUpdateDate, A.LastUpdateByUser
			, A.LAST_UPDATE_DATE
			, A.LAST_UPDATE_DATE
	-- SELECT COUNT(*)
	FROM dbo.Violator_Bankruptcy_Final_Stage A
	LEFT JOIN dbo.Violator_Bankruptcy B
		ON A.ViolatorID = B.ViolatorID  AND A.VidSeq = B.VidSeq AND A.BankruptcyInstanceNbr = B.BankruptcyInstanceNbr
	WHERE 
		B.ViolatorID IS NULL AND B.VidSeq IS NULL AND B.BankruptcyInstanceNbr IS NULL
		--AND 
		--A.LAST_UPDATE_TYPE = 'I'

	UPDATE STATISTICS [dbo].Violator WITH FULLSCAN


	DELETE 
	-- SELECT * 
	FROM dbo.Violator_Bankruptcy 
	WHERE EXISTS 
		(
			SELECT * FROM LND_TER.DBO.Bankruptcy 
			WHERE Last_update_type = 'D' and ViolatorID = [Violator ID] and VidSeq = SeqNbr and BankruptcyInstanceNbr = BankruptcyInstanceNbr
		)

				
	DELETE 	
	-- SELECT COUNT(*)
	FROM dbo.Violator_Bankruptcy 
	WHERE NOT EXISTS 
		(
			SELECT * FROM LND_TER.DBO.Bankruptcy 
			WHERE ViolatorID = [Violator ID] and VidSeq = SeqNbr and BankruptcyInstanceNbr = BankruptcyInstanceNbr
		)


