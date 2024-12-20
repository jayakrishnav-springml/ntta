CREATE PROC [DBO].[VPS_EDW_TXN_CNT_CHECK] AS
IF OBJECT_ID('EDW_RITE.dbo.LND_VPS_TXN_COUNT') IS NOT NULL
	DROP TABLE EDW_RITE.dbo.LND_VPS_TXN_COUNT

CREATE TABLE EDW_RITE.dbo.LND_VPS_TXN_COUNT
	WITH (
			CLUSTERED COLUMNSTORE INDEX
			,DISTRIBUTION = HASH (LND_TXN_YY_MM)
			) AS

SELECT YEAR(VIOL_DATE) * 100 + MONTH(VIOL_DATE) LND_TXN_YY_MM
	,COUNT_BIG(1) LND_TXN_CNT
FROM LND_LG_VPS.VP_OWNER.VIOLATIONS
WHERE VIOL_DATE BETWEEN DATEADD(YEAR, - 2, GETDATE())
		AND GETDATE()
GROUP BY YEAR(VIOL_DATE) * 100 + MONTH(VIOL_DATE)
OPTION (LABEL = 'LND_VPS TXN COUNT FOR LAST 2 YEARS FROM GETDATE()');

IF OBJECT_ID('EDW_RITE.dbo.EDW_VPS_TXN_COUNT') IS NOT NULL
	DROP TABLE EDW_RITE.dbo.EDW_VPS_TXN_COUNT

CREATE TABLE EDW_RITE.dbo.EDW_VPS_TXN_COUNT
	WITH (
			CLUSTERED COLUMNSTORE INDEX
			,DISTRIBUTION = HASH (EDW_TXN_YY_MM)
			) AS

SELECT YEAR(VIOL_DATE) * 100 + MONTH(VIOL_DATE) EDW_TXN_YY_MM
	,COUNT_BIG(1) EDW_TXN_CNT
FROM EDW_RITE.DBO.VIOLATIONS
WHERE VIOL_DATE BETWEEN DATEADD(YEAR, - 2, GETDATE())
		AND GETDATE()
GROUP BY YEAR(VIOL_DATE) * 100 + MONTH(VIOL_DATE)
OPTION (LABEL = 'EDW_VPS TXN COUNT FOR LAST 2 YEARS FROM GETDATE()');

IF OBJECT_ID('EDW_RITE.dbo.VPS_TXN_COUNT_COMPARE') IS NOT NULL
	DROP TABLE EDW_RITE.dbo.VPS_TXN_COUNT_COMPARE

CREATE TABLE EDW_RITE.dbo.VPS_TXN_COUNT_COMPARE_STAGE
	WITH (
			CLUSTERED COLUMNSTORE INDEX
			,DISTRIBUTION = HASH (EDW_TXN_YY_MM)
			) AS

SELECT GETDATE() AS DATA_AS_OF
	,LND_VPS_TXN.*
	,EDW_VPS_TXN.*
FROM EDW_RITE.dbo.LND_VPS_TXN_COUNT LND_VPS_TXN
JOIN EDW_RITE.dbo.EDW_VPS_TXN_COUNT EDW_VPS_TXN ON LND_VPS_TXN.LND_TXN_YY_MM = EDW_VPS_TXN.EDW_TXN_YY_MM
	AND LND_TXN_CNT <> EDW_TXN_CNT
OPTION (LABEL = 'LND_VPS_TXN_CNT <> EDW_VPS_TXN_CNT');

IF OBJECT_ID('EDW_RITE.dbo.VPS_TXN_COUNT_COMPARE_STAGE') > 0 RENAME OBJECT::dbo.VPS_TXN_COUNT_COMPARE_STAGE TO VPS_TXN_COUNT_COMPARE;
	IF OBJECT_ID('EDW_RITE.dbo.LND_VPS_TXN_COUNT') IS NOT NULL --DROP TABLE LND_VPS_TXN_COUNT
		DROP TABLE EDW_RITE.dbo.LND_VPS_TXN_COUNT

IF OBJECT_ID('EDW_RITE.dbo.EDW_VPS_TXN_COUNT') IS NOT NULL --DROP TABLE EDW_VPS_TXN_COUNT
	DROP TABLE EDW_RITE.dbo.EDW_VPS_TXN_COUNT

DECLARE @COUNT INT;

SELECT @COUNT = COUNT(1)
FROM VPS_TXN_COUNT_COMPARE

IF @COUNT > 0
BEGIN
	PRINT 'CHECK YOUR TXN COUNTS FOR SELECT * FROM VPS_TXN_COUNT_COMPARE ORDER BY 2,3,4,5';
END
ELSE
BEGIN
	PRINT 'TXN COUNTS MATCHING';
END
