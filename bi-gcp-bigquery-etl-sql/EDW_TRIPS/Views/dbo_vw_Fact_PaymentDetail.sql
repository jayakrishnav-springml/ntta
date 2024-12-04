## Translation time: 2024-03-06T12:00:18.105749Z
## Translation job ID: d4b7ca8f-acb6-42c7-87e7-c4d11bf0a997
## Source: ntta-gcp-poc-source-code-scripts/APS1_DDLs_latest/EDW_TRIPS/Views/dbo_vw_Fact_PaymentDetail.sql
## Translated from: SqlServer
## Translated to: BigQuery

CREATE OR REPLACE VIEW EDW_TRIPS.vw_Fact_PaymentDetail AS SELECT
    pmtdet.invoiceid,
    pmtdet.citationid,
    pmtdet.tptripid,
    pmtdet.channelid,
    pmtdet.paymentmodeid,
    pmtdet.paymentstatusid,
    pmtdet.refpaymentstatusid,
    pmtdet.paymentid,
    pmtdet.refpaymentid,
    pmtdet.overpaymentid,
    pmtdet.paymentdayid,
    pmtdet.invoicenumber,
    invdet.zcinvoicedate,
    coalesce(invdet.txndate, CAST( v.transactiondate as DATE), CAST( tolltxn.txndatetime as DATE)) AS txndate,
    coalesce(invdet.posteddate, CAST( v.posteddate as DATE), CAST( tolltxn.posteddate as DATE)) AS posteddate,
    pmtdet.laneid,
    pmtdet.customerid,
    pmtdet.amountreceived,
    pmtdet.fnfeespaid,
    pmtdet.snfeespaid,
    coalesce(invdet.avitollamount, v.avitollamount, tolltxn.avitollamount) AS avitollamount,
    coalesce(invdet.pbmtollamount, v.pbmtollamount, tolltxn.pbmtollamount) AS pbmtollamount,
    invdet.fnfees,
    invdet.snfees,
    NULL AS overpaymentamount,
    CASE
      WHEN invdet.deleteflag = 1
       OR pmtdet.deleteflag = 1
       OR tolltxn.deleteflag = 1
       OR v.deleteflag = 1 THEN 1
      ELSE 0
    END AS deleteflag
  FROM
    EDW_TRIPS.Fact_PaymentDetail AS pmtdet
    LEFT OUTER JOIN (
      SELECT
          Fact_InvoiceDetail.citationid,
          Fact_InvoiceDetail.invoicenumber,
          Fact_InvoiceDetail.tptripid,
          Fact_InvoiceDetail.zcinvoicedate,
          Fact_InvoiceDetail.txndate,
          Fact_InvoiceDetail.posteddate,
          Fact_InvoiceDetail.avitollamount,
          Fact_InvoiceDetail.pbmtollamount,
          Fact_InvoiceDetail.fnfees,
          Fact_InvoiceDetail.snfees,
          Fact_InvoiceDetail.currentinvflag,
          Fact_InvoiceDetail.deleteflag
        FROM
          EDW_TRIPS.Fact_InvoiceDetail
        WHERE Fact_InvoiceDetail.currentinvflag = 1
         AND txndate <>DATE'9999-12-31'
    ) AS invdet ON pmtdet.invoicenumber = invdet.invoicenumber
     AND pmtdet.citationid = invdet.citationid
    LEFT OUTER JOIN (
      SELECT
          Fact_Violation.citationid,
          Fact_Violation.tptripid,
          Fact_Violation.transactiondate,
          Fact_Violation.posteddate,
          Fact_Violation.avitollamount,
          Fact_Violation.pbmtollamount,
          Fact_Violation.deleteflag
        FROM
          EDW_TRIPS.Fact_Violation
    ) AS v ON pmtdet.citationid = v.citationid
     AND v.tptripid = pmtdet.tptripid
    LEFT OUTER JOIN (
      SELECT
          Fact_TollTransaction.custtripid,
          Fact_TollTransaction.tptripid,
          Fact_TollTransaction.posteddate,
          Fact_TollTransaction.txndatetime,
          Fact_TollTransaction.avitollamount,
          Fact_TollTransaction.pbmtollamount,
          Fact_TollTransaction.deleteflag
        FROM
          EDW_TRIPS.Fact_TollTransaction
    ) AS tolltxn ON pmtdet.citationid = tolltxn.custtripid
     AND tolltxn.tptripid = pmtdet.tptripid
