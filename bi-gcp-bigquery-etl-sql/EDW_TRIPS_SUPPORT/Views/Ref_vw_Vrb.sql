
  CREATE OR REPLACE VIEW EDW_TRIPS_SUPPORT.vw_Vrb 
  AS 
    SELECT
        a.vrbid,
        a.violatorid,
        a.vidseq,
        a.activeflag,
        CASE
          WHEN a.vrbstatuslookupid NOT IN(
            1, 2, 8, 11
          )
          AND NOT EXISTS (
              SELECT
                1
              FROM
                LND_TER.VrbHistory AS c
              WHERE a.vrbid = c.vrbid
                AND a.vrbstatuslookupid IN(
                  5, 6, 10
                )
                AND c.vrbstatuslookupid IN(
                  8, 11
                )
                AND c.vrbhistoryid = 
                (
                  SELECT
                    max(vrbhistoryid)
                  FROM
                    LND_TER.VrbHistory AS d
                  WHERE d.vrbid = c.vrbid
                    AND d.vrbstatuslookupid NOT IN(
                      5, 6, 10
                    )
                )
          ) THEN 1
          ELSE 0
        END AS vrbcount,
        1 AS vrbflag,
        a.vrbstatuslookupid,
        a.applieddate,
        a.vrbagencylookupid,
        a.sentdate,
        a.acknowledgeddate,
        a.rejectiondate,
        a.vrbrejectlookupid,
        a.removeddate,
        a.vrbremovallookupid,
        CAST( a.createddate as DATE) AS createddate,
        a.createdby,
        a.updateddate,
        a.updatedby
    FROM
      EDW_TER.Vrb AS a
      INNER JOIN EDW_TER.Violator AS b 
        ON a.violatorid = b.violatorid
          AND a.vidseq = b.vidseq
    UNION ALL
    SELECT
        0 AS vrbid,
        a.violatorid,
        a.vidseq,
        0 AS activeflag,
        0 AS vrbcount,
        0 AS vrbflag,
        -1 AS vrbstatuslookupid,
        PARSE_DATE('%m/%d/%Y', '1/1/1900') AS applieddate,
        -1 AS vrbagencylookupid,
        PARSE_DATE('%m/%d/%Y', '1/1/1900') AS sentdate,
        PARSE_DATE('%m/%d/%Y', '1/1/1900') AS acknowledgeddate,
        PARSE_DATE('%m/%d/%Y', '1/1/1900') AS rejectiondate,
        -1 AS vrbrejectlookupid,
        PARSE_DATE('%m/%d/%Y', '1/1/1900') AS removeddate,
        -1 AS vrbremovallookupid,
        NULL AS createddate,
        NULL AS createdby,
        NULL AS updateddate,
        NULL AS updatedby
      FROM
        EDW_TER.Violator AS a
      WHERE NOT EXISTS 
      (
        SELECT
            1
          FROM
            EDW_TER.Vrb AS b
          WHERE a.violatorid = b.violatorid
            AND a.vidseq = b.vidseq
      );