CREATE VIEW [dbo].[vw_ViolatorCallLog_ViolatorCallLogLookup] AS SELECT  
	  ViolatorCallLogLookupId 
	, [Descr] AS ViolatorCallLog
FROM dbo.ViolatorCallLogLookup;
