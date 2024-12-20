CREATE VIEW [dbo].[vw_PaymentPlan_By_Month] AS SELECT *
FROM   (     

SELECT  Cal_MonthID,paymentplanid,
                  CASE WHEN q.PaymentPlanStatusLookupID = 5 THEN 'Active' WHEN q.PaymentPlanStatusLookupID IN (6,7) THEN 'Paid in Full' WHEN q.PaymentPlanStatusLookupID IN (8,9) THEN 'Defaulted' ELSE q.Descr END AS PaymentPlan,  --
                  COUNT(1) CNT
                  from
(
  SELECT m.Cal_MonthID,a.paymentplanid,ROW_NUMBER() OVER (PARTITION BY paymentplanid,m.Cal_MonthID ORDER BY paymentplanhistoryid desc) AS rn,a.PaymentPlanStatusLookupID,descr
                     FROM 
                     (
                                          
                     SELECT 
                            PaymentPlanID,
                            PaymentPlanHistoryID,
                            PaymentPlanStatusLookupID,
                            CreatedDate,
                            UpdatedDate,
                            PrevValue = COALESCE(UpdatedDate,LAG(UpdatedDate) OVER (PARTITION BY PaymentPlanID ORDER BY PaymentPlanHistoryID),CreatedDate),
                            NextValue = DATEADD(SECOND,-1,COALESCE(LEAD(ISNULL(UpdatedDate,createddate)) OVER (PARTITION BY PaymentPlanID ORDER BY PaymentPlanHistoryID),'9999-12-31' )),
                            DeletedFlag
                                                FROM --[dbo].[PaymentPlanHistory]
                            (
                            SELECT PaymentPlanID, PaymentPlanHistoryID, PaymentPlanStatusLookupID, CreatedDate, UpdatedDate, DeletedFlag FROM LND_TER.[dbo].[PaymentPlanHistory]
                            UNION                            
                            SELECT PaymentPlanID, 999999 PaymentPlanHistoryID, PaymentPlanStatusLookupID, CreatedDate, UpdatedDate, DeletedFlag FROM LND_TER.[dbo].[PaymentPlan] 
                            ) PaymentPlanHistory
                     ) A
                     JOIN   LND_TER.[dbo].PaymentPlanStatusLookup PP ON PP.PaymentPlanStatusLookupID = A.PaymentPlanStatusLookupID AND DELETEDFLAG = 0 AND A.PaymentPlanStatusLookupID BETWEEN 5 AND 10
                     JOIN   EDW_RITE.dbo.DIM_MONTH M ON M.MonthDate BETWEEN PrevValue AND NextValue AND M.MonthDate BETWEEN '20160101' AND REPLACE(DATEADD(MONTH, -1, DATEADD(DAY, 1, EOMONTH(GETDATE()))),'-','')--WHERE '2019-11-06 08:00:00.000' BETWEEN PrevValue AND NextValue 
                      --WHERE --A.PaymentPlanStatusLookupID IN (6,7) AND 
                      --M.Cal_MonthID = 202002
) q
WHERE Rn = 1
                     GROUP BY Cal_MonthID,paymentplanid
                              ,CASE WHEN q.PaymentPlanStatusLookupID = 5 THEN 'Active' WHEN q.PaymentPlanStatusLookupID IN (6,7) THEN 'Paid in Full' WHEN q.PaymentPlanStatusLookupID IN (8,9) THEN 'Defaulted' ELSE q.Descr END
) T
PIVOT(
      SUM(CNT) FOR PaymentPlan IN ([Active],[Bankruptcy],[Defaulted],[Paid in Full]) 
     ) AS PIVOT_TABLE;
