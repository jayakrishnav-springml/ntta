CREATE OR REPLACE PROCEDURE `LND_TBOS_SUPPORT.ChargeBack_Export`(stage_dataset STRING, main_datset STRING)
BEGIN
/*
####################################################################################################
Proc Description: 
----------------------------------------------------------------------------------------------------
 1. Load all 5 Export Tables of ChargeBack

================================================================================================
Change Log:
--------------------------------------------------------------------------------------------
********    EGen        07-16-2024     New!
================================================================================================
Example:   
--------------------------------------------------------------------------------------------------

#######################################################################################
*/

  Declare sql STRING;

  -- ReCreating Tables To be used in ChargeBack Export 
  -- Chase PDE0020 Matched to CTW
  set sql = '''
  Create or Replace Table `FILES_EXPORT.Chase_PDE0020_Matched_To_CTW`
  As
  SELECT CR.EntityLevel,CR.EntityID,CR.StatusFlag,CR.SequenceNumber ,
  CR.TransactionDivisionNumber,CR.MerchantOrderNumber,CR.AccountNumber,CR.ReasonCode	
  ,CR.OriginalTransactionDate,CR.ChargebackReceivedDate,CR.ActivityDate,CR.ChargebackAmount,
  CR.CBCycle,CT.SequenceNumber as Sequence_Number ,CT.AmexCaseNumber as Amex_Case_Number ,CT.CustomerName as Customer_Name,
  CT.OrderIDNumber as Order_ID_Number ,CT.CardType as Card_Type,
  CT.LastFourofCC as Last_Four_of_CC,CT.DisputeCode as Dispute_Code,CT.AmountDisputed as Amount_Disputed,
  CT.PrePaidAccount as Pre_Paid_Account,CT.PostPaidAccount as Post_Paid_Account ,
  CT.ZipCashInvoices as ZipCash_Invoices,CT.CaseOwner as Case_Owner ,CT.ReceivedbyNTTA as Received_by_NTTA,
  CT.DateReplied as Date_Replied ,CT.TransactionDate as Transaction_Date,CT.TSADays as TSA_Days,
  CT.HowPaymentwasmade as How_payment_was_made,CT.CurrentDisputeStatus as Current_Dispute_Status,
  CT.Comments,CT.Notes,CT.WinLostSupervisorReview as `Win-Lost_Supervisor_Review`,
  CT.DateReviewed as Date_Reviewed,CT.ReversalCaseNumber as Reversal_Case_Number,
  CT.CaseDate as Case_Date,CT.date_case_approved as `Date_Case_#_Approved`,
  CT.ManagerReview as Manager_Review ,CT.Airport 
  FROM @Stage_Dataset.dbo_ChargeBack_Received CR
  JOIN @Stage_Dataset.dbo_ChargeBack_Tracking CT
  ON CR.MerchantOrderNumber=CT.OrderIDNumber
  ORDER BY CR.MerchantOrderNumber
  ''';

  set sql = Replace(sql,'@Stage_Dataset', stage_dataset);
  EXECUTE IMMEDIATE sql ;

  -- Chase PDE0020 NotMatched to CTW
  set sql = '''Create or Replace Table `FILES_EXPORT.Chase_PDE0020_NonMatched_to_CTW`
    AS
  SELECT CR.EntityLevel,CR.EntityID,CR.StatusFlag,CR.SequenceNumber ,CR.TransactionDivisionNumber,CR.MerchantOrderNumber,CR.AccountNumber,CR.ReasonCode	
  ,CR.OriginalTransactionDate,CR.ChargebackReceivedDate,CR.ActivityDate,CR.ChargebackAmount,CR.CBCycle,
  CT.SequenceNumber as Sequence_Number ,CT.AmexCaseNumber as Amex_Case_Number ,CT.CustomerName as Customer_Name,
  CT.OrderIDNumber as Order_ID_Number ,CT.CardType as Card_Type,
  CT.LastFourofCC as Last_Four_of_CC,CT.DisputeCode as Dispute_Code,CT.AmountDisputed as Amount_Disputed,
  CT.PrePaidAccount as Pre_Paid_Account,CT.PostPaidAccount as Post_Paid_Account ,
  CT.ZipCashInvoices as ZipCash_Invoices,CT.CaseOwner as Case_Owner ,CT.ReceivedbyNTTA as Received_by_NTTA,
  CT.DateReplied as Date_Replied ,CT.TransactionDate as Transaction_Date,CT.TSADays as TSA_Days,
  CT.HowPaymentwasmade as How_payment_was_made,CT.CurrentDisputeStatus as Current_Dispute_Status,
  CT.Comments,CT.Notes,CT.WinLostSupervisorReview as `Win-Lost_Supervisor_Review`,
  CT.DateReviewed as Date_Reviewed,CT.ReversalCaseNumber as Reversal_Case_Number,
  CT.CaseDate as Case_Date,CT.date_case_approved as `Date_Case_#_Approved`,
  CT.ManagerReview as Manager_Review ,CT.Airport 
  FROM @Stage_Dataset.dbo_ChargeBack_Received CR
  LEFT JOIN @Stage_Dataset.dbo_ChargeBack_Tracking CT
  ON CR.MerchantOrderNumber=CT.OrderIDNumber
  where CT.OrderIDNumber is null
  ORDER BY CR.MerchantOrderNumber''';
  
  set sql = Replace(sql,'@Stage_Dataset', stage_dataset);
  EXECUTE IMMEDIATE sql ;
  
  -- Load AMEX Matched to CTW
  set sql = '''Create OR REPLACE TABLE `FILES_EXPORT.AMEX_Matched_to_CTW`
  AS
  SELECT
  CA.WinLossStatus,CA.CaseNumber,CA.CardNumber,CA.SENumber,CA.OriginalReasonCode,CA.OriginalReasonCodeDescription,CA.ChargeReferenceNumber,CA.ChargebackStatus	
  ,FORMAT_DATE("%m/%d/%Y", CA.ReplyByDate) as ReplyByDate,FORMAT_DATE("%m/%d/%Y", CA.RespondedOnDate) as RespondedOnDate,FORMAT_DATE("%m/%d/%Y", CA.CBDateReceived) as CBDateReceived,CA.ChargebackAmount,CA.ChargebackAmountCurrencyCode,CA.CaseUpdateDate,CA.CaseUpdateAmount,CA.CaseUpdateAmountCurrencyCode	
  ,FORMAT_DATE("%m/%d/%Y", CA.AdjustmentDate) as AdjustmentDate,CA.AdjustmentNumber,CA.ChargeAmount,CA.ChargeAmountCurrency,CA.DisputeAmount,CA.DisputeAmountCurrencyCode,CA.CaseNote,CA.MerchantInitials,CA.ResponseNotes,CA.CaseCurrentStatus
  ,CA.UpdatedReasonCode,CA.UpdatedReasonCodeDescription,CT.SequenceNumber,CT.AmexCaseNumber,CT.CustomerName,CT.OrderIDNumber,CT.CardType,CT.LastFourofCC,CT.DisputeCode,CT.AmountDisputed,
  CT.PrePaidAccount,CT.PostPaidAccount,CT.ZipCashInvoices,CT.CaseOwner,CT.ReceivedbyNTTA,CT.DateReplied,CT.TransactionDate,CT.TSADays,CT.HowPaymentwasmade,CT.CurrentDisputeStatus,
  CT.Comments,CT.Notes,CT.WinLostSupervisorReview,CT.DateReviewed,CT.ReversalCaseNumber, CT.CaseDate,CT.date_case_approved as `DateCase#Approved`,CT.ManagerReview,CT.Airport
  FROM  @Stage_Dataset.dbo_ChargeBack_AMEX CA
  JOIN  @Stage_Dataset.dbo_ChargeBack_Tracking CT
  ON CA.ChargeReferenceNumber=CT.OrderIDNumber
  ORDER BY CA.ChargeReferenceNumber''';

  set sql = Replace(sql,'@Stage_Dataset', stage_dataset);
  EXECUTE IMMEDIATE sql ;

 -- Load AMEX Not Matched to CTW
  set sql = '''Create Or Replace TABLE  `FILES_EXPORT.AMEX_Not_Matched_to_CTW`
  AS
  SELECT
  CA.WinLossStatus,CA.CaseNumber,CA.CardNumber,CA.SENumber,CA.OriginalReasonCode,CA.OriginalReasonCodeDescription,CA.ChargeReferenceNumber,CA.ChargebackStatus	
  ,CA.ReplyByDate,CA.RespondedOnDate,CA.CBDateReceived,CA.ChargebackAmount,CA.ChargebackAmountCurrencyCode,CA.CaseUpdateDate,CA.CaseUpdateAmount,CA.CaseUpdateAmountCurrencyCode	
  ,CA.AdjustmentDate,CA.AdjustmentNumber,CA.ChargeAmount,CA.ChargeAmountCurrency,CA.DisputeAmount,CA.DisputeAmountCurrencyCode,CA.CaseNote,CA.MerchantInitials,CA.ResponseNotes,CA.CaseCurrentStatus
  ,CA.UpdatedReasonCode,CA.UpdatedReasonCodeDescription,CT.SequenceNumber,CT.AmexCaseNumber,CT.CustomerName,CT.OrderIDNumber,CT.CardType,CT.LastFourofCC,CT.DisputeCode,CT.AmountDisputed,
  CT.PrePaidAccount,CT.PostPaidAccount,CT.ZipCashInvoices,CT.CaseOwner,CT.ReceivedbyNTTA,CT.DateReplied,CT.TransactionDate,CT.TSADays,CT.HowPaymentwasmade,CT.CurrentDisputeStatus,
  CT.Comments,CT.Notes,CT.WinLostSupervisorReview,CT.DateReviewed,CT.ReversalCaseNumber,CT.CaseDate,CT.date_case_approved as `DateCase#Approved`,CT.ManagerReview,CT.Airport
  FROM  @Stage_Dataset.dbo_ChargeBack_AMEX CA
  LEFT JOIN  @Stage_Dataset.dbo_ChargeBack_Tracking CT
  ON CA.ChargeReferenceNumber=CT.OrderIDNumber
  WHERE CT.OrderIDNumber IS NULL
  ORDER BY CA.ChargeReferenceNumber''';

  set sql = Replace(sql,'@Stage_Dataset', stage_dataset);
  EXECUTE IMMEDIATE sql ;
  
  --TRIPS Matched TO CTW
  set sql = '''Create or Replace Table `FILES_EXPORT.TRIPS_Matched_TO_CTW`
  AS
  select  
  pmt.PaymentID,
  pmt.PaymentDate,
  Concat('"' ,pmt.VoucherNo, '"') as VoucherNo,
  Concat('"' ,pmt.SubSystem,'"' ) as SubSystem,
  pmt.PaymentModeID,
  Concat('"' ,pmt.IntiatedBy,'"' ) as IntiatedBy,
  Concat('"' ,pmt.ActivityType,'"' ) as ActivityType,
  Concat('"' ,pmt.StatementNote,'"' ) as StatementNote,
  pmt.TxnAmount,
  pmt.PaymentStatusID,
  pmt.RefPaymentID,
  Concat('"' ,pmt.RefType,'"' ) as RefType,
  pmt.SourcePKID,
  pmt.AccountStatusID,
  Concat('"' ,pmt.ApprovedBy,'"' ) as ApprovedBy,
  pmt.ChannelID,
  pmt.LocationID,
  pmt.SourceOfEntry,
  Concat('"' ,pmt.ReasonText,'"' ) as ReasonText,
  pmt.ICNID,
  pmt.IsVirtualCheck,
  Concat('"' ,pmt.PmtTxnType,'"' ) as PmtTxnType,
  pmt.SourcePmtID,
  pmt.CreatedDate,
  Concat('"' ,pmt.CreatedUser,'"' ) as CreatedUser,
  pmt.UpdatedDate,
  Concat('"' ,pmt.UpdatedUser,'"' ) as UpdatedUser,
  Concat('"' ,ps.LOOKUPTYPECODE,'"' ) as LOOKUPTYPECODE,
  CT.*
  FROM LND_TBOS.FINANCE_PAYMENTTXNS pmt
  JOIN LND_TBOS.TOLLPLUS_REF_LOOKUPTYPECODES_HIERARCHY ps
  on pmt.PAYMENTSTATUSID=ps.LOOKUPTYPECODEID
  join @Stage_Dataset.dbo_ChargeBack_Tracking CT
  on CAST(paymentID AS STRING)= Cast(CT.OrderIDNumber as STRING)''';

  set sql = Replace(sql,'@Stage_Dataset', stage_dataset);
  EXECUTE IMMEDIATE sql ;

  EXCEPTION WHEN ERROR THEN
    BEGIN
      DECLARE error_message STRING DEFAULT @@error.message;
      Select Concat("Error : ",error_message);
      RAISE USING MESSAGE = error_message;  -- Rethrow the error!
    END;
END;