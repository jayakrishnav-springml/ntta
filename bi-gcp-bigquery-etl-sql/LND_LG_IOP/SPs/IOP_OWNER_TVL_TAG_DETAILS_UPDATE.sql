CREATE PROC [IOP_OWNER].[TVL_TAG_DETAILS_UPDATE] AS
/*
       Use this proc to help write the code
              GetUpdateFields 'IOP_OWNER','TVL_TAG_DETAILS'
              You will have to remove the Distribution key from what it generates
*/

/*
       Update Stats on CT_UPD table to help with de-dupping and update steps
*/

EXEC DropStats 'IOP_OWNER','TVL_TAG_DETAILS_CT_UPD'
CREATE STATISTICS STATS_TVL_TAG_DETAILS_CT_UPD_001 ON IOP_OWNER.TVL_TAG_DETAILS_CT_UPD (TTD_ID)
CREATE STATISTICS STATS_TVL_TAG_DETAILS_CT_UPD_002 ON IOP_OWNER.TVL_TAG_DETAILS_CT_UPD (TTD_ID, INSERT_DATETIME)


/*
       Get Duplicate Records with the INSERT_DATETIME from the CDC Staging 
*/
/*
IF OBJECT_ID('tempdb..#TVL_TAG_DETAILS_CT_UPD_Dups')<>0
       DROP TABLE #TVL_TAG_DETAILS_CT_UPD_Dups

CREATE TABLE #TVL_TAG_DETAILS_CT_UPD_Dups WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (TTD_ID, INSERT_DATETIME), LOCATION = USER_DB)
AS
       SELECT A.TTD_ID, A.INSERT_DATETIME
       FROM IOP_OWNER.TVL_TAG_DETAILS_CT_UPD A
       INNER JOIN 
              (
                     SELECT TTD_ID
                     FROM IOP_OWNER.TVL_TAG_DETAILS_CT_UPD
                     GROUP BY TTD_ID
                     HAVING COUNT(*)>1
              ) Dups ON A.TTD_ID = Dups.TTD_ID

/*
       Create temp table with Last Update 
*/

IF OBJECT_ID('tempdb..#TVL_TAG_DETAILS_CT_UPD_DuplicateLastRowToReInsert')<>0
       DROP TABLE #TVL_TAG_DETAILS_CT_UPD_DuplicateLastRowToReInsert

CREATE TABLE #TVL_TAG_DETAILS_CT_UPD_DuplicateLastRowToReInsert WITH (DISTRIBUTION = REPLICATE, CLUSTERED INDEX (TTD_ID), LOCATION = USER_DB)
AS
       SELECT  A.TTD_ID, A.HIA_AGCY_ID, A.TAG_IDENTIFIER, A.TAG_ID, A.TVL_AGCY_ID, A.BATCH_MODE, A.TVL_TAG_STATUS, A.LIC_PLATE_NBR, A.LIC_PLATE_STATE, A.VEHICLE_CLASS_CODE, A.REV_TYPE, A.FIRST_TVL_BATCH_ID, A.DATE_TVL_EFFECTIVE, A.LAST_TVL_BATCH_ID, A.ATTRIBUTE_1, A.ATTRIBUTE_2, A.ATTRIBUTE_3, A.ATTRIBUTE_4, A.ATTRIBUTE_5, A.CREATED_BY, A.DATE_CREATED, A.MODIFIED_BY, A.DATE_MODIFIED, A.INSERT_DATETIME
       FROM IOP_OWNER.TVL_TAG_DETAILS_CT_UPD A
       INNER JOIN 
              (
                     SELECT TTD_ID, MAX(INSERT_DATETIME) AS LAST_INSERT_DATETIME
                     FROM #TVL_TAG_DETAILS_CT_UPD_Dups
                     GROUP BY TTD_ID
              ) LastRcrd ON A.TTD_ID = LastRcrd.TTD_ID AND A.INSERT_DATETIME = LastRcrd.LAST_INSERT_DATETIME

/*
       DELETE all the duplicate rows from the target
*/

