CREATE OR REPLACE PROCEDURE EDW_TRIPS_SUPPORT.Get_Select_String(IN table STRING, INOUT params_in_sql_out STRING)

  BEGIN

/*
USE EDW_TRIPS 
GO
IF OBJECT_ID ('Utility.Get_Select_String', 'P') IS NOT NULL DROP PROCEDURE Utility.Get_Select_String
GO

###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
DECLARE @Params_In_SQL_Out VARCHAR(MAX) = 'Types,Alias,TitleCase,No[]',@Table_Name VARCHAR(200)  = '[TollPlus].[TP_Customers]'
EXEC Utility.Get_Select_String @Table_Name, @Params_In_SQL_Out OUTPUT 

DECLARE @Params_In_SQL_Out VARCHAR(MAX) = 'Alias:TPC,Types',@Table_Name VARCHAR(200)  = '[TollPlus].[TP_Customers]'
EXEC Utility.Get_Select_String @Table_Name, @Params_In_SQL_Out OUTPUT 

DECLARE @Params_In_SQL_Out VARCHAR(MAX) = 'Alias:Long,TitleCase,No[]',@Table_Name VARCHAR(200)  = '[TollPlus].[TP_Customers]'
EXEC Utility.Get_Select_String @Table_Name, @Params_In_SQL_Out OUTPUT 

DECLARE @Params_In_SQL_Out VARCHAR(MAX) = 'No[]',@Table_Name VARCHAR(200)  = '[TollPlus].[TP_Customers]'
EXEC Utility.Get_Select_String @Table_Name, @Params_In_SQL_Out OUTPUT 
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc creating and returning part of SQL statement of all table columns to use in queries like Select and Create as Select 
Depends on Parameters it can be just list of names devided by comma, or use cast, ISNULL and allias. See example.

@Table_Name - Table name (with Schema) - table for get columns from
@Params_In_SQL_Out - Param to return SQL statement. Can take some secondary parameters
	can include values: 	'Types,Alias:Short or Long or YourAlias,TitleCase,No[],NoPrint'
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837 Andy	01/10/2020	New!
###################################################################################################################
*/


    DECLARE error STRING DEFAULT '';
    DECLARE params STRING;
    DECLARE tablealias STRING;
    DECLARE index INT64;
    DECLARE types INT64 DEFAULT 0;
    DECLARE alias INT64 DEFAULT 0;
    DECLARE titlecase INT64 DEFAULT 0;
    DECLARE nunofcolumns INT64;
    SET params = coalesce(params_in_sql_out, '');
    SET params_in_sql_out = '';
    IF table IS NULL THEN
      SET error = concat(error, 'Table Name cannot be NULL');
    END IF;
    IF length(rtrim(error)) > 0 THEN
      SELECT error;
    ELSE
      BEGIN
        DECLARE dot INT64;
        DECLARE indicat INT64 DEFAULT 1;
        DECLARE delimiter STRING DEFAULT '  ';
        DECLARE select_string STRING DEFAULT '';
        DECLARE columnname STRING DEFAULT '';
       
        SET tablealias = table;
        SET params = replace(replace(params, ' ', ''), '\t', '');
        SET index = (
        SELECT
            coalesce(nullif(strpos(params, 'Alias:'), 0), strpos(params, 'Table:')))
        ;
        IF index > 0 THEN
         -- In this brackets only the table name can be we need to put in AS

          SET tablealias = substr(params, greatest(CASE
            WHEN strpos(substr(params, index), ':') = 0 THEN 0
            ELSE strpos(substr(params, index), ':') + (CASE
              WHEN index < 1 THEN 1
              ELSE index
            END - 1)
          END + 1, 0), CASE
            WHEN CASE
              WHEN strpos(substr(params, index), ':') = 0 THEN 0
              ELSE strpos(substr(params, index), ':') + (CASE
                WHEN index < 1 THEN 1
                ELSE index
              END - 1)
            END + 1 < 1 THEN greatest(CASE
              WHEN strpos(substr(params, index), ':') = 0 THEN 0
              ELSE strpos(substr(params, index), ':') + (CASE
                WHEN index < 1 THEN 1
                ELSE index
              END - 1)
            END + 1 + (coalesce(nullif(CASE
              WHEN strpos(substr(params, index), ',') = 0 THEN 0
              ELSE strpos(substr(params, index), ',') + (CASE
                WHEN index < 1 THEN 1
                ELSE index
              END - 1)
            END, 0), length(rtrim(params)) + 1) - CASE
              WHEN strpos(substr(params, index), ':') = 0 THEN 0
              ELSE strpos(substr(params, index), ':') + (CASE
                WHEN index < 1 THEN 1
                ELSE index
              END - 1)
            END - 1 - 1), 0)
            ELSE coalesce(nullif(CASE
              WHEN strpos(substr(params, index), ',') = 0 THEN 0
              ELSE strpos(substr(params, index), ',') + (CASE
                WHEN index < 1 THEN 1
                ELSE index
              END - 1)
            END, 0), length(rtrim(params)) + 1) - CASE
              WHEN strpos(substr(params, index), ':') = 0 THEN 0
              ELSE strpos(substr(params, index), ':') + (CASE
                WHEN index < 1 THEN 1
                ELSE index
              END - 1)
            END - 1
          END);
          SET params = replace(replace(params, concat('Table:', tablealias), 'Alias'), concat('Alias:', tablealias), 'Alias');

          -- If table include somehow one of the key word (like table, Type or Alias) - we have to remove it

           IF tablealias = 'Short' THEN
            SET tablealias = (
            SELECT
                tablealias.aliasshort AS tablealias
              FROM
                EDW_TRIPS_SUPPORT.TableAlias
              WHERE lower(tablealias.tablename) = lower(table)
            );
          END IF;
          IF tablealias = 'Long' THEN
            SET tablealias = (
            SELECT
                tablealias.aliaslong AS tablealias
              FROM
                EDW_TRIPS_SUPPORT.TableAlias
            WHERE lower(tablealias.tablename) = lower(table)
            );
          END IF;
        END IF;
        IF strpos(params, 'Type') > 0 THEN
          SET types = 1;
        END IF;
        IF strpos(params, 'Alias') > 0 THEN
          SET alias = 1;
        END IF;
        IF strpos(params, 'Title') > 0 THEN
          SET titlecase = 1;
        END IF;

        CREATE OR REPLACE TEMPORARY TABLE _SESSION.tablecolums
          AS
            SELECT
                c.table_name AS tablename,
                c.column_name AS columnname,
                c.ordinal_position AS column_id,
                c.data_type AS columntype,
                CASE
                    WHEN c.is_nullable = 'YES' THEN 1
                    ELSE 0
                END AS is_nullable,
                ROW_NUMBER() OVER (ORDER BY c.ordinal_position) AS rn
              FROM
                `EDW_TRIPS.INFORMATION_SCHEMA.COLUMNS` AS c
              where lower(c.table_name) = lower(table)
        ;
        SET nunofcolumns = (
          SELECT
              coalesce(any_value(subselect._u0040_nunofcolumns), nunofcolumns) AS _u0040_nunofcolumns
            FROM
              (
                SELECT
                    max(`#tablecolums`.rn) AS _u0040_nunofcolumns
                  FROM
                    _SESSION.tablecolums AS `#tablecolums`
                LIMIT 1
              ) AS subselect
        );
        IF titlecase = 1 THEN
          SET tablealias =   REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE
			   (InitCap(tablealias),'__','_'),'By','By'),'HV','HV'),'ID','ID'),'In','In'),'Is','Is'),'No','No'),'Of','Of'),'Or','Or'),'PK','PK'),'To','To'),'Acc','Acc'),'Act','Act'),'Add','Add'),'Adj','Adj'),'AIP','AIP'),'Amt','Amt'),'And','And'),'Bad','Bad'),'Ban','Ban'),'BOS','BOS'),'Cnt','Cnt'),'CSV','CSV'),'Day','Day'),'DMV','DMV'),'DPS','DPS'),'Due','Due'),'EIP','EIP'),'End','End'),'Fee','Fee'),'FK_','FK_'),'FTP','FTP'),'Hex','Hex'),'ICN','ICN'),'IDX','IDX'),'Img','Img'),'INX','INX'),'IOP','IOP'),'IX_','IX_'),'Key','Key'),'Lic','Lic'),'Log','Log'),'Map','Map'),'MIR','MIR'),'New','New'),'NNP','NNP'),'Non','Non'),'Num','Num'),'OCR','OCR'),'Out','Out'),'Own','Own'),'Pay','Pay'),'PBM','PBM'),'Raw','Raw'),'Ref','Ref'),'Rev','Rev'),'ROI','ROI'),'Seq','Seq'),'Sig','Sig'),'SSN','SSN'),'Tag','Tag'),'Tax','Tax'),'Top','Top'),'TP_','TP_'),'TSA','TSA'),'Txn','Txn'),'UQ_','UQ_'),'UTC','UTC'),'VCF','VCF'),'VIN','VIN'),'VIP','VIP'),'VRB','VRB'),'VSR','VSR'),'Web','Web'),'Zip','Zip'),'ALPR','ALPR'),'Attr','Attr'),'Auto','Auto'),'Axle','Axle'),'Bank','Bank'),'Bill','Bill'),'Call','Call'),'Case','Case'),'Cash','Cash'),'City','City'),'Clos','Clos'),'Code','Code'),'Coll','Coll'),'Comm','Comm'),'Cust','Cust'),'Data','Data'),'Date','Date'),'Desc','Desc'),'Down','Down'),'Driv','Driv'),'Effe','Effe'),'Exit','Exit'),'File','File'),'Flag','Flag'),'Hist','Hist'),'Hold','Hold'),'Home','Home'),'Host','Host'),'Info','Info'),'Item','Item'),'JSON','JSON'),'Lane','Lane'),'Last','Last'),'Left','Left'),'Line','Line'),'List','List'),'Load','Load'),'Look','Look'),'Mail','Mail'),'Main','Main'),'Make','Make'),'Mark','Mark'),'Mode','Mode'),'MST_','MST_'),'Name','Name'),'NIX_','NIX_'),'Note','Note'),'NTTA','NTTA'),'Paid','Paid'),'Path','Path'),'Phon','Phon'),'Plan','Plan'),'Plus','Plus'),'Port','Port'),'Post','Post'),'Prev','Prev'),'Quer','Quer'),'Rate','Rate'),'Read','Read'),'Role','Role'),'Self','Self'),'Send','Send'),'Sent','Sent'),'Ship','Ship'),'Size','Size'),'Step','Step'),'Term','Term'),'Time','Time'),'Toll','Toll'),'Tran','Tran'),'Trip','Trip'),'Type','Type'),'User','User'),'With','With'),'Work','Work'),'Year','Year'),'Activ','Activ'),'Admin','Admin'),'Agenc','Agenc'),'Alert','Alert'),'Alias','Alias'),'Batch','Batch'),'Blind','Blind'),'Block','Block'),'Check','Check'),'Citat','Citat'),'Class','Class'),'Color','Color'),'Count','Count'),'Court','Court'),'Creat','Creat'),'Cycle','Cycle'),'Email','Email'),'Entry','Entry'),'Error','Error'),'Event','Event'),'Expir','Expir'),'First','First'),'Float','Float'),'Group','Group'),'Horiz','Horiz'),'Ident','Ident'),'Image','Image'),'Index','Index'),'Langu','Langu'),'Match','Match'),'Modif','Modif'),'Plate','Plate'),'Plaza','Plaza'),'Print','Print'),'Prior','Prior'),'Purch','Purch'),'Queue','Queue'),'Raise','Raise'),'Right','Right'),'Setup','Setup'),'Shift','Shift'),'Speed','Speed'),'Spons','Spons'),'Stage','Stage'),'Stand','Stand'),'Start','Start'),'STAT_','STAT_'),'State','State')
			   ,'Level','Level'),'Super','Super'),'Surve','Surve'),'Table','Table'),'Title','Title'),'TxDot','TxDot'),'Updat','Updat'),'Valid','Valid'),'Value','Value'),'Verif','Verif'),'Video','Video'),'VToll','VToll'),'Waive','Waive'),'Write','Write'),'Action','Action'),'Active','Active'),'Amount','Amount'),'Appear','Appear'),'Approv','Approv'),'Assign','Assign'),'Bottom','Bottom'),'Bright','Bright'),'Calcul','Calcul'),'Change','Change'),'Charge','Charge'),'Confid','Confid'),'Config','Config'),'Credit','Credit'),'Detail','Detail'),'Direct','Direct'),'DocMgr','DocMgr'),'Enable','Enable'),'Ground','Ground'),'Handle','Handle'),'Header','Header'),'Height','Height'),'Histor','Histor'),'ImgEnh','ImgEnh'),'Invoic','Invoic'),'Length','Length'),'Letter','Letter'),'Manual','Manual'),'Messag','Messag'),'Method','Method'),'Middle','Middle'),'Number','Number'),'Option','Option'),'Parent','Parent'),'Period','Period'),'Portal','Portal'),'Posted','Posted'),'Prefer','Prefer'),'Prefix','Prefix'),'Primar','Primar'),'Protec','Protec'),'Qualif','Qualif'),'Reason','Reason'),'Rebill','Rebill'),'Record','Record'),'Reject','Reject'),'Remain','Remain'),'Remark','Remark'),'Renter','Renter'),'Report','Report'),'Result','Result'),'Retail','Retail'),'Return','Return'),'Review','Review'),'Serial','Serial'),'Source','Source'),'Status','Status'),'Submit','Submit'),'Suffix','Suffix'),'Syntax','Syntax'),'System','System'),'Unread','Unread'),'Upload','Upload'),'Violat','Violat'),'Volume','Volume'),'Account','Account'),'Address','Address'),'Balance','Balance'),'Carrier','Carrier'),'Categor','Categor'),'Channel','Channel'),'Complet','Complet'),'Consume','Consume'),'Contact','Contact'),'Correct','Correct'),'Deliver','Deliver'),'Deposit','Deposit'),'Dismiss','Dismiss'),'Display','Display'),'Facilit','Facilit'),'Frequen','Frequen'),'Generat','Generat'),'Hearing','Hearing'),'Inbound','Inbound'),'Indicat','Indicat'),'Invalid','Invalid'),'Malform','Malform'),'Manager','Manager'),'Misread','Misread'),'Notific','Notific'),'Parking','Parking'),'Pending','Pending'),'Premium','Premium'),'Process','Process'),'Receipt','Receipt'),'Receive','Receive'),'Renewal','Renewal'),'Replace','Replace'),'Request','Request'),'Require','Require'),'Resolve','Resolve'),'Service','Service'),'Sponsor','Sponsor'),'Storage','Storage'),'Summary','Summary'),'Tracker','Tracker'),'Trigger','Trigger'),'Trooper','Trooper'),'Unmatch','Unmatch'),'Vehicle','Vehicle'),'Visible','Visible'),'Approved','Approved'),'Authorit','Authorit'),'Conflict','Conflict'),'Contrast','Contrast'),'Customer','Customer'),'Decision','Decision'),'Discount','Discount'),'Download','Download'),'Eligible','Eligible'),'Inventor','Inventor'),'Loaction','Loaction'),'Location','Location'),'Metadata','Metadata'),'Position','Position'),'Response','Response'),'Sequence','Sequence'),'ShortCut','ShortCut'),'Template','Template'),'Terminat','Terminat'),'Vertical','Vertical'),'Affidavit','Affidavit'),
			   'Determina','Determina'),'Exception','Exception'),'Excessive','Excessive'),'RegBlocks','RegBlocks'),'Registrat','Registrat'),'Signature','Signature'),'Subscribe','Subscribe'),'Telephone','Telephone'),'Threshold','Threshold'),'Bankruptcy','Bankruptcy'),'Confidance','Confidance'),'Correspond','Correspond'),'Processing','Processing'),'Disposition','Disposition'),'Outstanding','Outstanding'),'Transaction','Transaction'),'Jurisdiction','Jurisdiction'),'Representativ','Representativ'),'IPSTransaction','IPSTransaction');
        END IF;
        WHILE indicat <= nunofcolumns DO
          SET (columnname, select_string) = (
            WITH cte_columninfo AS (
              SELECT
              		--'[' + M.TableName + '].' AS TableName,

                  m.columnname AS columnname,
                  concat(CASE
                    WHEN m.is_nullable = 1 THEN ''
                    ELSE 'IFNULL('
                  END, 'CAST(') AS isnullbegin,
                  concat(')', CASE
                    WHEN m.is_nullable = 1 THEN ''
                    ELSE concat(', ', CASE
                      WHEN m.columntype LIKE '%DATE%' THEN '\'1900-01-01\''
                      WHEN m.columntype LIKE '%STRING' THEN '\'\''
                       WHEN m.columntype IN ('BYTES') THEN '''CAST(B'' AS BYTES)'''
                      ELSE '0'
                    END, ')')
                  END) AS isnullend,
                  concat(' AS ', m.columntype) AS columntype

                  FROM
                  _SESSION.tablecolums AS m
                WHERE m.rn = indicat
            )
            SELECT
                STRUCT(cte_columninfo.columnname AS `@columnname`, concat(CASE
                  WHEN types = 1 THEN cte_columninfo.isnullbegin
                  ELSE ''
                END, CASE
                  WHEN alias = 1 THEN concat('[', tablealias, '].')
                  ELSE ''
                END, '[', cte_columninfo.columnname, ']', CASE
                  WHEN types = 1 THEN concat(cte_columninfo.columntype, cte_columninfo.isnullend)
                  ELSE ''
                END) AS `@select_string`)
              FROM
                cte_columninfo
            LIMIT 1
          );
          IF titlecase + types > 0 THEN
            SET select_string = concat(select_string, ' AS [', columnname, ']');
          END IF;
          SET params_in_sql_out = concat(params_in_sql_out, code_points_to_string(ARRAY[
            13
          ]), code_points_to_string(ARRAY[
            10
          ]), code_points_to_string(ARRAY[
            9
          ]), delimiter, select_string);

        	--SET @Params_In_SQL_Out = @Params_In_SQL_Out + @Delimiter + CHAR(13) + CHAR(10) + CHAR(9) + @SELECT_String
 
          SET delimiter = ', ';
          SET Indicat = Indicat + 1;
        END WHILE;
        IF strpos(params, 'No[]') > 0 THEN
          SET params_in_sql_out = replace(replace(params_in_sql_out, '[', ''), ']', '');
        END IF;
        IF strpos(params, 'NoPrint') = 0 THEN
          select params_in_sql_out;
        END IF;
      END;
    END IF;
  END;
