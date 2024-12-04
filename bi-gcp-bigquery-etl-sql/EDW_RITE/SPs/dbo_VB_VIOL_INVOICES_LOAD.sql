CREATE PROC [DBO].[VB_VIOL_INVOICES_LOAD] AS

/*

USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.VB_VIOL_INVOICES_LOAD') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.VB_VIOL_INVOICES_LOAD
GO


EXEC EDW_RITE.DBO.VB_VIOL_INVOICES_LOAD
*/

/*	
SELECT TOP 100 * FROM VB_VIOL_INVOICES 
WHERE VBI_VBI_INVOICE_ID = -1

SELECT COUNT_BIG(1) FROM VB_VIOL_INVOICES -- 29 413 256 
*/  

/*
INSERT INTO dbo.VB_VIOL_INVOICES
	(	 	  
	VIOLATOR_ID, VBI_VBI_INVOICE_ID, INV_VIOL_INVOICE_ID, DATE_CREATED, LAST_UPDATE_TYPE, LAST_UPDATE_DATE
	)
	VALUES
	(-1,-1,-1,NULL,'I','2000-01-01')

*/

--Ranjith Nair 2017-02-02  Changed Incremental to Full Load

IF OBJECT_ID('dbo.VB_VIOL_INVOICES_STAGE')<>0 	DROP TABLE dbo.VB_VIOL_INVOICES_STAGE

CREATE TABLE dbo.VB_VIOL_INVOICES_STAGE WITH (CLUSTERED INDEX (VBI_VBI_INVOICE_ID, INV_VIOL_INVOICE_ID), DISTRIBUTION = HASH(VBI_VBI_INVOICE_ID))--DISTRIBUTION = HASH(VIOLATOR_ID), CLUSTERED INDEX (VIOLATOR_ID, VBI_VBI_INVOICE_ID)) 
AS 
-- EXPLAIN
SELECT   B.VIOLATOR_ID VIOLATOR_ID, A.VBI_VBI_INVOICE_ID, A.INV_VIOL_INVOICE_ID, A.DATE_CREATED, A.LAST_UPDATE_TYPE, A.LAST_UPDATE_DATE
FROM LND_LG_VPS.[VP_OWNER].[VB_VIOL_INVOICES] A
LEFT JOIN LND_LG_VPS.[VP_OWNER].[VB_INVOICES] B
	ON A.VBI_VBI_INVOICE_ID = B.VBI_INVOICE_ID
OPTION (LABEL = 'VB_VIOL_INVOICES_LOAD: VB_VIOL_INVOICES_STAGE');

INSERT INTO dbo.VB_VIOL_INVOICES_STAGE
	(	 	  
	VIOLATOR_ID, VBI_VBI_INVOICE_ID, INV_VIOL_INVOICE_ID, DATE_CREATED, LAST_UPDATE_TYPE, LAST_UPDATE_DATE
	)
	VALUES
	(-1,-1,-1,NULL,'I','2000-01-01')

CREATE STATISTICS [STATS_VB_VIOL_INVOICES_001] ON EDW_RITE.dbo.[VB_VIOL_INVOICES_STAGE] ([VIOLATOR_ID]);
--CREATE STATISTICS [STATS_VB_VIOL_INVOICES_002] ON EDW_RITE.dbo.[VB_VIOL_INVOICES_STAGE] ([VBI_VBI_INVOICE_ID],[VIOLATOR_ID]);
--CREATE STATISTICS [STATS_VB_VIOL_INVOICES_003] ON EDW_RITE.dbo.[VB_VIOL_INVOICES_STAGE] ([INV_VIOL_INVOICE_ID],[VBI_VBI_INVOICE_ID]);

--STEP #2: Replace OLD table with NEW
IF OBJECT_ID('dbo.VB_VIOL_INVOICES_OLD')>0 	DROP TABLE dbo.VB_VIOL_INVOICES_OLD;
IF OBJECT_ID('dbo.VB_VIOL_INVOICES')>0		RENAME OBJECT::dbo.VB_VIOL_INVOICES TO VB_VIOL_INVOICES_OLD;
RENAME OBJECT::dbo.VB_VIOL_INVOICES_STAGE TO VB_VIOL_INVOICES;
IF OBJECT_ID('dbo.VB_VIOL_INVOICES_OLD')>0 	DROP TABLE dbo.VB_VIOL_INVOICES_OLD;




	--UPDATE dbo.VB_VIOL_INVOICES
	--SET  DATE_CREATED = B.DATE_CREATED
	--	, LAST_UPDATE_TYPE = B.LAST_UPDATE_TYPE
	--	, LAST_UPDATE_DATE = B.LAST_UPDATE_DATE
	--FROM dbo.VB_VIOL_INVOICES_STAGE B
	--WHERE 
	--	dbo.VB_VIOL_INVOICES.VIOLATOR_ID = B.VIOLATOR_ID
	--	AND
	--	dbo.VB_VIOL_INVOICES.VBI_VBI_INVOICE_ID = B.VBI_VBI_INVOICE_ID
	--	AND
	--	dbo.VB_VIOL_INVOICES.INV_VIOL_INVOICE_ID = B.INV_VIOL_INVOICE_ID 
	--	AND
	--	dbo.VB_VIOL_INVOICES.DATE_CREATED <> B.DATE_CREATED

	--INSERT INTO dbo.VB_VIOL_INVOICES (VIOLATOR_ID, VBI_VBI_INVOICE_ID, INV_VIOL_INVOICE_ID, DATE_CREATED, LAST_UPDATE_TYPE, LAST_UPDATE_DATE)
	--SELECT A.VIOLATOR_ID, A.VBI_VBI_INVOICE_ID, A.INV_VIOL_INVOICE_ID, A.DATE_CREATED, A.LAST_UPDATE_TYPE, A.LAST_UPDATE_DATE
	--FROM dbo.VB_VIOL_INVOICES_STAGE A
	--LEFT JOIN dbo.VB_VIOL_INVOICES B ON A.VIOLATOR_ID = B.VIOLATOR_ID AND A.VBI_VBI_INVOICE_ID = B.VBI_VBI_INVOICE_ID AND A.INV_VIOL_INVOICE_ID = B.INV_VIOL_INVOICE_ID
	--WHERE B.VIOLATOR_ID IS NULL AND B.VBI_VBI_INVOICE_ID IS NULL AND B.INV_VIOL_INVOICE_ID IS NULL
	--AND A.VIOLATOR_ID IS NOT NULL

	--IF OBJECT_ID('dbo.VB_VIOL_INVOICES')>0			RENAME OBJECT::dbo.VB_VIOL_INVOICES TO VB_VIOL_INVOICES_OLD;
	--IF OBJECT_ID('dbo.VB_VIOL_INVOICES_STAGE')>0	RENAME OBJECT::dbo.VB_VIOL_INVOICES_STAGE TO VB_VIOL_INVOICES;
	--IF OBJECT_ID('dbo.VB_VIOL_INVOICES_OLD')>0		DROP TABLE dbo.VB_VIOL_INVOICES_OLD;


