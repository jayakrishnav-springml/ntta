CREATE PROC [DBO].[VB_INVOICES_FULL_LOAD] AS 

/*
USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.VB_INVOICES_FULL_LOAD') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.VB_INVOICES_FULL_LOAD
GO

*/
-- Andy Filipps 2018-12-10 - created new Full Load


/*

SELECT COUNT_BIG(1) FROM dbo.VB_INVOICES  -- 85 548 414

SELECT TOP 100 * FROM dbo.VB_INVOICES

*/
--SELECT MAX(VIOLATOR_ID)	--	 805 414 819
--FROM dbo.VIOLATORS		-- 2 147 483 647

--DBCC PDW_SHOWSPACEUSED('VB_INVOICES')

	--DECLARE @LAST_UPDATE_DATE datetime2(2) 
	--exec dbo.GetLoadStartDatetime 'dbo.VB_INVOICES', @LAST_UPDATE_DATE OUTPUT

IF OBJECT_ID('dbo.VB_INVOICES_STAGE')>0		DROP TABLE dbo.VB_INVOICES_STAGE

CREATE TABLE dbo.VB_INVOICES_STAGE WITH (CLUSTERED INDEX ( [VBI_INVOICE_ID] ASC, [VIOLATOR_ID] ASC ), DISTRIBUTION = HASH(VBI_INVOICE_ID))--DISTRIBUTION = HASH(VIOLATOR_ID), CLUSTERED INDEX (VIOLATOR_ID)) 
AS 
-- EXPLAIN
SELECT  
	CONVERT(bigint,VBI_INVOICE_ID) AS VBI_INVOICE_ID
	, VBI_STATUS, VBB_BATCH_ID
	, ISNULL(CONVERT(bigint,VIOLATOR_ID), -1) AS VIOLATOR_ID
	, VIOLATOR_ADDR_SEQ, INVOICE_DATE
	, INVOICE_AMOUNT,  ISNULL(INVOICE_AMT_DISC,0) AS INVOICE_AMT_DISC, LATE_FEE_AMOUNT
	, PAST_DUE_AMOUNT, INVOICE_AMT_PAID
	, TOLL_AMOUNT --, PAST_DUE_LATE_FEE_AMOUNT, PAST_DUE_MAIL_FEE_AMOUNT
	, VBB_LN_BATCH_ID
	, CONVERT(DATE,DATE_EXCUSED) AS DATE_EXCUSED
	, EXCUSED_BY
	, CASE WHEN date_excused IS NULL THEN 0 ELSE DATEDIFF(DAY,invoice_date,date_excused) END AS INVOICE_DAYS_TO_EXCUSED
	, DUE_DATE
	, ISNULL(DATE_MODIFIED, '1/1/1900') AS DATE_MODIFIED
	, A.LAST_UPDATE_TYPE, A.LAST_UPDATE_DATE
FROM LND_LG_VPS.[VP_OWNER].[VB_INVOICES] A
OPTION (LABEL = 'VB_INVOICES_STAGE_LOAD');

INSERT INTO dbo.VB_INVOICES_STAGE
(	 	  
VBI_INVOICE_ID,VBI_STATUS,VBB_BATCH_ID,VIOLATOR_ID,VIOLATOR_ADDR_SEQ,INVOICE_DATE,INVOICE_AMOUNT,INVOICE_AMT_DISC,LATE_FEE_AMOUNT,PAST_DUE_AMOUNT,INVOICE_AMT_PAID,TOLL_AMOUNT,
VBB_LN_BATCH_ID,DATE_EXCUSED,EXCUSED_BY,INVOICE_DAYS_TO_EXCUSED,DUE_DATE,DATE_MODIFIED,LAST_UPDATE_TYPE,LAST_UPDATE_DATE
)
VALUES
(-1,'',-1,-1,0,'1900-01-01',0,0,0,0,0,0,-1,NULL,'',0,'1900-01-01','2000-01-01','I','2000-01-01')


CREATE STATISTICS [STATS_VB_INVOICES_001] ON [dbo].[VB_INVOICES_STAGE] ([VBI_STATUS]);
CREATE STATISTICS [STATS_VB_INVOICES_002] ON [dbo].[VB_INVOICES_STAGE] ([INVOICE_DATE]);
CREATE STATISTICS [STATS_VB_INVOICES_003] ON [dbo].[VB_INVOICES_STAGE] ([LAST_UPDATE_DATE]);
CREATE STATISTICS [STATS_VB_INVOICES_004] ON [dbo].[VB_INVOICES_STAGE] ([VBB_BATCH_ID]);
CREATE STATISTICS [STATS_VB_INVOICES_005] ON [dbo].[VB_INVOICES_STAGE] ([DATE_EXCUSED]);
CREATE STATISTICS [STATS_VB_INVOICES_006] ON [dbo].[VB_INVOICES_STAGE] ([VIOLATOR_ID], VIOLATOR_ADDR_SEQ);


--STEP #2: Replace OLD table with NEW
IF OBJECT_ID('dbo.VB_INVOICES_OLD')>0 	DROP TABLE dbo.VB_INVOICES_OLD;
IF OBJECT_ID('dbo.VB_INVOICES')>0		RENAME OBJECT::dbo.VB_INVOICES TO VB_INVOICES_OLD;
RENAME OBJECT::dbo.VB_INVOICES_STAGE TO VB_INVOICES;
IF OBJECT_ID('dbo.VB_INVOICES_OLD')>0 	DROP TABLE dbo.VB_INVOICES_OLD;

--CREATE STATISTICS [STATS_VB_INVOICES_001] ON [dbo].[VB_INVOICES] ([VIOLATOR_ID]);
--CREATE STATISTICS [STATS_VB_INVOICES_002] ON [dbo].[VB_INVOICES] ([VIOLATOR_ID], [VBI_INVOICE_ID], [INVOICE_DATE]);
--CREATE STATISTICS [STATS_VB_INVOICES_003] ON [dbo].[VB_INVOICES] ([LAST_UPDATE_DATE]);
--CREATE STATISTICS [STATS_VB_INVOICES_004] ON [dbo].[VB_INVOICES] ([VIOLATOR_ID], [VBI_INVOICE_ID], [VBI_STATUS]);
--CREATE STATISTICS [STATS_VB_INVOICES_005] ON [dbo].[VB_INVOICES] ([VBB_BATCH_ID], [VIOLATOR_ID], [VBI_INVOICE_ID]);
--CREATE STATISTICS [STATS_VB_INVOICES_006] ON [dbo].[VB_INVOICES] ([VBB_BATCH_ID], [DATE_EXCUSED]);
--CREATE STATISTICS [STATS_VB_INVOICES_007] ON [dbo].[VB_INVOICES] ([VIOLATOR_ID], [VBI_INVOICE_ID]);

--IF OBJECT_ID('dbo.VB_INVOICES_STAGE')>0 	DROP TABLE dbo.VB_INVOICES_STAGE

