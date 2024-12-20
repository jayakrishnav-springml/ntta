CREATE PROC [dbo].[Violator_PaymentAgreement_Load] AS

	UPDATE dbo.Violator_PaymentAgreement  
		SET 
			  dbo.Violator_PaymentAgreement.LastName = B.LastName
			, dbo.Violator_PaymentAgreement.FirstName = B.FirstName
			, dbo.Violator_PaymentAgreement.PhoneNumber = B.PhoneNumber
			, dbo.Violator_PaymentAgreement.LicensePlate = B.LicensePlate
			, dbo.Violator_PaymentAgreement.[State] = B.[State]
			, dbo.Violator_PaymentAgreement.AgentID = B.AgentID
			, dbo.Violator_PaymentAgreement.PaymentAgreement_SourceId = B.PaymentAgreement_SourceId
			, dbo.Violator_PaymentAgreement.SettlementAmount = B.SettlementAmount
			, dbo.Violator_PaymentAgreement.DownPayment = B.DownPayment
			, dbo.Violator_PaymentAgreement.DueDate = B.DueDate
			, dbo.Violator_PaymentAgreement.AgreementTypeId = B.AgreementTypeId
			, dbo.Violator_PaymentAgreement.TodaysDate = B.TodaysDate
			, dbo.Violator_PaymentAgreement.Collections = B.Collections
			, dbo.Violator_PaymentAgreement.RemainingBalanceDue = B.RemainingBalanceDue
			, dbo.Violator_PaymentAgreement.PaymentPlanDueDate = B.PaymentPlanDueDate
			, dbo.Violator_PaymentAgreement.CheckNumber = B.CheckNumber
			, dbo.Violator_PaymentAgreement.PaidInFull = B.PaidInFull
			, dbo.Violator_PaymentAgreement.DefaultInd = B.DefaultInd
			, dbo.Violator_PaymentAgreement.SpanishOnly = B.SpanishOnly
			, dbo.Violator_PaymentAgreement.AmnestyAccount = B.AmnestyAccount
			, dbo.Violator_PaymentAgreement.Tolltag_Acct_Id = B.Tolltag_Acct_Id
			, dbo.Violator_PaymentAgreement.AdminFees = B.AdminFees
			, dbo.Violator_PaymentAgreement.CitationFees = B.CitationFees
			, dbo.Violator_PaymentAgreement.MonthlyPaymentAmount = B.MonthlyPaymentAmount
			, dbo.Violator_PaymentAgreement.LAST_UPDATE_DATE = B.LAST_UPDATE_DATE
			, dbo.Violator_PaymentAgreement.InsertDate = B.InsertDate
			, dbo.Violator_PaymentAgreement.InsertByUser = B.InsertByUser
			, dbo.Violator_PaymentAgreement.LastUpdateDate = B.LastUpdateDate
			, dbo.Violator_PaymentAgreement.LastUpdateByUser = B.LastUpdateByUser
			, dbo.Violator_PaymentAgreement.DefaultDate = B.DefaultDate
			, dbo.Violator_PaymentAgreement.MaintenanceAgencyID = B.MaintenanceAgencyID
			, dbo.Violator_PaymentAgreement.ViolatorID2 = B.ViolatorID2
			, dbo.Violator_PaymentAgreement.ViolatorID3 = B.ViolatorID3
			, dbo.Violator_PaymentAgreement.ViolatorID4 = B.ViolatorID4
			, dbo.Violator_PaymentAgreement.BalanceDue = B.BalanceDue
			, dbo.Violator_PaymentAgreement.NTTA_Collections = B.NTTA_Collections
			, dbo.Violator_PaymentAgreement.[ContactSource] = B.[ContactSource]
			, dbo.Violator_PaymentAgreement.[PaymentPlanStatus] = B.[PaymentPlanStatus]
	FROM dbo.Violator_PaymentAgreement_Final_Stage B
	WHERE 
		dbo.Violator_PaymentAgreement.ViolatorId = B.ViolatorId AND dbo.Violator_PaymentAgreement.VidSeq = B.VidSeq AND dbo.Violator_PaymentAgreement.InstanceNbr = B.InstanceNbr
		--AND 
		--B.LAST_UPDATE_TYPE = 'U' 


	INSERT INTO DBO.Violator_PaymentAgreement
		(
		     ViolatorID, VidSeq, InstanceNbr, LastName, FirstName, PhoneNumber, LicensePlate, [State]
		   , AgentID, PaymentAgreement_SourceId, SettlementAmount, DownPayment, DueDate, AgreementTypeId
		   , TodaysDate, Collections, RemainingBalanceDue, PaymentPlanDueDate, CheckNumber, PaidInFull
		   , DefaultInd, SpanishOnly, AmnestyAccount, Tolltag_Acct_Id, AdminFees, CitationFees
		   , MonthlyPaymentAmount, DefaultDate, MaintenanceAgencyId
		   , ViolatorID2, ViolatorID3, ViolatorID4
		   , BalanceDue, NTTA_Collections, [ContactSource], [PaymentPlanStatus]
		   , Insertdate, InsertByUser, LastUpdatedate, LastUpdateByUser, INSERT_DATE, LAST_UPDATE_DATE
		)
	-- EXPLAIN
	SELECT 
		     A.ViolatorID, A.VidSeq, A.InstanceNbr, A.LastName, A.FirstName, A.PhoneNumber, A.LicensePlate, A.[State]
		   , A.AgentID, A.PaymentAgreement_SourceId, A.SettlementAmount, A.DownPayment, A.DueDate, A.AgreementTypeId
		   , A.TodaysDate, A.Collections, A.RemainingBalanceDue, A.PaymentPlanDueDate, A.CheckNumber, A.PaidInFull
		   , A.DefaultInd, A.SpanishOnly, A.AmnestyAccount, A.Tolltag_Acct_Id, A.AdminFees, A.CitationFees
		   , A.MonthlyPaymentAmount, A.DefaultDate, A.MaintenanceAgencyId
		   , A.ViolatorID2, A.ViolatorID3, A.ViolatorID4
		   , A.BalanceDue, A.NTTA_Collections, A.[ContactSource], A.[PaymentPlanStatus]
		   , A.Insertdate, A.InsertByUser, A.LastUpdatedate, A.LastUpdateByUser
			, A.LAST_UPDATE_DATE
			, A.LAST_UPDATE_DATE
	FROM dbo.Violator_PaymentAgreement_Final_Stage A
	LEFT JOIN dbo.Violator_PaymentAgreement B
		ON A.ViolatorID = B.ViolatorID  AND A.VidSeq = B.VidSeq AND A.InstanceNbr = B.InstanceNbr
	WHERE 
		B.ViolatorID IS NULL AND B.VidSeq IS NULL AND B.InstanceNbr IS NULL
		--AND 
		--A.LAST_UPDATE_TYPE = 'I'


	UPDATE STATISTICS [dbo].Violator_PaymentAgreement WITH FULLSCAN

	DELETE 
	FROM dbo.Violator_PaymentAgreement 
	WHERE EXISTS 
		(
			SELECT * FROM LND_TER.DBO.PaymentAgreement 
			WHERE Last_update_type = 'D' and ViolatorID = [Violator ID] and VidSeq = SeqNbr and InstanceNbr = PaymentPlanInstanceNbr
		)

				
	DELETE 	FROM dbo.Violator_PaymentAgreement 
	WHERE NOT EXISTS 
		(
			SELECT * FROM LND_TER.DBO.PaymentAgreement 
			WHERE ViolatorID = [Violator ID] and VidSeq = SeqNbr and InstanceNbr = PaymentPlanInstanceNbr
		)






