CREATE VIEW [dbo].[vw_ViolatorInvoiceStatus] AS SELECT 
      VIOL_INV_STATUS			AS ViolatorInvoiceStatus
    , VIOL_INV_STATUS_DESCR		AS ViolatorInvoiceStatusName
FROM [dbo].[VIOL_INV_STATUS];
