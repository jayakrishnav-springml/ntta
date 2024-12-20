CREATE VIEW [dbo].[vw_Fact_PaymentDetail] AS SELECT PmtDet.InvoiceID,
	   PmtDet.CitationID,
	   PmtDet.TpTripID,
       PmtDet.ChannelID,
       PmtDet.PaymentModeID,
       PmtDet.PaymentStatusID,
	   PmtDet.RefPaymentStatusID,
       PmtDet.PaymentID,
	   PmtDet.RefPaymentID,
	   PmtDet.OverpaymentID,
       PmtDet.PaymentDayID,
       PmtDet.InvoiceNumber,
       InvDet.ZCInvoiceDate,
       COALESCE(InvDet.TxnDate, CAST(V.TransactionDate AS DATE), CAST(TollTxn.TxnDatetime AS DATE)) TXNDate,
       COALESCE(InvDet.PostedDate, CAST(V.PostedDate AS DATE), CAST(TollTxn.PostedDate AS DATE)) PostedDate,
       PmtDet.LaneID,
       PmtDet.CustomerID,
       PmtDet.AmountReceived,
       PmtDet.FNFeesPaid,
       PmtDet.SNFeesPaid,
       COALESCE(InvDet.AVITollAmount, V.AviTollAmount, TollTxn.AVITollAmount) AVITollAMount,
       COALESCE(InvDet.PBMTollAmount, V.PBMTollAmount, TollTxn.PBMTollAmount) PBMTollAmount,
       InvDet.FNFees,
       InvDet.SNFees,
	   NULL AS OverpaymentAmount,
	   CAST(CASE WHEN InvDet.DeleteFlag = 1 OR PmtDet.DeleteFlag = 1 OR TollTxn.DeleteFlag = 1 OR V.DeleteFlag = 1 THEN 1 ELSE 0 END AS BIT) DeleteFlag
FROM dbo.Fact_PaymentDetail  PmtDet
    LEFT JOIN
    (
        SELECT CitationID,
               InvoiceNumber,
               TPTripID,
               ZCInvoiceDate,
               TxnDate,
               PostedDate,
               AVITollAmount,
               PBMTollAmount,
               FNFees,
               SNFees,
               CurrentInvFlag,
			   DeleteFlag
        FROM dbo.Fact_InvoiceDetail
        WHERE CurrentInvFlag = 1
    ) InvDet
        ON PmtDet.InvoiceNumber = InvDet.InvoiceNumber
           AND PmtDet.CitationID = InvDet.CitationID
    LEFT JOIN
    (
        SELECT CitationID,
               TPTripID,
               TransactionDate,
               PostedDate,
               AviTollAmount,
               PBMTollAmount,
			   DeleteFlag
        FROM dbo.Fact_Violation
    ) V
        ON PmtDet.CitationID = V.CitationID AND V.TPTripID = PmtDet.TPTripID
    LEFT JOIN
    (
        SELECT CustTripID,
               TPTripID,
               PostedDate,
               TxnDatetime,
               AVITollAmount,
               PBMTollAmount,
			   DeleteFlag
        FROM dbo.Fact_TollTransaction
    ) TollTxn
        ON PmtDet.CitationID = TollTxn.CustTripID AND TollTxn.TPTripID = PmtDet.TPTripID 

UNION ALL

SELECT  -1 InvoiceID,
	    -1 CitationID,
	    -1 TpTripID,
        ChannelID,
        PaymentModeID,
        PaymentStatusID,
	    RefPaymentStatusID,
        PaymentID,
	    RefPaymentID,
		PaymentID AS OverpaymentID,
        PaymentDayID,
        -1 InvoiceNumber,
        '1900-01-01' ZCInvoiceDate,
        '1900-01-01' TXNDate,
        '1900-01-01' PostedDate,
        -1 LaneID,
        CustomerID,
        NULL AmountReceived,
        NULL FNFeesPaid,
        NULL SNFeesPaid,
        NULL AVITollAMount,
        NULL PBMTollAmount,
        NULL FNFees,
        NULL SNFees,
		LineItemAmount OverpaymentAmount,
	    DeleteFlag
FROM	dbo.fact_CustomerPaymentDetail f
JOIN	dbo.Dim_AppTxnType att
		ON att.AppTxnTypeID = f.AppTxnTypeID
WHERE	att.AppTxnTypeCode IN ('APPZCOVRPMT','APPZCUNIDOVRPMT','APPPOSTOVRPMT' ,'APPPOSTUNIDOVRPMT')
AND		RefPaymentID = 0
AND		CustomerPaymentTypeID = 1
  
UNION ALL

SELECT  -1 InvoiceID,
	    -1 CitationID,
	    -1 TpTripID,
        PMT.ChannelID,
        PMT.PaymentModeID,
        PMT.PaymentStatusID,
	    PMT.RefPaymentStatusID,
        PMT.PaymentID,
	    PMT.RefPaymentID,
		ORIG.PaymentID AS OverpaymentID,
        PMT.PaymentDayID,
        -1 InvoiceNumber,
        '1900-01-01' ZCInvoiceDate,
        '1900-01-01' TXNDate,
        '1900-01-01' PostedDate,
        -1 LaneID,
        ORIG.CustomerID,
        NULL AmountReceived,
        NULL FNFeesPaid,
        NULL SNFeesPaid,
        NULL AVITollAMount,
        NULL PBMTollAmount,
        NULL FNFees,
        NULL SNFees,
		ORIG.LineItemAmount * -1 OverpaymentAmount,
	    PMT.DeleteFlag
FROM 
	(
		SELECT	DISTINCT f.PaymentID, f.PaymentStatusID, f.RefPaymentID, f.RefPaymentStatusID, f.ChannelID, f.PaymentModeID, f.PaymentDayID, f.DeleteFlag 
		FROM	dbo.fact_CustomerPaymentDetail f
		WHERE	f.RefPaymentID > 0
		AND		f.PaymentStatusID = 109
		AND		CustomerPaymentTypeID = 1
	)	PMT
JOIN	dbo.fact_CustomerPaymentDetail ORIG
		ON PMT.RefPaymentID = ORIG.PaymentID
JOIN	dbo.Dim_AppTxnType att
		ON att.AppTxnTypeID = ORIG.AppTxnTypeID
WHERE	att.AppTxnTypeCode IN ('APPZCOVRPMT','APPZCUNIDOVRPMT','APPPOSTOVRPMT' ,'APPPOSTUNIDOVRPMT')
AND		ORIG.RefPaymentID = 0
AND		ORIG.CustomerPaymentTypeID = 1
AND		ORIG.PaymentStatusID IN (119, 3182);
