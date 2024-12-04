CREATE VIEW [Reporting].[vw_Dim_Month_Txn] AS SELECT A.SnapshotMonthID,
       A.TripMonthID,      
       A.AsOfDayID,
       MinAsOfDayID,
       MaxAsOfDayID,
       ROW_NUMBER() OVER (PARTITION BY A.TripMonthID ORDER BY A.SnapshotMonthID) - 1 AS MonthCount
FROM
(
    SELECT DISTINCT
           TripMonthID,
           SnapshotMonthID,
           AsOfDayID,
           (CASE
                WHEN AsOfDayID = MAX(AsOfDayID) OVER (PARTITION BY TripMonthID ORDER BY SnapshotMonthID) THEN
                    1
                ELSE
                    0
            END
           ) AS MaxFirstEntryFlag,
           MIN(AsOfDayID) OVER (PARTITION BY TripMonthID) MinAsOfDayID,
           MAX(AsOfDayID) OVER (PARTITION BY TripMonthID) MaxAsOfDayID
    FROM dbo.Fact_UnifiedTransaction_SummarySnapshot
    GROUP BY TripMonthID,
             SnapshotMonthID,
             AsOfDayID
           
) A
WHERE MaxFirstEntryFlag <> 0;