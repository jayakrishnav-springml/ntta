CREATE VIEW [dbo].[vw_BubbleSummarySnapshot] AS (
SELECT 
       SS.SnapshotMonthID
	   , SS.AsOfDayID -- New! 
	   , SS.RowSeq -- New!
       , SS.TripMonthID
	   , SS.TripMonthID/100	 AS TripYearID -- New!
       , SS.FacilityCode				
       , SS.OperationsAgency			
       , SS.OperationsMappingID
       , SS.Mapping
       , SS.MappingDetailed				
       , SS.PursUnpursStatus
       , RT.RecordType
       , TIM.TripIdentMethod
       , SS.TripWith
       , TPT.TransactionPostingType
       , SS.TripStageID
       , TSG.TripStageCode
       , TSG.TripStageDesc				
       , SS.TripStatusID
       , TST.TripStatusCode
       , TST.TripStatusDesc				
       , RC.ReasonCode
       , CSG.CitationStageCode			
       , PS.TripPaymentStatusDesc		
       , SS.SourceName
       , SS.TxnCount
       , SS.ExpectedAmount				
       , SS.AdjustedExpectedAmount		
       , SS.CalcAdjustedAmount			
       , SS.TripWithAdjustedAmount		
       , SS.TollAmount					
       , SS.ActualPaidAmount			
       , SS.OutStandingAmount			
       , SS.BadAddressFlag				
       , SS.NonRevenueFlag				
       , SS.BusinessRuleMatchedFlag		
	   , SS.OOSPlateFlag				
       , SS.ManuallyReviewedFlag
	   , SS.ClassAdjustmentFlag
       , CAST(0 AS SMALLINT) IOPDuplicateFlag			
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