UNION ALL
SELECT
    -1 AS invoiceid,
    -1 AS citationid,
    -1 AS tptripid,
    channelid,
    paymentmodeid,
    paymentstatusid,
    refpaymentstatusid,
    paymentid,
    refpaymentid,
    paymentid AS overpaymentid,
    paymentdayid,
    -1 AS invoicenumber,
    '1900-01-01' AS zcinvoicedate,
    '1900-01-01' AS txndate,
    '1900-01-01' AS posteddate,
    -1 AS laneid,
    customerid,
    NULL AS amountreceived,
    NULL AS fnfeespaid,
    NULL AS snfeespaid,
    NULL AS avitollamount,
    NULL AS pbmtollamount,
    NULL AS fnfees,
    NULL AS snfees,
    lineitemamount AS overpaymentamount,
    deleteflag
  FROM
    EDW_TRIPS.fact_CustomerPaymentDetail AS f
    INNER JOIN EDW_TRIPS.Dim_AppTxnType AS att ON att.apptxntypeid = f.apptxntypeid
  WHERE att.apptxntypecode IN(
    'APPZCOVRPMT', 'APPZCUNIDOVRPMT', 'APPPOSTOVRPMT', 'APPPOSTUNIDOVRPMT'
  )
   AND refpaymentid = 0
   AND customerpaymenttypeid = 1
UNION ALL
SELECT
    -1 AS invoiceid,
    -1 AS citationid,
    -1 AS tptripid,
    pmt.channelid,
    pmt.paymentmodeid,
    pmt.paymentstatusid,
    pmt.refpaymentstatusid,
    pmt.paymentid,
    pmt.refpaymentid,
    orig.paymentid AS overpaymentid,
    pmt.paymentdayid,
    -1 AS invoicenumber,
    '1900-01-01' AS zcinvoicedate,
    '1900-01-01' AS txndate,
    '1900-01-01' AS posteddate,
    -1 AS laneid,
    orig.customerid,
    NULL AS amountreceived,
    NULL AS fnfeespaid,
    NULL AS snfeespaid,
    NULL AS avitollamount,
    NULL AS pbmtollamount,
    NULL AS fnfees,
    NULL AS snfees,
    orig.lineitemamount * -1 AS overpaymentamount,
    pmt.deleteflag
  FROM
    (
      SELECT DISTINCT
          f.paymentid,
          f.paymentstatusid,
          f.refpaymentid,
          f.refpaymentstatusid,
          f.channelid,
          f.paymentmodeid,
          f.paymentdayid,
          f.deleteflag
        FROM
          EDW_TRIPS.fact_CustomerPaymentDetail AS f
        WHERE f.refpaymentid > 0
         AND f.paymentstatusid = 109
         AND f.customerpaymenttypeid = 1
    ) AS pmt
    INNER JOIN EDW_TRIPS.fact_CustomerPaymentDetail AS orig ON pmt.refpaymentid = orig.paymentid
    INNER JOIN EDW_TRIPS.Dim_AppTxnType AS att ON att.apptxntypeid = orig.apptxntypeid
  WHERE att.apptxntypecode IN(
    'APPZCOVRPMT', 'APPZCUNIDOVRPMT', 'APPPOSTOVRPMT', 'APPPOSTUNIDOVRPMT'
  )
   AND orig.refpaymentid = 0
   AND orig.customerpaymenttypeid = 1
   AND orig.paymentstatusid IN(
    119, 3182
  )
;
