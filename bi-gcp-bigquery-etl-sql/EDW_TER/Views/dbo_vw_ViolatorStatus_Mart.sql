CREATE VIEW [dbo].[vw_ViolatorStatus_Mart] AS SELECT 
		ReportDate, ViolatorID, VidSeq, HvFlag, HvExemptFlag, TermFlag, TermAddedFlag
	, TermRemovedFlag, EligRmdyFlag, BanFlag, BanCiteWarnFlag, BanCiteWarnCount, BanImpoundFlag
	, VrbFlag, VrbFlagAdded, VrbFlagRemoved, DeterminationLetterFlag, BanLetterFlag, TermLetterFlag
	, HvQAmountDue, HvQTollsDue, HvQTransactions, HvQFeesDue, TotalAmountDueInitial, TotalAmountDue
	, TotalTollsDue, TotalFeesDue, TotalCitationCount, TotalTransactionsInitial, TotalTransactionsCount
	, SettlementAmount, DownPayment, Collections, PaidInFull, DefaultInd, AdminFees, CitationFees
	, MonthlyPaymentAmount, BalanceDue, ExcusedAmount, CollectableAmount, BankruptcyInd
	, HVActive, HVActiveAdded, HVActiveRemoved, HVRemoved, VrbAcknowledged, VrbRemoved
	, VrbRemovalQueued, BanByProcessServer, BanByDPS, BanByUSMail1stBan
	FROM dbo.ViolatorStatus_Mart;
