CREATE OR REPLACE PROCEDURE LND_TBOS_SUPPORT.Get_CreateTableAs_SQL(IN table STRING, IN new_table_name STRING, INOUT params_in_sql_out STRING)
  BEGIN
/*
USE LND_TBOS
GO
IF OBJECT_ID ('Utility.Get_CreateTableAs_SQL', 'P') IS NOT NULL DROP PROCEDURE Utility.Get_CreateTableAs_SQL
GO
###################################################################################################################
Example:
-------------------------------------------------------------------------------------------------------------------
DECLARE @CreateTableAs VARCHAR(MAX) = 'Types,Alias,No[]',
		@CreateStatistics VARCHAR(MAX) = 'Types,Alias,No[]',
		@TransferObject VARCHAR(MAX) = 'Types,Alias,No[]',
		@Table_Name VARCHAR(200) = 'Utility.TableLoadParameters',
		@New_Table_Name VARCHAR(100) = 'New.TableLoadParameters'

EXEC Utility.Get_CreateTableAs_SQL @Table_Name, @New_Table_Name, @CreateTableAs OUTPUT 
EXEC Utility.Get_CreateStatistics_SQL @Table_Name, @New_Table_Name, @CreateStatistics OUTPUT 
EXEC Utility.Get_TransferObject_SQL @New_Table_Name, @Table_Name, @TransferObject OUTPUT 
===================================================================================================================
Proc Description: 
-------------------------------------------------------------------------------------------------------------------
This proc creating and returning CREATE TABLE AS SELECT statement for table from another table.
If the new table already exists - it's dropping it before creating

@Table_Name - Name of the table to get all data and Metadata from
@New_Table_Name - Table name we need to creat from the table. All metatadata and data will be the same.
@Params_In_SQL_Out - Param to return string. 
	-- can be: 	'Types,Alias:Short or Long or YourAlias,TitleCase,No[],NoPrint'
===================================================================================================================
Change Log:
-------------------------------------------------------------------------------------------------------------------
CHG0037837			Andy	01/10/2020	New!
###################################################################################################################
*/


    DECLARE error STRING DEFAULT '';
    DECLARE params STRING DEFAULT coalesce(params_in_sql_out, '');
    DECLARE tablealias STRING;
    DECLARE index INT64;
    DECLARE alias INT64 DEFAULT 0;
    DECLARE titlecase INT64 DEFAULT 0;
    DECLARE table_index STRING;
    DECLARE select_string STRING;
    IF table IS NULL THEN
      SET error = concat(error, 'Table name cannot be NULL');
    END IF;
    SET params_in_sql_out = '';
    IF length(rtrim(error)) > 0 THEN
      SELECT error;
    ELSE
      BEGIN
        DECLARE types INT64 DEFAULT 0;
        DECLARE nobrackets INT64 DEFAULT 0;
        SET table_index = concat(params, ',NoPrint');
        SET select_string = concat(params, ',NoPrint');
        IF new_table_name IS NULL
         OR length(rtrim(new_table_name)) = 0 THEN
          SET new_table_name = concat('New.', table);
        END IF;
        SET tablealias = table;
        SET params = replace(replace(params, ' ', ''), '\t', '');
        SET index = (
        SELECT
            coalesce(nullif(strpos(params, 'Alias:'), 0), strpos(params, 'Table:')))
        ;
        IF index > 0 THEN -- In this brackets only the table name can be we need to put in AS
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
          SET params = replace(replace(params, concat('Table:', tablealias), 'Alias'), concat('Alias:', tablealias), 'Alias');-- If table include somehow one of the key word (like table, Type or Alias) - we have to remove it
          IF tablealias = 'Short' THEN
            SET tablealias = (
            SELECT
                TableAlias.aliasshort AS tablealias
              FROM
                  LND_TBOS_SUPPORT.TableAlias
              WHERE lower(TableAlias.tablename) = lower(table)
            );
          END IF;
          IF tablealias = 'Long' THEN
            SET tablealias = (
            SELECT
                TableAlias.aliaslong AS tablealias
              FROM
                  LND_TBOS_SUPPORT.TableAlias
              WHERE lower(TableAlias.tablename) = lower(table)
            );
          END IF;
        END IF;
        IF strpos(params, 'Alias') > 0 THEN
          SET alias = 1;
        END IF;
        IF strpos(params, 'Title') > 0 THEN
          SET titlecase = 1;
        END IF;

        SET table_index = (
          select  concat("CLUSTER BY ", STRING_AGG(column_name, ",")) from LND_TBOS.INFORMATION_SCHEMA.COLUMNS c
              where lower(c.table_name)=lower(table) and clustering_ordinal_position IS NOT NULL
        );

        CALL LND_TBOS_SUPPORT.Get_Select_String(table, select_string);
        IF titlecase = 1 THEN
        SET table = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE
			   (InitCap(table),'__','_'),'By','By'),'HV','HV'),'ID','ID'),'In','In'),'Is','Is'),'No','No'),'Of','Of'),'Or','Or'),'PK','PK'),'To','To'),'Acc','Acc'),'Act','Act'),'Add','Add'),'Adj','Adj'),'AIP','AIP'),'Amt','Amt'),'And','And'),'Bad','Bad'),'Ban','Ban'),'BOS','BOS'),'Cnt','Cnt'),'CSV','CSV'),'Day','Day'),'DMV','DMV'),'DPS','DPS'),'Due','Due'),'EIP','EIP'),'End','End'),'Fee','Fee'),'FK_','FK_'),'FTP','FTP'),'Hex','Hex'),'ICN','ICN'),'IDX','IDX'),'Img','Img'),'INX','INX'),'IOP','IOP'),'IX_','IX_'),'Key','Key'),'Lic','Lic'),'Log','Log'),'Map','Map'),'MIR','MIR'),'New','New'),'NNP','NNP'),'Non','Non'),'Num','Num'),'OCR','OCR'),'Out','Out'),'Own','Own'),'Pay','Pay'),'PBM','PBM'),'Raw','Raw'),'Ref','Ref'),'Rev','Rev'),'ROI','ROI'),'Seq','Seq'),'Sig','Sig'),'SSN','SSN'),'Tag','Tag'),'Tax','Tax'),'Top','Top'),'TP_','TP_'),'TSA','TSA'),'Txn','Txn'),'UQ_','UQ_'),'UTC','UTC'),'VCF','VCF'),'VIN','VIN'),'VIP','VIP'),'VRB','VRB'),'VSR','VSR'),'Web','Web'),'Zip','Zip'),'ALPR','ALPR'),'Attr','Attr'),'Auto','Auto'),'Axle','Axle'),'Bank','Bank'),'Bill','Bill'),'Call','Call'),'Case','Case'),'Cash','Cash'),'City','City'),'Clos','Clos'),'Code','Code'),'Coll','Coll'),'Comm','Comm'),'Cust','Cust'),'Data','Data'),'Date','Date'),'Desc','Desc'),'Down','Down'),'Driv','Driv'),'Effe','Effe'),'Exit','Exit'),'File','File'),'Flag','Flag'),'Hist','Hist'),'Hold','Hold'),'Home','Home'),'Host','Host'),'Info','Info'),'Item','Item'),'JSON','JSON'),'Lane','Lane'),'Last','Last'),'Left','Left'),'Line','Line'),'List','List'),'Load','Load'),'Look','Look'),'Mail','Mail'),'Main','Main'),'Make','Make'),'Mark','Mark'),'Mode','Mode'),'MST_','MST_'),'Name','Name'),'NIX_','NIX_'),'Note','Note'),'NTTA','NTTA'),'Paid','Paid'),'Path','Path'),'Phon','Phon'),'Plan','Plan'),'Plus','Plus'),'Port','Port'),'Post','Post'),'Prev','Prev'),'Quer','Quer'),'Rate','Rate'),'Read','Read'),'Role','Role'),'Self','Self'),'Send','Send'),'Sent','Sent'),'Ship','Ship'),'Size','Size'),'Step','Step'),'Term','Term'),'Time','Time'),'Toll','Toll'),'Tran','Tran'),'Trip','Trip'),'Type','Type'),'User','User'),'With','With'),'Work','Work'),'Year','Year'),'Activ','Activ'),'Admin','Admin'),'Agenc','Agenc'),'Alert','Alert'),'Alias','Alias'),'Batch','Batch'),'Blind','Blind'),'Block','Block'),'Check','Check'),'Citat','Citat'),'Class','Class'),'Color','Color'),'Count','Count'),'Court','Court'),'Creat','Creat'),'Cycle','Cycle'),'Email','Email'),'Entry','Entry'),'Error','Error'),'Event','Event'),'Expir','Expir'),'First','First'),'Float','Float'),'Group','Group'),'Horiz','Horiz'),'Ident','Ident'),'Image','Image'),'Index','Index'),'Langu','Langu'),'Match','Match'),'Modif','Modif'),'Plate','Plate'),'Plaza','Plaza'),'Print','Print'),'Prior','Prior'),'Purch','Purch'),'Queue','Queue'),'Raise','Raise'),'Right','Right'),'Setup','Setup'),'Shift','Shift'),'Speed','Speed'),'Spons','Spons'),'Stage','Stage'),'Stand','Stand'),'Start','Start'),'STAT_','STAT_'),'State','State')
			   ,'Level','Level'),'Super','Super'),'Surve','Surve'),'Table','Table'),'Title','Title'),'TxDot','TxDot'),'Updat','Updat'),'Valid','Valid'),'Value','Value'),'Verif','Verif'),'Video','Video'),'VToll','VToll'),'Waive','Waive'),'Write','Write'),'Action','Action'),'Active','Active'),'Amount','Amount'),'Appear','Appear'),'Approv','Approv'),'Assign','Assign'),'Bottom','Bottom'),'Bright','Bright'),'Calcul','Calcul'),'Change','Change'),'Charge','Charge'),'Confid','Confid'),'Config','Config'),'Credit','Credit'),'Detail','Detail'),'Direct','Direct'),'DocMgr','DocMgr'),'Enable','Enable'),'Ground','Ground'),'Handle','Handle'),'Header','Header'),'Height','Height'),'Histor','Histor'),'ImgEnh','ImgEnh'),'Invoic','Invoic'),'Length','Length'),'Letter','Letter'),'Manual','Manual'),'Messag','Messag'),'Method','Method'),'Middle','Middle'),'Number','Number'),'Option','Option'),'Parent','Parent'),'Period','Period'),'Portal','Portal'),'Posted','Posted'),'Prefer','Prefer'),'Prefix','Prefix'),'Primar','Primar'),'Protec','Protec'),'Qualif','Qualif'),'Reason','Reason'),'Rebill','Rebill'),'Record','Record'),'Reject','Reject'),'Remain','Remain'),'Remark','Remark'),'Renter','Renter'),'Report','Report'),'Result','Result'),'Retail','Retail'),'Return','Return'),'Review','Review'),'Serial','Serial'),'Source','Source'),'Status','Status'),'Submit','Submit'),'Suffix','Suffix'),'Syntax','Syntax'),'System','System'),'Unread','Unread'),'Upload','Upload'),'Violat','Violat'),'Volume','Volume'),'Account','Account'),'Address','Address'),'Balance','Balance'),'Carrier','Carrier'),'Categor','Categor'),'Channel','Channel'),'Complet','Complet'),'Consume','Consume'),'Contact','Contact'),'Correct','Correct'),'Deliver','Deliver'),'Deposit','Deposit'),'Dismiss','Dismiss'),'Display','Display'),'Facilit','Facilit'),'Frequen','Frequen'),'Generat','Generat'),'Hearing','Hearing'),'Inbound','Inbound'),'Indicat','Indicat'),'Invalid','Invalid'),'Malform','Malform'),'Manager','Manager'),'Misread','Misread'),'Notific','Notific'),'Parking','Parking'),'Pending','Pending'),'Premium','Premium'),'Process','Process'),'Receipt','Receipt'),'Receive','Receive'),'Renewal','Renewal'),'Replace','Replace'),'Request','Request'),'Require','Require'),'Resolve','Resolve'),'Service','Service'),'Sponsor','Sponsor'),'Storage','Storage'),'Summary','Summary'),'Tracker','Tracker'),'Trigger','Trigger'),'Trooper','Trooper'),'Unmatch','Unmatch'),'Vehicle','Vehicle'),'Visible','Visible'),'Approved','Approved'),'Authorit','Authorit'),'Conflict','Conflict'),'Contrast','Contrast'),'Customer','Customer'),'Decision','Decision'),'Discount','Discount'),'Download','Download'),'Eligible','Eligible'),'Inventor','Inventor'),'Loaction','Loaction'),'Location','Location'),'Metadata','Metadata'),'Position','Position'),'Response','Response'),'Sequence','Sequence'),'ShortCut','ShortCut'),'Template','Template'),'Terminat','Terminat'),'Vertical','Vertical'),'Affidavit','Affidavit'),
			   'Determina','Determina'),'Exception','Exception'),'Excessive','Excessive'),'RegBlocks','RegBlocks'),'Registrat','Registrat'),'Signature','Signature'),'Subscribe','Subscribe'),'Telephone','Telephone'),'Threshold','Threshold'),'Bankruptcy','Bankruptcy'),'Confidance','Confidance'),'Correspond','Correspond'),'Processing','Processing'),'Disposition','Disposition'),'Outstanding','Outstanding'),'Transaction','Transaction'),'Jurisdiction','Jurisdiction'),'Representativ','Representativ'),'IPSTransaction','IPSTransaction');
        
        SET new_table_name = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE
			   (InitCap(new_table_name),'__','_'),'By','By'),'HV','HV'),'ID','ID'),'In','In'),'Is','Is'),'No','No'),'Of','Of'),'Or','Or'),'PK','PK'),'To','To'),'Acc','Acc'),'Act','Act'),'Add','Add'),'Adj','Adj'),'AIP','AIP'),'Amt','Amt'),'And','And'),'Bad','Bad'),'Ban','Ban'),'BOS','BOS'),'Cnt','Cnt'),'CSV','CSV'),'Day','Day'),'DMV','DMV'),'DPS','DPS'),'Due','Due'),'EIP','EIP'),'End','End'),'Fee','Fee'),'FK_','FK_'),'FTP','FTP'),'Hex','Hex'),'ICN','ICN'),'IDX','IDX'),'Img','Img'),'INX','INX'),'IOP','IOP'),'IX_','IX_'),'Key','Key'),'Lic','Lic'),'Log','Log'),'Map','Map'),'MIR','MIR'),'New','New'),'NNP','NNP'),'Non','Non'),'Num','Num'),'OCR','OCR'),'Out','Out'),'Own','Own'),'Pay','Pay'),'PBM','PBM'),'Raw','Raw'),'Ref','Ref'),'Rev','Rev'),'ROI','ROI'),'Seq','Seq'),'Sig','Sig'),'SSN','SSN'),'Tag','Tag'),'Tax','Tax'),'Top','Top'),'TP_','TP_'),'TSA','TSA'),'Txn','Txn'),'UQ_','UQ_'),'UTC','UTC'),'VCF','VCF'),'VIN','VIN'),'VIP','VIP'),'VRB','VRB'),'VSR','VSR'),'Web','Web'),'Zip','Zip'),'ALPR','ALPR'),'Attr','Attr'),'Auto','Auto'),'Axle','Axle'),'Bank','Bank'),'Bill','Bill'),'Call','Call'),'Case','Case'),'Cash','Cash'),'City','City'),'Clos','Clos'),'Code','Code'),'Coll','Coll'),'Comm','Comm'),'Cust','Cust'),'Data','Data'),'Date','Date'),'Desc','Desc'),'Down','Down'),'Driv','Driv'),'Effe','Effe'),'Exit','Exit'),'File','File'),'Flag','Flag'),'Hist','Hist'),'Hold','Hold'),'Home','Home'),'Host','Host'),'Info','Info'),'Item','Item'),'JSON','JSON'),'Lane','Lane'),'Last','Last'),'Left','Left'),'Line','Line'),'List','List'),'Load','Load'),'Look','Look'),'Mail','Mail'),'Main','Main'),'Make','Make'),'Mark','Mark'),'Mode','Mode'),'MST_','MST_'),'Name','Name'),'NIX_','NIX_'),'Note','Note'),'NTTA','NTTA'),'Paid','Paid'),'Path','Path'),'Phon','Phon'),'Plan','Plan'),'Plus','Plus'),'Port','Port'),'Post','Post'),'Prev','Prev'),'Quer','Quer'),'Rate','Rate'),'Read','Read'),'Role','Role'),'Self','Self'),'Send','Send'),'Sent','Sent'),'Ship','Ship'),'Size','Size'),'Step','Step'),'Term','Term'),'Time','Time'),'Toll','Toll'),'Tran','Tran'),'Trip','Trip'),'Type','Type'),'User','User'),'With','With'),'Work','Work'),'Year','Year'),'Activ','Activ'),'Admin','Admin'),'Agenc','Agenc'),'Alert','Alert'),'Alias','Alias'),'Batch','Batch'),'Blind','Blind'),'Block','Block'),'Check','Check'),'Citat','Citat'),'Class','Class'),'Color','Color'),'Count','Count'),'Court','Court'),'Creat','Creat'),'Cycle','Cycle'),'Email','Email'),'Entry','Entry'),'Error','Error'),'Event','Event'),'Expir','Expir'),'First','First'),'Float','Float'),'Group','Group'),'Horiz','Horiz'),'Ident','Ident'),'Image','Image'),'Index','Index'),'Langu','Langu'),'Match','Match'),'Modif','Modif'),'Plate','Plate'),'Plaza','Plaza'),'Print','Print'),'Prior','Prior'),'Purch','Purch'),'Queue','Queue'),'Raise','Raise'),'Right','Right'),'Setup','Setup'),'Shift','Shift'),'Speed','Speed'),'Spons','Spons'),'Stage','Stage'),'Stand','Stand'),'Start','Start'),'STAT_','STAT_'),'State','State')
			   ,'Level','Level'),'Super','Super'),'Surve','Surve'),'Table','Table'),'Title','Title'),'TxDot','TxDot'),'Updat','Updat'),'Valid','Valid'),'Value','Value'),'Verif','Verif'),'Video','Video'),'VToll','VToll'),'Waive','Waive'),'Write','Write'),'Action','Action'),'Active','Active'),'Amount','Amount'),'Appear','Appear'),'Approv','Approv'),'Assign','Assign'),'Bottom','Bottom'),'Bright','Bright'),'Calcul','Calcul'),'Change','Change'),'Charge','Charge'),'Confid','Confid'),'Config','Config'),'Credit','Credit'),'Detail','Detail'),'Direct','Direct'),'DocMgr','DocMgr'),'Enable','Enable'),'Ground','Ground'),'Handle','Handle'),'Header','Header'),'Height','Height'),'Histor','Histor'),'ImgEnh','ImgEnh'),'Invoic','Invoic'),'Length','Length'),'Letter','Letter'),'Manual','Manual'),'Messag','Messag'),'Method','Method'),'Middle','Middle'),'Number','Number'),'Option','Option'),'Parent','Parent'),'Period','Period'),'Portal','Portal'),'Posted','Posted'),'Prefer','Prefer'),'Prefix','Prefix'),'Primar','Primar'),'Protec','Protec'),'Qualif','Qualif'),'Reason','Reason'),'Rebill','Rebill'),'Record','Record'),'Reject','Reject'),'Remain','Remain'),'Remark','Remark'),'Renter','Renter'),'Report','Report'),'Result','Result'),'Retail','Retail'),'Return','Return'),'Review','Review'),'Serial','Serial'),'Source','Source'),'Status','Status'),'Submit','Submit'),'Suffix','Suffix'),'Syntax','Syntax'),'System','System'),'Unread','Unread'),'Upload','Upload'),'Violat','Violat'),'Volume','Volume'),'Account','Account'),'Address','Address'),'Balance','Balance'),'Carrier','Carrier'),'Categor','Categor'),'Channel','Channel'),'Complet','Complet'),'Consume','Consume'),'Contact','Contact'),'Correct','Correct'),'Deliver','Deliver'),'Deposit','Deposit'),'Dismiss','Dismiss'),'Display','Display'),'Facilit','Facilit'),'Frequen','Frequen'),'Generat','Generat'),'Hearing','Hearing'),'Inbound','Inbound'),'Indicat','Indicat'),'Invalid','Invalid'),'Malform','Malform'),'Manager','Manager'),'Misread','Misread'),'Notific','Notific'),'Parking','Parking'),'Pending','Pending'),'Premium','Premium'),'Process','Process'),'Receipt','Receipt'),'Receive','Receive'),'Renewal','Renewal'),'Replace','Replace'),'Request','Request'),'Require','Require'),'Resolve','Resolve'),'Service','Service'),'Sponsor','Sponsor'),'Storage','Storage'),'Summary','Summary'),'Tracker','Tracker'),'Trigger','Trigger'),'Trooper','Trooper'),'Unmatch','Unmatch'),'Vehicle','Vehicle'),'Visible','Visible'),'Approved','Approved'),'Authorit','Authorit'),'Conflict','Conflict'),'Contrast','Contrast'),'Customer','Customer'),'Decision','Decision'),'Discount','Discount'),'Download','Download'),'Eligible','Eligible'),'Inventor','Inventor'),'Loaction','Loaction'),'Location','Location'),'Metadata','Metadata'),'Position','Position'),'Response','Response'),'Sequence','Sequence'),'ShortCut','ShortCut'),'Template','Template'),'Terminat','Terminat'),'Vertical','Vertical'),'Affidavit','Affidavit'),
			   'Determina','Determina'),'Exception','Exception'),'Excessive','Excessive'),'RegBlocks','RegBlocks'),'Registrat','Registrat'),'Signature','Signature'),'Subscribe','Subscribe'),'Telephone','Telephone'),'Threshold','Threshold'),'Bankruptcy','Bankruptcy'),'Confidance','Confidance'),'Correspond','Correspond'),'Processing','Processing'),'Disposition','Disposition'),'Outstanding','Outstanding'),'Transaction','Transaction'),'Jurisdiction','Jurisdiction'),'Representativ','Representativ'),'IPSTransaction','IPSTransaction');
      
          SET tablealias = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(REPLACE
			   (InitCap(tablealias),'__','_'),'By','By'),'HV','HV'),'ID','ID'),'In','In'),'Is','Is'),'No','No'),'Of','Of'),'Or','Or'),'PK','PK'),'To','To'),'Acc','Acc'),'Act','Act'),'Add','Add'),'Adj','Adj'),'AIP','AIP'),'Amt','Amt'),'And','And'),'Bad','Bad'),'Ban','Ban'),'BOS','BOS'),'Cnt','Cnt'),'CSV','CSV'),'Day','Day'),'DMV','DMV'),'DPS','DPS'),'Due','Due'),'EIP','EIP'),'End','End'),'Fee','Fee'),'FK_','FK_'),'FTP','FTP'),'Hex','Hex'),'ICN','ICN'),'IDX','IDX'),'Img','Img'),'INX','INX'),'IOP','IOP'),'IX_','IX_'),'Key','Key'),'Lic','Lic'),'Log','Log'),'Map','Map'),'MIR','MIR'),'New','New'),'NNP','NNP'),'Non','Non'),'Num','Num'),'OCR','OCR'),'Out','Out'),'Own','Own'),'Pay','Pay'),'PBM','PBM'),'Raw','Raw'),'Ref','Ref'),'Rev','Rev'),'ROI','ROI'),'Seq','Seq'),'Sig','Sig'),'SSN','SSN'),'Tag','Tag'),'Tax','Tax'),'Top','Top'),'TP_','TP_'),'TSA','TSA'),'Txn','Txn'),'UQ_','UQ_'),'UTC','UTC'),'VCF','VCF'),'VIN','VIN'),'VIP','VIP'),'VRB','VRB'),'VSR','VSR'),'Web','Web'),'Zip','Zip'),'ALPR','ALPR'),'Attr','Attr'),'Auto','Auto'),'Axle','Axle'),'Bank','Bank'),'Bill','Bill'),'Call','Call'),'Case','Case'),'Cash','Cash'),'City','City'),'Clos','Clos'),'Code','Code'),'Coll','Coll'),'Comm','Comm'),'Cust','Cust'),'Data','Data'),'Date','Date'),'Desc','Desc'),'Down','Down'),'Driv','Driv'),'Effe','Effe'),'Exit','Exit'),'File','File'),'Flag','Flag'),'Hist','Hist'),'Hold','Hold'),'Home','Home'),'Host','Host'),'Info','Info'),'Item','Item'),'JSON','JSON'),'Lane','Lane'),'Last','Last'),'Left','Left'),'Line','Line'),'List','List'),'Load','Load'),'Look','Look'),'Mail','Mail'),'Main','Main'),'Make','Make'),'Mark','Mark'),'Mode','Mode'),'MST_','MST_'),'Name','Name'),'NIX_','NIX_'),'Note','Note'),'NTTA','NTTA'),'Paid','Paid'),'Path','Path'),'Phon','Phon'),'Plan','Plan'),'Plus','Plus'),'Port','Port'),'Post','Post'),'Prev','Prev'),'Quer','Quer'),'Rate','Rate'),'Read','Read'),'Role','Role'),'Self','Self'),'Send','Send'),'Sent','Sent'),'Ship','Ship'),'Size','Size'),'Step','Step'),'Term','Term'),'Time','Time'),'Toll','Toll'),'Tran','Tran'),'Trip','Trip'),'Type','Type'),'User','User'),'With','With'),'Work','Work'),'Year','Year'),'Activ','Activ'),'Admin','Admin'),'Agenc','Agenc'),'Alert','Alert'),'Alias','Alias'),'Batch','Batch'),'Blind','Blind'),'Block','Block'),'Check','Check'),'Citat','Citat'),'Class','Class'),'Color','Color'),'Count','Count'),'Court','Court'),'Creat','Creat'),'Cycle','Cycle'),'Email','Email'),'Entry','Entry'),'Error','Error'),'Event','Event'),'Expir','Expir'),'First','First'),'Float','Float'),'Group','Group'),'Horiz','Horiz'),'Ident','Ident'),'Image','Image'),'Index','Index'),'Langu','Langu'),'Match','Match'),'Modif','Modif'),'Plate','Plate'),'Plaza','Plaza'),'Print','Print'),'Prior','Prior'),'Purch','Purch'),'Queue','Queue'),'Raise','Raise'),'Right','Right'),'Setup','Setup'),'Shift','Shift'),'Speed','Speed'),'Spons','Spons'),'Stage','Stage'),'Stand','Stand'),'Start','Start'),'STAT_','STAT_'),'State','State')
			   ,'Level','Level'),'Super','Super'),'Surve','Surve'),'Table','Table'),'Title','Title'),'TxDot','TxDot'),'Updat','Updat'),'Valid','Valid'),'Value','Value'),'Verif','Verif'),'Video','Video'),'VToll','VToll'),'Waive','Waive'),'Write','Write'),'Action','Action'),'Active','Active'),'Amount','Amount'),'Appear','Appear'),'Approv','Approv'),'Assign','Assign'),'Bottom','Bottom'),'Bright','Bright'),'Calcul','Calcul'),'Change','Change'),'Charge','Charge'),'Confid','Confid'),'Config','Config'),'Credit','Credit'),'Detail','Detail'),'Direct','Direct'),'DocMgr','DocMgr'),'Enable','Enable'),'Ground','Ground'),'Handle','Handle'),'Header','Header'),'Height','Height'),'Histor','Histor'),'ImgEnh','ImgEnh'),'Invoic','Invoic'),'Length','Length'),'Letter','Letter'),'Manual','Manual'),'Messag','Messag'),'Method','Method'),'Middle','Middle'),'Number','Number'),'Option','Option'),'Parent','Parent'),'Period','Period'),'Portal','Portal'),'Posted','Posted'),'Prefer','Prefer'),'Prefix','Prefix'),'Primar','Primar'),'Protec','Protec'),'Qualif','Qualif'),'Reason','Reason'),'Rebill','Rebill'),'Record','Record'),'Reject','Reject'),'Remain','Remain'),'Remark','Remark'),'Renter','Renter'),'Report','Report'),'Result','Result'),'Retail','Retail'),'Return','Return'),'Review','Review'),'Serial','Serial'),'Source','Source'),'Status','Status'),'Submit','Submit'),'Suffix','Suffix'),'Syntax','Syntax'),'System','System'),'Unread','Unread'),'Upload','Upload'),'Violat','Violat'),'Volume','Volume'),'Account','Account'),'Address','Address'),'Balance','Balance'),'Carrier','Carrier'),'Categor','Categor'),'Channel','Channel'),'Complet','Complet'),'Consume','Consume'),'Contact','Contact'),'Correct','Correct'),'Deliver','Deliver'),'Deposit','Deposit'),'Dismiss','Dismiss'),'Display','Display'),'Facilit','Facilit'),'Frequen','Frequen'),'Generat','Generat'),'Hearing','Hearing'),'Inbound','Inbound'),'Indicat','Indicat'),'Invalid','Invalid'),'Malform','Malform'),'Manager','Manager'),'Misread','Misread'),'Notific','Notific'),'Parking','Parking'),'Pending','Pending'),'Premium','Premium'),'Process','Process'),'Receipt','Receipt'),'Receive','Receive'),'Renewal','Renewal'),'Replace','Replace'),'Request','Request'),'Require','Require'),'Resolve','Resolve'),'Service','Service'),'Sponsor','Sponsor'),'Storage','Storage'),'Summary','Summary'),'Tracker','Tracker'),'Trigger','Trigger'),'Trooper','Trooper'),'Unmatch','Unmatch'),'Vehicle','Vehicle'),'Visible','Visible'),'Approved','Approved'),'Authorit','Authorit'),'Conflict','Conflict'),'Contrast','Contrast'),'Customer','Customer'),'Decision','Decision'),'Discount','Discount'),'Download','Download'),'Eligible','Eligible'),'Inventor','Inventor'),'Loaction','Loaction'),'Location','Location'),'Metadata','Metadata'),'Position','Position'),'Response','Response'),'Sequence','Sequence'),'ShortCut','ShortCut'),'Template','Template'),'Terminat','Terminat'),'Vertical','Vertical'),'Affidavit','Affidavit'),
			   'Determina','Determina'),'Exception','Exception'),'Excessive','Excessive'),'RegBlocks','RegBlocks'),'Registrat','Registrat'),'Signature','Signature'),'Subscribe','Subscribe'),'Telephone','Telephone'),'Threshold','Threshold'),'Bankruptcy','Bankruptcy'),'Confidance','Confidance'),'Correspond','Correspond'),'Processing','Processing'),'Disposition','Disposition'),'Outstanding','Outstanding'),'Transaction','Transaction'),'Jurisdiction','Jurisdiction'),'Representativ','Representativ'),'IPSTransaction','IPSTransaction');
      
        END IF;
        -- First we have to drop existing table
        SET params_in_sql_out = concat(params_in_sql_out, code_points_to_string(ARRAY[
          13
        ]), 'CREATE OR REPLACE TABLE LND_TBOS.', new_table_name, ' ', table_index, ' ', 'AS', code_points_to_string(ARRAY[
          13
        ]), 'SELECT', select_string, code_points_to_string(ARRAY[
          13
        ]), 'FROM ', '[LND_TBOS.', table, '] AS [', tablealias, ']', code_points_to_string(ARRAY[
          13
        ]), ';');
        -- WHERE 1 = 1 - we need this for automated adding filter using SUBSTRING 
        IF strpos(params, 'No[]') > 0 THEN
          SET params_in_sql_out = replace(replace(params_in_sql_out, '[', ''), ']', '');
        END IF;
        IF strpos(params, 'NoPrint') = 0 THEN
          SELECT params_in_sql_out;
        END IF;
      END;
    END IF;
  END;
