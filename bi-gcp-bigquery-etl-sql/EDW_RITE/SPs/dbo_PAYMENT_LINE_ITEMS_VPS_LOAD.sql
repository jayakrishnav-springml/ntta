CREATE PROC [DBO].[PAYMENT_LINE_ITEMS_VPS_LOAD] AS

/*

USE EDW_RITE
GO

IF EXISTS (SELECT * 
            FROM   sysobjects 
            WHERE  id = object_id('DBO.PAYMENT_LINE_ITEMS_VPS_LOAD') 
                   and OBJECTPROPERTY(id, 'IsProcedure') = 1 )
DROP PROCEDURE DBO.PAYMENT_LINE_ITEMS_VPS_LOAD
GO

*/

/*
EXEC EDW_RITE.DBO.PAYMENT_LINE_ITEMS_VPS_LOAD


INSERT INTO dbo.PAYMENT_LINE_ITEMS_VPS
	(	 	  
	PAYMENT_LINE_ITEM_ID, PAYMENT_TXN_ID, PMT_TXN_TYPE, PAYMENT_FORM, CREDIT_CARD_TYPE,
	PAYMENT_LINE_ITEM_AMOUNT, PAYMENT_STATUS, REF_LINE_ITEM_ID, LAST_UPDATE_DATE
	)
	VALUES
	(-1,-1,-1,'-1','-1','-1',0,'-1',-1,'1900-01-01')

*/

/*	
SELECT TOP 100 * FROM PAYMENT_LINE_ITEMS_VPS 
SELECT COUNT_BIG(1) FROM PAYMENT_LINE_ITEMS_VPS -- 40 521 705

*/

--DROP STATISTICS [dbo].PAYMENT_LINE_ITEMS_VPS.STATS_PAYMENT_LINE_ITEMS_VPS_007 --ON [dbo].PAYMENT_LINE_ITEMS_VPS_NEW_STAGE --(LAST_UPDATE_DATE);
--alter table [dbo].PAYMENT_LINE_ITEMS_VPS alter column LAST_UPDATE_DATE DATETIME2(2) NULL

-- Too lazy to build full load and incremental - both in one place - if new column is there - incremental...
DECLARE @TODAYS_DATE DATETIME2(2) = SYSDATETIME()
DECLARE @FULL_LOAD BIT  
--EXEC dbo.GetLoadStartDatetime 'dbo.PAYMENT_LINE_ITEMS_VPS', @LAST_UPDATE_DATE OUTPUT
SELECT @FULL_LOAD = CASE WHEN C.column_id IS NULL THEN 1 ELSE 0 END FROM sys.tables t LEFT JOIN sys.columns c ON c.object_id = t.object_id AND c.name = 'REF_LINE_ITEM_ID' WHERE t.name = 'PAYMENT_LINE_ITEMS_VPS'
--PRINT @FULL_LOAD
--PRINT @TODAYS_DATE
--SET @FULL_LOAD = 1

IF @FULL_LOAD = 1-- (SELECT 1 FROM sys.columns c	JOIN sys.tables t ON c.object_id = t.object_id WHERE t.name = 'PAYMENT_LINE_ITEMS_VPS' AND c.name = 'REF_LINE_ITEM_ID') IS NULL 
BEGIN
	IF OBJECT_ID('dbo.PAYMENT_LINE_ITEMS_VPS_NEW_STAGE') IS NOT NULL DROP TABLE dbo.PAYMENT_LINE_ITEMS_VPS_NEW_STAGE
	CREATE TABLE dbo.PAYMENT_LINE_ITEMS_VPS_NEW_STAGE WITH (CLUSTERED INDEX (PAYMENT_LINE_ITEM_ID), DISTRIBUTION = HASH(PAYMENT_TXN_ID)) AS    
	SELECT PAYMENT_LINE_ITEM_ID, PAYMENT_TXN_ID, PMT_TXN_TYPE, PAYMENT_FORM, CREDIT_CARD_TYPE, PAYMENT_LINE_ITEM_AMOUNT, PAYMENT_STATUS, REF_LINE_ITEM_ID, @TODAYS_DATE AS LAST_UPDATE_DATE
	FROM LND_LG_VPS.[VP_OWNER].PAYMENT_LINE_ITEMS 
	OPTION (LABEL = 'PAYMENT_LINE_ITEMS_VPS_LOAD: FULL load');
