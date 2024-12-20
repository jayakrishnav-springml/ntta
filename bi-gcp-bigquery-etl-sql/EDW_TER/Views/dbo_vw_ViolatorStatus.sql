CREATE VIEW [dbo].[vw_ViolatorStatus] AS SELECT 
			ViolatorStatusID, ViolatorID, VidSeq, HvFlag, HvDate, ViolatorStatusLookupID, HvExemptFlag
		, HvExemptDate, ViolatorStatusTermLookupID, TermFlag, TermDate, ViolatorStatusEligRmdyLookupID
		, EligRmdyFlag, EligRmdyDate, BanFlag, BanDate, BanStartDate, BanCiteWarnFlag, BanCiteWarnDate
		, BanCiteWarnCount, BanImpoundFlag, BanImpoundDate, VrbFlag, VrbDate, ViolatorStatusLetterDeterminationLookupID
		, DeterminationLetterFlag, DeterminationLetterDate, ViolatorStatusLetterBanLookupID, BanLetterFlag
		, BanLetterDate, ViolatorStatusLetterTermLookupID, TermLetterFlag, TermLetterDate
		, HvQAmountDue, HvQTollsDue, HvQTransactions, HvQFeesDue, TotalAmountDueInitial, TotalAmountDue
		, TotalTollsDue, TotalFeesDue, TotalCitationCount, TotalTransactionsInitial, TotalTransactionsCount
		, SettlementAmount, DownPayment, Collections, PaidInFull, DefaultInd
		, AdminFees, CitationFees, MonthlyPaymentAmount, BalanceDue
		, ExcusedAmount, CollectableAmount, BankruptcyInd
		, HVActive, HVRemoved, VrbAcknowledged, VrbRemoved, VrbRemovalQueued, BanByProcessServer, BanByDPS, BanByUSMail1stBan 
--		, TollsPaid, FeesCollected
		, ACCT_ID, ACCT_STATUS_CODE, HAS_TOLL_TAG_ACCOUNT, TollTransactionCount, BALANCE_AMOUNT
		, PMT_TYPE_CODE, REBILL_AMT, REBILL_DATE, BAL_LAST_UPDATED
		--, INSERT_DATE, LAST_UPDATE_DATE
FROM dbo.ViolatorStatus;