DELETE FROM IOP_OWNER.TVL_TAG_DETAILS_CT_UPD 
WHERE EXISTS(SELECT * FROM #TVL_TAG_DETAILS_CT_UPD_Dups B WHERE IOP_OWNER.TVL_TAG_DETAILS_CT_UPD.TTD_ID = B.TTD_ID);


/*
       Re-insert the LAST ROW for Duplicates
*/
INSERT INTO IOP_OWNER.TVL_TAG_DETAILS_CT_UPD 
       (TTD_ID, HIA_AGCY_ID, TAG_IDENTIFIER, TAG_ID, TVL_AGCY_ID, BATCH_MODE, TVL_TAG_STATUS, LIC_PLATE_NBR, LIC_PLATE_STATE, VEHICLE_CLASS_CODE, REV_TYPE, FIRST_TVL_BATCH_ID, DATE_TVL_EFFECTIVE, LAST_TVL_BATCH_ID, ATTRIBUTE_1, ATTRIBUTE_2, ATTRIBUTE_3, ATTRIBUTE_4, ATTRIBUTE_5, CREATED_BY, DATE_CREATED, MODIFIED_BY, DATE_MODIFIED, INSERT_DATETIME)
SELECT TTD_ID, HIA_AGCY_ID, TAG_IDENTIFIER, TAG_ID, TVL_AGCY_ID, BATCH_MODE, TVL_TAG_STATUS, LIC_PLATE_NBR, LIC_PLATE_STATE, VEHICLE_CLASS_CODE, REV_TYPE, FIRST_TVL_BATCH_ID, DATE_TVL_EFFECTIVE, LAST_TVL_BATCH_ID, ATTRIBUTE_1, ATTRIBUTE_2, ATTRIBUTE_3, ATTRIBUTE_4, ATTRIBUTE_5, CREATED_BY, DATE_CREATED, MODIFIED_BY, DATE_MODIFIED, INSERT_DATETIME
FROM #TVL_TAG_DETAILS_CT_UPD_DuplicateLastRowToReInsert

*/
       UPDATE  IOP_OWNER.TVL_TAG_DETAILS
       SET 
    
              --IOP_OWNER.TVL_TAG_DETAILS.TTD_ID = B.TTD_ID
              IOP_OWNER.TVL_TAG_DETAILS.HIA_AGCY_ID = B.HIA_AGCY_ID
              , IOP_OWNER.TVL_TAG_DETAILS.TAG_IDENTIFIER = B.TAG_IDENTIFIER
              , IOP_OWNER.TVL_TAG_DETAILS.TAG_ID = B.TAG_ID
              , IOP_OWNER.TVL_TAG_DETAILS.TVL_AGCY_ID = B.TVL_AGCY_ID
              , IOP_OWNER.TVL_TAG_DETAILS.BATCH_MODE = B.BATCH_MODE
              , IOP_OWNER.TVL_TAG_DETAILS.TVL_TAG_STATUS = B.TVL_TAG_STATUS
              , IOP_OWNER.TVL_TAG_DETAILS.LIC_PLATE_NBR = B.LIC_PLATE_NBR
              , IOP_OWNER.TVL_TAG_DETAILS.LIC_PLATE_STATE = B.LIC_PLATE_STATE
              , IOP_OWNER.TVL_TAG_DETAILS.VEHICLE_CLASS_CODE = B.VEHICLE_CLASS_CODE
              , IOP_OWNER.TVL_TAG_DETAILS.REV_TYPE = B.REV_TYPE
              , IOP_OWNER.TVL_TAG_DETAILS.FIRST_TVL_BATCH_ID = B.FIRST_TVL_BATCH_ID
              , IOP_OWNER.TVL_TAG_DETAILS.DATE_TVL_EFFECTIVE = B.DATE_TVL_EFFECTIVE
              , IOP_OWNER.TVL_TAG_DETAILS.LAST_TVL_BATCH_ID = B.LAST_TVL_BATCH_ID
              , IOP_OWNER.TVL_TAG_DETAILS.ATTRIBUTE_1 = B.ATTRIBUTE_1
              , IOP_OWNER.TVL_TAG_DETAILS.ATTRIBUTE_2 = B.ATTRIBUTE_2
              , IOP_OWNER.TVL_TAG_DETAILS.ATTRIBUTE_3 = B.ATTRIBUTE_3
              , IOP_OWNER.TVL_TAG_DETAILS.ATTRIBUTE_4 = B.ATTRIBUTE_4
              , IOP_OWNER.TVL_TAG_DETAILS.ATTRIBUTE_5 = B.ATTRIBUTE_5
              , IOP_OWNER.TVL_TAG_DETAILS.CREATED_BY = B.CREATED_BY
              , IOP_OWNER.TVL_TAG_DETAILS.DATE_CREATED = B.DATE_CREATED
              , IOP_OWNER.TVL_TAG_DETAILS.MODIFIED_BY = B.MODIFIED_BY
              , IOP_OWNER.TVL_TAG_DETAILS.DATE_MODIFIED = B.DATE_MODIFIED
              , IOP_OWNER.TVL_TAG_DETAILS.LAST_UPDATE_TYPE = 'U'
              , IOP_OWNER.TVL_TAG_DETAILS.LAST_UPDATE_DATE = B.INSERT_DATETIME
       FROM IOP_OWNER.TVL_TAG_DETAILS_CT_UPD B
       WHERE IOP_OWNER.TVL_TAG_DETAILS.TTD_ID = B.TTD_ID;