END
ELSE
BEGIN 
	IF OBJECT_ID('dbo.PAYMENT_LINE_ITEMS_VPS_STAGE') IS NOT NULL DROP TABLE dbo.PAYMENT_LINE_ITEMS_VPS_STAGE
	CREATE TABLE dbo.PAYMENT_LINE_ITEMS_VPS_STAGE WITH (CLUSTERED INDEX (PAYMENT_LINE_ITEM_ID), DISTRIBUTION = HASH(PAYMENT_TXN_ID)) AS 
	-- EXPLAIN
	SELECT PAYMENT_LINE_ITEM_ID, PAYMENT_TXN_ID, PMT_TXN_TYPE, PAYMENT_FORM, CREDIT_CARD_TYPE, PAYMENT_LINE_ITEM_AMOUNT, PAYMENT_STATUS, REF_LINE_ITEM_ID
	FROM LND_LG_VPS.[VP_OWNER].PAYMENT_LINE_ITEMS 
	EXCEPT 
	SELECT PAYMENT_LINE_ITEM_ID, PAYMENT_TXN_ID, PMT_TXN_TYPE, PAYMENT_FORM, CREDIT_CARD_TYPE, PAYMENT_LINE_ITEM_AMOUNT, PAYMENT_STATUS, REF_LINE_ITEM_ID
	FROM dbo.PAYMENT_LINE_ITEMS_VPS 
	OPTION (LABEL = 'PAYMENT_LINE_ITEMS_VPS_LOAD: PAYMENT_LINE_ITEMS_VPS_STAGE');

	IF OBJECT_ID('dbo.PAYMENT_LINE_ITEMS_VPS_NEW_STAGE') IS NOT NULL DROP TABLE dbo.PAYMENT_LINE_ITEMS_VPS_NEW_STAGE
	CREATE TABLE dbo.PAYMENT_LINE_ITEMS_VPS_NEW_STAGE WITH (CLUSTERED INDEX (PAYMENT_LINE_ITEM_ID), DISTRIBUTION = HASH(PAYMENT_TXN_ID)) AS    
	SELECT	
		PAYMENT_LINE_ITEM_ID, PAYMENT_TXN_ID, PMT_TXN_TYPE, PAYMENT_FORM, CREDIT_CARD_TYPE,
		PAYMENT_LINE_ITEM_AMOUNT, PAYMENT_STATUS, REF_LINE_ITEM_ID, LAST_UPDATE_DATE
	FROM dbo.PAYMENT_LINE_ITEMS_VPS AS F 
	WHERE	NOT EXISTS (SELECT 1 FROM dbo.PAYMENT_LINE_ITEMS_VPS_STAGE AS NSET WHERE NSET.PAYMENT_LINE_ITEM_ID = F.PAYMENT_LINE_ITEM_ID) 
	  UNION ALL 
	SELECT	
		N.PAYMENT_LINE_ITEM_ID, N.PAYMENT_TXN_ID, N.PMT_TXN_TYPE, N.PAYMENT_FORM, N.CREDIT_CARD_TYPE,
		N.PAYMENT_LINE_ITEM_AMOUNT, N.PAYMENT_STATUS, REF_LINE_ITEM_ID, @TODAYS_DATE AS LAST_UPDATE_DATE
	FROM dbo.PAYMENT_LINE_ITEMS_VPS_STAGE AS N
	OPTION (LABEL = 'PAYMENT_LINE_ITEMS_VPS_LOAD: INSERT/UPDATE');
END

CREATE STATISTICS [STATS_PAYMENT_LINE_ITEMS_VPS_001] ON [dbo].PAYMENT_LINE_ITEMS_VPS_NEW_STAGE (PAYMENT_TXN_ID);
CREATE STATISTICS [STATS_PAYMENT_LINE_ITEMS_VPS_002] ON [dbo].PAYMENT_LINE_ITEMS_VPS_NEW_STAGE (PMT_TXN_TYPE,PAYMENT_FORM);
CREATE STATISTICS [STATS_PAYMENT_LINE_ITEMS_VPS_003] ON [dbo].PAYMENT_LINE_ITEMS_VPS_NEW_STAGE (PAYMENT_FORM,PAYMENT_STATUS);
CREATE STATISTICS [STATS_PAYMENT_LINE_ITEMS_VPS_004] ON [dbo].PAYMENT_LINE_ITEMS_VPS_NEW_STAGE (CREDIT_CARD_TYPE);
CREATE STATISTICS [STATS_PAYMENT_LINE_ITEMS_VPS_005] ON [dbo].PAYMENT_LINE_ITEMS_VPS_NEW_STAGE (PAYMENT_STATUS);
CREATE STATISTICS [STATS_PAYMENT_LINE_ITEMS_VPS_006] ON [dbo].PAYMENT_LINE_ITEMS_VPS_NEW_STAGE (REF_LINE_ITEM_ID);
CREATE STATISTICS [STATS_PAYMENT_LINE_ITEMS_VPS_007] ON [dbo].PAYMENT_LINE_ITEMS_VPS_NEW_STAGE (LAST_UPDATE_DATE);

--STEP #2: Replace OLD table with NEW
IF OBJECT_ID('dbo.PAYMENT_LINE_ITEMS_VPS_OLD') IS NOT NULL 	DROP TABLE dbo.PAYMENT_LINE_ITEMS_VPS_OLD;
IF OBJECT_ID('dbo.PAYMENT_LINE_ITEMS_VPS') IS NOT NULL		RENAME OBJECT::dbo.PAYMENT_LINE_ITEMS_VPS TO PAYMENT_LINE_ITEMS_VPS_OLD;
RENAME OBJECT::dbo.PAYMENT_LINE_ITEMS_VPS_NEW_STAGE TO PAYMENT_LINE_ITEMS_VPS;
IF OBJECT_ID('dbo.PAYMENT_LINE_ITEMS_VPS_OLD') IS NOT NULL 	DROP TABLE dbo.PAYMENT_LINE_ITEMS_VPS_OLD;

IF OBJECT_ID('dbo.PAYMENT_LINE_ITEMS_VPS_STAGE') IS NOT NULL 	DROP TABLE dbo.PAYMENT_LINE_ITEMS_VPS_STAGE


