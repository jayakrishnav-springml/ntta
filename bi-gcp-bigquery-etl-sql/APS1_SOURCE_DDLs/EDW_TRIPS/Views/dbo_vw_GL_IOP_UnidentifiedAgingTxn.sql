CREATE VIEW [dbo].[vw_GL_IOP_UnidentifiedAgingTxn] AS WITH CTE_TT_DR
AS (SELECT 
           Gl_TxnID,
           LinkID TPTripID,
           CustomerID,
           a1.BusinessUnitId,
           CAST(PostingDate AS DATE) PostingDate,
           CAST(TxnDate AS DATE) TxnDate,
           TxnAmount
    FROM dbo.Fact_GL_Transactions a1
        JOIN dbo.Dim_GL_TxnType a2
            ON a1.TxnTypeID = a2.TxnTypeID
    WHERE (
              TxnType LIKE 'IOP%UNIDTTDR'
              OR TxnType LIKE 'IOP%UNIDTT'
          )
          AND Status = 'Active'
          AND CustomerID = 100057393),
     CTE_TT_CR
AS (SELECT Gl_TxnID,
           LinkID TPTripID,
           CustomerID,
           a1.BusinessUnitId,
           CAST(PostingDate AS DATE) PostingDate,
           CAST(TxnDate AS DATE) TxnDate,
           TxnAmount
    FROM dbo.Fact_GL_Transactions a1
        JOIN dbo.Dim_GL_TxnType a2
            ON a1.TxnTypeID = a2.TxnTypeID
    WHERE (
              TxnType LIKE 'IOP%UNIDTTCR'
              OR TxnType LIKE 'IOP%UNIDTTREJ'
          )
          AND Status = 'Active'
          AND CustomerID = 100057393),
     CTE_VT_DR
AS (SELECT Gl_TxnID,
           LinkID TPTripID,
           CustomerID,
           a1.BusinessUnitId,
           CAST(PostingDate AS DATE) PostingDate,
           CAST(TxnDate AS DATE) TxnDate,
           TxnAmount
    FROM dbo.Fact_GL_Transactions a1
        JOIN dbo.Dim_GL_TxnType a2
            ON a1.TxnTypeID = a2.TxnTypeID
    WHERE (
              TxnType LIKE 'IOP%UNIDVTDR'
              OR TxnType LIKE 'IOP%UNIDVT'
          )
          AND Status = 'Active'
          AND CustomerID = 100057393),
     CTE_VT_CR
AS (SELECT Gl_TxnID,
           LinkID TPTripID,
           CustomerID,
           a1.BusinessUnitId,
           CAST(PostingDate AS DATE) PostingDate,
           CAST(TxnDate AS DATE) TxnDate,
           TxnAmount
    FROM dbo.Fact_GL_Transactions a1
        JOIN dbo.Dim_GL_TxnType a2
            ON a1.TxnTypeID = a2.TxnTypeID
    WHERE (
              (
                  TxnType LIKE 'IOP%UNIDVTCR'
                  OR a2.TxnType LIKE 'IOP%UNIDVTREJ'
                     AND a1.CustomerID = 100057393
              )
              OR
              (
                  (
                      a2.TxnType LIKE 'IOPNTELBJ%VT'
                      AND a2.TxnType NOT IN ( 'IOPNTELBJUNIDVT' )
                  )
                  OR
                  (
                      a2.TxnType LIKE 'IOPNTE12%VT'
                      AND a2.TxnType NOT IN ( 'IOPNTE12UNIDVT' )
                  )
              )
          )
          AND Status = 'Active')
--AND CustomerID = 100057393)
SELECT T.Gl_TxnID,
       T.TPTripID,
       FT.LaneID,
       T.CustomerID,
       T.BusinessUnitId,
       T.PostingDate,
       T.TxnDate,
       T.TxnAmount,
       DATEDIFF(DAY, T.PostingDate, getdate()) DaycountID
FROM CTE_TT_DR T
    JOIN dbo.Fact_Transaction FT
        ON T.TPTripID = FT.TPTripID
WHERE T.TPTripID NOT IN
      (
          SELECT TPTripID FROM CTE_TT_CR
      )
UNION
SELECT T.Gl_TxnID,
       T.TPTripID,
       FT.LaneID,
       T.CustomerID,
       T.BusinessUnitId,
       T.PostingDate,
       T.TxnDate,
       T.TxnAmount,
       DATEDIFF(DAY, T.PostingDate, getdate()) DaycountID
FROM CTE_VT_DR T
    JOIN dbo.Fact_Transaction FT
        ON T.TPTripID = FT.TPTripID
WHERE T.TPTripID NOT IN
      (
          SELECT TPTripID FROM CTE_VT_CR
      );
