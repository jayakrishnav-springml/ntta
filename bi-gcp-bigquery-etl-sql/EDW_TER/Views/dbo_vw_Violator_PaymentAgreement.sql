CREATE VIEW [dbo].[vw_Violator_PaymentAgreement] AS SELECT 
	ViolatorID
	, VidSeq
	, InstanceNbr
	, 1 AS PaymentAgreementCount
	, convert(smallint,1) AS PaymentAgreementFlag
	, VP.LastName
	, VP.FirstName
	, PhoneNumber
	, LicensePlate
	, [State]
	, AgentID
	, PaymentAgreement_SourceId
	, SettlementAmount
	, DownPayment
	, DueDate
	, AgreementTypeId
	, TodaysDate
	, TodaysDate  as PaymentPlanDate
	, ActiveAgreementDate
	, DefaultDate
	, '1/1/1900'  as EnforcementToolDate
	, '-1'  as EnforcementToolCode
	, Collections
	, VP.RemainingBalanceDue
	, PaymentPlanDueDate
	, CheckNumber
	, PaidInFull
	, [DefaultInd]
	, SpanishOnly
	, AmnestyAccount
	, Tolltag_Acct_Id
	, AdminFees
	, CitationFees
	, MonthlyPaymentAmount
	, MaintenanceAgencyId
	, ViolatorID2 
	, ViolatorID3 
	, ViolatorID4 
	, VP.BalanceDue 
	, [ContactSource], [PaymentPlanStatus]
	, Insertdate AS PaymentAgreementInsertdate
	, InsertByUser AS PaymentAgreementInsertByUser
	, LastUpdatedate AS PaymentAgreementLastUpdatedate
	, LastUpdateByUser AS PaymentAgreementLastUpdateByUser
FROM dbo.Violator_PaymentAgreement VP
LEFT JOIN LND_TER.DBO.PAYMENTPLAN ON InstanceNbr = PaymentPlanID
UNION ALL 
SELECT 
	  ViolatorID
	, VidSeq
	, 0 As InstanceNbr
	, 0 AS PaymentAgreementCount
	, convert(smallint,0) AS PaymentAgreementFlag
	, '(Null)' AS LastName
	, '(Null)' AS FirstName
	, '(Null)' AS PhoneNumber
	, '(Null)' AS LicensePlate
	, '-1' as [State]
	, -1 as AgentID
	, -1 as PaymentAgreement_SourceId
	, null as SettlementAmount
	, null as DownPayment
	, '1/1/1900' AS DueDate
	, -1 as AgreementTypeId
	, '1/1/1900' AS TodaysDate
	, '1/1/1900'  as PaymentPlanDate
	, '1/1/1900'  as ActiveAgreementDate
	, '1/1/1900'  as DefaultDate
	, '1/1/1900'  as EnforcementToolDate
	, '-1'  as EnforcementToolCode
	, null as Collections
	, null as RemainingBalanceDue
	, '1/1/1900' AS PaymentPlanDueDate
	, null as CheckNumber
	, -1 as PaidInFull
	, -1 as [DefaultInd]
	, -1 as SpanishOnly
	, -1 as AmnestyAccount
	, null as Tolltag_Acct_Id
	, null as AdminFees
	, null as CitationFees
	, null as MonthlyPaymentAmount
	, -1 AS MaintenanceAgencyId
	, null AS ViolatorID2 
	, null AS ViolatorID3 
	, null AS ViolatorID4 
	, null AS BalanceDue 
	, null AS [ContactSource], null AS [PaymentPlanStatus]
	, null AS PaymentAgreementInsertdate
	, null AS PaymentAgreementInsertByUser
	, null AS PaymentAgreementLastUpdatedate
	, null AS PaymentAgreementLastUpdateByUser
FROM dbo.Violator a
WHERE NOT EXISTS (SELECT * FROM dbo.Violator_PaymentAgreement b where a.ViolatorID = b.ViolatorID AND a.VidSeq = b.VidSeq);
