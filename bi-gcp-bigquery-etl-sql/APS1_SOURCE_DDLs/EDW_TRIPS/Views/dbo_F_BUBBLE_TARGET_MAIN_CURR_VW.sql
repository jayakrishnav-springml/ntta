CREATE VIEW [dbo].[F_BUBBLE_TARGET_MAIN_CURR_VW] AS (
SELECT 
       CAST(FUS.SnapshotMonthID AS NUMERIC(18, 0)) AS [SnapshotMonthID],
       CAST(FUS.TripMonthID AS NUMERIC(18, 0)) AS [TxnYr Mnth],
       DF.[FacilityCode] [Facility],
       FUS.OperationsMappingID,
       DOM.[TripIdentMethod],
       DOM.[SourceName],
       DOM.[TripWith],
       DOM.[TransactionPostingType],
       CAST(DOM.[TripStageID] AS NUMERIC(18, 0)) [TripStageID],
       DOM.[TripStageCode],
       DOM.[TripStageDesc] [TripStageDescription],
       CAST(DOM.[TripStatusID] AS NUMERIC(18, 0)) [TripStatusID],
       DOM.[TripStatusCode],
       DOM.[TripStatusDesc] [TripStatusDescription],
       DOM.[ReasonCode] [ReasonCode],
       DOM.[CitationStageCode] [CitationStage],
       DOM.[TripPaymentStatusDesc] [PaymentStatus],
       CAST(FUS.[TxnCount] AS NUMERIC(18, 0)) AS [TxnCount],
       CAST(FUS.[ExpectedAmount] AS REAL) [ExpectedAmount ($)],
       CAST(FUS.AdjustedExpectedAmount AS REAL) [AdjustedExpectedAmount ($)],
       CAST(FUS.[CalcAdjustedAmount] AS REAL) [CalcAdjustedAmount ($)],
      -- CAST(FUS.[TripWithAdjustedAmount] AS REAL) [TripWithAdjustedAmount ($)],
      -- CAST(FUS.[TollAmount] AS REAL) [TollAmount ($)],
       CAST(FUS.[ActualPaidAmount] AS REAL) [PaidAmount ($)],
       CAST(FUS.[OutStandingAmount] AS REAL) [OutStandingAmount ($)],
       DOM.OperationsAgency [Agency],
       DOM.Mapping,
       DOM.MappingDetailed [Mapping_Detailed],
       DOM.PursUnpursStatus [Purs_UnPurs_Calc],
       CAST(DOM.[BadAddressFlag] AS NUMERIC(18, 0)) [BadAddress],
       CAST(FUS.[NonRevenueFlag] AS NUMERIC(18, 0)) [isNonRevenue],
       CAST(DOM.[BusinessRuleMatchedFlag] AS NUMERIC(18, 0)) [isBusinessRuleMatched],
	   CAST(FUS.[OOSPlateFlag] AS NUMERIC(18, 0)) [isOOSPlate],
       FUS.VTollFlag,
       FUS.ClassAdjustmentFlag,
       CAST(FUS.[ManuallyReviewedFlag] AS NUMERIC(18, 0)) [isManuallyReviewed],
       CAST(0 AS NUMERIC(18, 0)) AS [isIOPDuplicate],
       FUS.FirstPaidMonthID,
       FUS.LastPaidMonthID,
	   FUS.Rpt_PaidvsAEA,
	   FUS.Rpt_PurUnP	,
	   FUS.Rpt_LPState	,
	   FUS.Rpt_InvUnInv	,
	   FUS.Rpt_VToll	,
       FUS.Rpt_IRStatus,
       FUS.Rpt_ProcessStatus,
       FUS.Rpt_PaidStatus,
       FUS.Rpt_IRRejectStatus,
       DRT.RecordType,
	   FUS.EDW_UpdateDate

    FROM [dbo].[Fact_UnifiedTransaction_SummarySnapshot] FUS
          JOIN [dbo].[Dim_OperationsMapping] DOM
                ON DOM.OperationsMappingID = FUS.OperationsMappingID
          JOIN [dbo].[Dim_Facility] DF 
                ON DF.FacilityID =FUS.FacilityID
          JOIN dbo.Dim_RecordType DRT
                ON DRT.RecordTypeID = FUS.RecordTypeID
    WHERE SnapshotMonthID = ( SELECT MAX(SnapshotMonthID) FROM [dbo].[Fact_UnifiedTransaction_SummarySnapshot])

);
