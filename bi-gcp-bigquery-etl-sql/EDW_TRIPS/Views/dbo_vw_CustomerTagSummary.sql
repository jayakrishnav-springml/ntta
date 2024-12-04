CREATE OR REPLACE VIEW EDW_TRIPS.vw_CustomerTagSummary AS WITH cte_tags_summary AS (
    SELECT
        fact_customertagdetail.monthid,
        fact_customertagdetail.customerid,
        fact_customertagdetail.rebillamountgroupid,
        fact_customertagdetail.rebillamount,
        fact_customertagdetail.accounttypeid,
        fact_customertagdetail.accountstatusid,
        fact_customertagdetail.autoreplenishmentid,
        fact_customertagdetail.zipcode,
        fact_customertagdetail.accountcreatedate,
        fact_customertagdetail.accountlastclosedate,
        sum(fact_customertagdetail.monthendtag) - sum(fact_customertagdetail.monthbegintag) AS monthlytagschange,
        sum(fact_customertagdetail.monthbegintag) AS monthbegintags,
        sum(fact_customertagdetail.openedtag) AS openedtags,
        sum(fact_customertagdetail.closedtag) AS closedtags,
        sum(fact_customertagdetail.monthendtag) AS monthendtags,
        sum(fact_customertagdetail.monthbegintag) + sum(fact_customertagdetail.openedtag) - sum(fact_customertagdetail.closedtag) AS calc_monthendtags,
        sum(fact_customertagdetail.monthbegintag) + sum(fact_customertagdetail.openedtag) - sum(fact_customertagdetail.closedtag) - sum(fact_customertagdetail.monthendtag) AS diff_monthendtags,
        CASE
            WHEN sum(fact_customertagdetail.monthbegintag) + sum(fact_customertagdetail.openedtag) - sum(fact_customertagdetail.closedtag) = sum(fact_customertagdetail.monthendtag) THEN 'OK'
            ELSE 'NOT OK'
        END AS tagdiffcheck,
        CASE
            WHEN sum(fact_customertagdetail.openedtag) > sum(fact_customertagdetail.closedtag) THEN sum(fact_customertagdetail.openedtag) - sum(fact_customertagdetail.closedtag)
            ELSE 0
        END AS newtags,
        CASE
            WHEN sum(fact_customertagdetail.openedtag) >= sum(fact_customertagdetail.closedtag) THEN sum(fact_customertagdetail.closedtag)
            ELSE sum(fact_customertagdetail.openedtag)
        END AS existingtags
    FROM
        EDW_TRIPS.Fact_CustomerTagDetail
    GROUP BY
        1,
        2,
        3,
        4,
        5,
        6,
        7,
        8,
        9,
        10
)
SELECT
    cte_tags_summary.*,
    CASE
        WHEN cte_tags_summary.monthbegintags = 0 THEN 0
        ELSE 1
    END AS monthbegincustomers,
    CASE
        WHEN cte_tags_summary.monthbegintags = 0
        AND (
            cte_tags_summary.openedtags > 0
            OR cte_tags_summary.monthendtags > 0
        ) THEN 1
        ELSE 0
    END AS newcustomers,
    CASE
        WHEN (
            cte_tags_summary.monthbegintags > 0
            OR cte_tags_summary.openedtags > 0
        )
        AND cte_tags_summary.monthendtags = 0 THEN 1
        ELSE 0
    END AS lostcustomers,
    CASE
        WHEN cte_tags_summary.monthendtags = 0 THEN 0
        ELSE 1
    END AS monthendcustomers
FROM
    cte_tags_summary;