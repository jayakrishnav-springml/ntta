CREATE VIEW [dbo].[vw_ViolationStatus] AS SELECT 
      VIOL_STATUS			AS ViolationStatus
    , VIOL_STATUS_DESCR			AS ViolationStatusName
FROM [dbo].[VIOL_STATUS];
