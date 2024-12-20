CREATE VIEW [dbo].[vw_ViolatorCallLog] AS SELECT  
		  ViolatorCallLogID 
		, ViolatorID
		, VidSeq
		, Convert(smallint,1)  AS CallCount
		, Convert(smallint,1)  AS CallFlag
		, ViolatorCallLogLookupID
		, OutgoingCallFlag
		, PhoneNbr
		, ConnectedFlag
		, CreatedDate
		, CreatedBy
		, UpdatedDate
		, UpdatedBy
	FROM dbo.ViolatorCallLog
	UNION ALL 
	SELECT  
		  0 AS ViolatorCallLogID
		, ViolatorID
		, VidSeq
		, Convert(smallint,0) AS CallCount
		, Convert(smallint,0) AS CallFlag
		, -1 AS ViolatorCallLogLookupID  
		, -1 AS OutgoingCallFlag
		, null as PhoneNbr
		, -1 AS ConnectedFlag
		, null AS CreatedDate
		, null AS CreatedBy
		, null AS UpdatedDate
		, null AS UpdatedBy
	FROM dbo.Violator a
	WHERE NOT EXISTS (SELECT 1 FROM dbo.ViolatorCallLog b WHERE a.ViolatorID = b.ViolatorID and a.VidSeq = b.VidSeq);
