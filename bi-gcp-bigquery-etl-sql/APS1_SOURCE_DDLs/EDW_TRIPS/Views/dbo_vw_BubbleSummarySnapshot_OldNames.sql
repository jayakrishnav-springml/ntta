CREATE VIEW [dbo].[vw_BubbleSummarySnapshot_OldNames] AS (
SELECT 
       SS.SnapshotMonthID
	   , SS.AsOfDayID -- New!
	   , SS.RowSeq -- New!
       , SS.TripMonthID					AS [TxnYr Mnth]  
       , SS.TripMonthID/100				AS TripYear -- New!
       , SS.FacilityCode				AS Facility 
       , SS.OperationsAgency			AS Agency 
       , SS.OperationsMappingID
       , SS.Mapping
       , SS.MappingDetailed				AS Mapping_Detailed 
       , SS.PursUnpursStatus			AS Purs_UnPurs_Calc 
       , RT.RecordType
       , TIM.TripIdentMethod
       , SS.TripWith
       , TPT.TransactionPostingType
       , SS.TripStageID
       , TSG.TripStageCode
       , TSG.TripStageDesc				AS TripStageDescription 
       , SS.TripStatusID
       , TST.TripStatusCode
       , TST.TripStatusDesc				AS TripStatusDescription 
       , RC.ReasonCode
       , CSG.CitationStageCode			AS CitationStage 
       , PS.TripPaymentStatusDesc		AS PaymentStatus 
       , SS.SourceName
       , SS.TxnCount
       , SS.ExpectedAmount				AS [ExpectedAmount ($)] 
       , SS.AdjustedExpectedAmount		AS [AdjustedExpectedAmount ($)] 
       , SS.CalcAdjustedAmount			AS [CalcAdjustedAmount ($)] 
       , SS.TripWithAdjustedAmount		AS [TripWithAdjustedAmount ($)] 
       , SS.TollAmount					AS [TollAmount ($)] 
       , SS.ActualPaidAmount			AS [PaidAmount ($)] 
       , SS.OutStandingAmount			AS [OutStandingAmount ($)] 
       , SS.BadAddressFlag				AS BadAddress 
       , SS.NonRevenueFlag				AS isNonRevenue 
       , SS.BusinessRuleMatchedFlag		AS isBusinessRuleMatched 
	   , SS.OOSPlateFlag				AS isOOSPlate 
       , SS.ManuallyReviewedFlag		AS isManuallyReviewed 
	   , SS.ClassAdjustmentFlag			AS isClassAdjustment
       , CAST(0 AS SMALLINT)			AS isIOPDuplicate 
       , SS.FirstPaidMonthID
       , SS.LastPaidMonthID
	   , CAST(''''+ SS.Rpt_PaidvsAEA AS VARCHAR(5))	AS Rpt_PaidvsAEA
	   , SS.Rpt_PurUnP
	   , SS.Rpt_LPState
	   , SS.Rpt_InvUnInv
	   , SS.Rpt_VToll
       , SS.Rpt_IRStatus
       , SS.Rpt_ProcessStatus
       , SS.Rpt_PaidStatus
       , SS.Rpt_IRRejectStatus 	
	FROM dbo.Fact_UnifiedTransaction_SummarySnapshot SS
		JOIN dbo.Dim_TripIdentMethod TIM ON TIM.TripIdentMethodID = SS.TripIdentMethodID
		JOIN dbo.Dim_TransactionPostingType TPT ON TPT.TransactionPostingTypeID = SS.TransactionPostingTypeID
		JOIN dbo.Dim_TripStage TSG ON TSG.TripStageID = SS.TripStageID
		JOIN dbo.Dim_TripStatus TST ON TST.TripStatusID = SS.TripStatusID
        JOIN dbo.Dim_ReasonCode RC ON RC.ReasonCodeID = SS.ReasonCodeID
        JOIN dbo.Dim_CitationStage CSG ON CSG.CitationStageID = SS.CitationStageID
		JOIN dbo.Dim_TripPaymentStatus PS ON PS.TripPaymentStatusID =	SS.TripPaymentStatusID 
        JOIN dbo.Dim_RecordType RT ON RT.RecordTypeID = SS.RecordTypeID
);
