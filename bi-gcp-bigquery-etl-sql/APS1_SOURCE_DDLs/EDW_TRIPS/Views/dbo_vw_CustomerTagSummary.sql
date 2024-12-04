CREATE VIEW [dbo].[vw_CustomerTagSummary] AS WITH CTE_Tags_Summary AS
(
    SELECT	MonthID, 
            CustomerID,
			RebillAmountGroupID,
			RebillAmount,
			AccountTypeID,
            AccountStatusID,
			AutoReplenishmentID,
            ZipCode,
            AccountCreateDate, 
            AccountLastCloseDate,
            SUM(MonthEndTag) - SUM(MonthBeginTag) MonthlyTagsChange,
            SUM(MonthBeginTag) MonthBeginTags,
            SUM(OpenedTag) OpenedTags,
            SUM(ClosedTag) ClosedTags,
            SUM(MonthEndTag) MonthEndTags,
            SUM(MonthBeginTag) + SUM(OpenedTag) - SUM(ClosedTag) Calc_MonthEndTags,
            SUM(MonthBeginTag) + SUM(OpenedTag) - SUM(ClosedTag) - SUM(MonthEndTag) Diff_MonthEndTags,
            CASE WHEN SUM(MonthBeginTag) + SUM(OpenedTag) - SUM(ClosedTag) = SUM(MonthEndTag) THEN 'OK' ELSE 'NOT OK' END TagDiffCheck,
			CASE WHEN SUM(OpenedTag) > SUM(ClosedTag) THEN SUM(OpenedTag) - SUM(ClosedTag) ELSE 0 END NewTags,			
			CASE WHEN SUM(OpenedTag) >= SUM(ClosedTag) THEN SUM(ClosedTag) ELSE SUM(OpenedTag) END ExistingTags
    FROM dbo.Fact_CustomerTagDetail
    GROUP BY MonthID, CustomerID, RebillAmountGroupID, RebillAmount, AccountTypeID, AccountStatusID, AutoReplenishmentID, ZipCode, AccountCreateDate, AccountLastCloseDate
)
SELECT *,
        CASE WHEN MonthBeginTags = 0 THEN 0 ELSE 1 END MonthBeginCustomers,
        CASE WHEN MonthBeginTags = 0 AND (OpenedTags > 0 OR MonthEndTags >0) THEN 1 ELSE 0 END NewCustomers, 
        CASE WHEN (MonthBeginTags > 0 OR OpenedTags > 0) AND MonthEndTags = 0 THEN 1 ELSE 0 END LostCustomers,
        CASE WHEN MonthEndTags = 0 THEN 0 ELSE 1 END MonthEndCustomers 
FROM   CTE_Tags_Summary;