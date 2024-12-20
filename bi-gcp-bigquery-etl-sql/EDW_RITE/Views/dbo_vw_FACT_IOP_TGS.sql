CREATE VIEW [dbo].[vw_FACT_IOP_TGS] AS SELECT --TOP(1000) 
		IOP_TXN_ID,
		DAY_ID,
		TAG_ID,
		TXN_DATE,
		POSTED_DATE,
		T.TAG_IDENTIFIER,
		TXN_TYPE,
		AGENCY_TXN_TYPES.MAX_FARE_AMT,
		AGENCY_TXN_TYPES.MIN_FARE_AMT,
		AGENCY_TXN_TYPES.MAX_TXN_AGE,
		AGENCY_TXN_TYPES.COMMENTS AS TXN_TYPE_COMMENTS,
		T.TXN_STATUS,
		TXN_STATUSES.TXN_STATUS_DESC,
		T.DISPOSITION,
		DISPOSITION_DESCR,
		SOURCE_AGCY_ID,
		AGENCIES.ABBREV AS SOURCE_AGENCY_ABBREV,
		AGENCIES.[NAME] AS SOURCE_AGENCY_NAME,
		HIA_AGENCY_ID,
		HIA.ABBREV AS HIA_AGENCY_ABBREV,
		HIA.[NAME] AS HIA_AGENCY_NAME,
		T.SOURCE_CODE,
		SOURCE_CODE_DESC,
		SOURCE_TXN_ID,
		T.LANE_ID,
		LOC,
		T.TVL_TAG_STATUS,
		TVL_TAG_STATUS_DESC,
		LIC_PLATE_STATE,
		LIC_PLATE_NBR,
		EARNED_CLASS,
		POSTED_CLASS,
		EARNED_REVENUE,
		POSTED_REVENUE,
		LANE_ABBREV, 
		LANE_NAME, 
		LANE_DIRECTION, 
		PLAZA_ABBREV, 
		PLAZA_NAME, 
		SUB_FACILITY_ABBREV, 
		FACILITY_ABBREV, 
		FACILITY_NAME, 
		SUB_AGENCY_ABBREV, 
		AGENCY_ABBREV, 
		AGENCY_NAME  --SELECT COUNT_BIG(1) --SELECT  TOP(100) *--T.ACCT_ID, T.TAG_ID, 
	FROM   [dbo].FACT_IOP_TGS T	--211,547,496
	LEFT JOIN LND_LG_IOP.IOP_OWNER.AGENCY_TXN_TYPES ON TXN_TYPE = IOP_TXN_TYPE
	LEFT JOIN LND_LG_IOP.IOP_OWNER.TXN_STATUSES ON T.TXN_STATUS = TXN_STATUSES.TXN_STATUS
	LEFT JOIN EDW_RITE.dbo.DIM_DISPOSITION ON T.DISPOSITION = DIM_DISPOSITION.DISPOSITION
	LEFT JOIN LND_LG_IOP.FPL_OWNER.AGENCIES ON T.SOURCE_AGCY_ID = AGENCIES.AGCY_ID
	LEFT JOIN LND_LG_IOP.FPL_OWNER.AGENCIES HIA ON T.HIA_AGENCY_ID = HIA.AGCY_ID
	LEFT JOIN LND_LG_IOP.IOP_OWNER.TXN_SOURCE_CODES ON T.SOURCE_CODE = TXN_SOURCE_CODES.SOURCE_CODE
	LEFT JOIN LND_LG_IOP.IOP_OWNER.TVL_TAG_STATUSES ON T.TVL_TAG_STATUS = TVL_TAG_STATUSES.TVL_TAG_STATUS
	LEFT JOIN [DBO].DIM_LANE L ON L.LANE_ID = T.LANE_ID 
	WHERE T.DISPOSITION = 'P';
