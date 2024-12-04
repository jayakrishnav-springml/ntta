CREATE OR REPLACE PROCEDURE `EDW_TRIPS.GIS_Customer_Data_Load`()
BEGIN
  DECLARE log_source STRING DEFAULT 'EDW_TRIPS.GIS_Customer_Data_Load';
  DECLARE log_start_date DATETIME;
  DECLARE log_message STRING;
  DECLARE sql STRING;
  BEGIN
    DECLARE month_year STRING;

    SET month_year = FORMAT_DATE('%Y_%m', CURRENT_DATE()); 
    SET log_start_date = current_datetime('America/Chicago');
    SET log_message = concat('Started Loading FILES_EXPORT.BI_CUSTOMERDATA',month_year);
    CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date,log_message, 'I', NULL , NULL );

    SET sql = """
      CREATE OR REPLACE TABLE FILES_EXPORT.BI_CUSTOMERDATA_"""||month_year||""" AS
        SELECT
            dim_customer.customerid,
            dim_customer.title,
            dim_customer.firstname,
            dim_customer.middleinitial,
            dim_customer.lastname,
            dim_customer.suffix,
            dim_customer.addresstype,
            dim_customer.addressline1,
            dim_customer.addressline2,
            dim_customer.city,
            dim_customer.state,
            dim_customer.country,
            dim_customer.zipcode,
            dim_customer.plus4,
            dim_customer.addressupdateddate,
            dim_customer.mobilephonenumber,
            dim_customer.homephonenumber,
            dim_customer.workphonenumber,
            dim_customer.preferredphonetype,
            dim_customer.customerplanid,
            dim_customer.customerplandesc,
            dim_customer.accountcategoryid,
            dim_customer.accountcategorydesc,
            dim_customer.accounttypeid,
            dim_customer.accounttypecode,
            dim_customer.accounttypedesc,
            dim_customer.accountstatusid,
            dim_customer.accountstatuscode,
            dim_customer.accountstatusdesc,
            dim_customer.accountstatusdate,
            dim_customer.customerstatusid,
            dim_customer.customerstatuscode,
            dim_customer.customerstatusdesc,
            dim_customer.revenuecategoryid,
            dim_customer.revenuecategorycode,
            dim_customer.revenuecategorydesc,
            dim_customer.revenuetypeid,
            dim_customer.revenuetypecode,
            dim_customer.revenuetypedesc,
            dim_customer.channelid,
            dim_customer.channelname,
            dim_customer.channeldesc,
            dim_customer.rebillamount,
            dim_customer.rebilldate,
            dim_customer.autoreplenishmentid,
            dim_customer.autoreplenishmentcode,
            dim_customer.autoreplenishmentdesc,
            dim_customer.tolltagacctbalance,
            dim_customer.zipcashcustbalance,
            dim_customer.refundbalance,
            dim_customer.tolltagdepositbalance,
            dim_customer.fleetacctbalance,
            dim_customer.companycode,
            dim_customer.companyname,
            dim_customer.fleetflag,
            dim_customer.badaddressflag,
            dim_customer.incollectionsflag,
            dim_customer.hvflag,
            dim_customer.adminhearingscheduledflag,
            dim_customer.paymentplanestablishedflag,
            dim_customer.vrbflag,
            dim_customer.citationissuedflag,
            dim_customer.bankruptcyflag,
            dim_customer.writeoffflag,
            dim_customer.groundtransportationflag,
            dim_customer.autorecalcreplamtflag,
            dim_customer.autorebillfailedflag,
            dim_customer.autorebillfailed_startdate,
            dim_customer.expiredcreditcardflag,
            dim_customer.expiredcreditcard_startdate,
            dim_customer.tolltagacctnegbalanceflag,
            dim_customer.tolltagacctlowbalanceflag,
            dim_customer.thresholdamount,
            dim_customer.lowbalancedate,
            dim_customer.negbalancedate,
            dim_customer.linktolltagcustomerid,
            dim_customer.zipcashtotolltagflag,
            dim_customer.zipcashtotolltagdate,
            dim_customer.tolltagtozipcashflag,
            dim_customer.tolltagtozipcashdate,
            dim_customer.directacctflag,
            dim_customer.seq1,
            dim_customer.seq2,
            dim_customer.zc_tolltagacctcreatedate,
            dim_customer.zipcashacctcount,
            dim_customer.firstzipcashcustomerid,
            dim_customer.firstzipcashacctcreatedate,
            dim_customer.lastzipcashcustomerid,
            dim_customer.lastzipcashacctcreatedate,
            dim_customer.accountcreatedate,
            dim_customer.accountcreatedby,
            dim_customer.accountcreatechannelid,
            dim_customer.accountcreatechannelname,
            dim_customer.accountcreatechanneldesc,
            dim_customer.accountcreateposid,
            dim_customer.accountopendate,
            dim_customer.accountopenedby,
            dim_customer.accountopenchannelid,
            dim_customer.accountopenchannelname,
            dim_customer.accountopenchanneldesc,
            dim_customer.accountopenposid,
            dim_customer.accountlastactivedate,
            dim_customer.accountlastactiveby,
            dim_customer.accountlastactivechannelid,
            dim_customer.accountlastactivechannelname,
            dim_customer.accountlastactivechanneldesc,
            dim_customer.accountlastactiveposid,
            dim_customer.accountlastclosedate,
            dim_customer.accountlastcloseby,
            dim_customer.accountlastclosechannelid,
            dim_customer.accountlastclosechannelname,
            dim_customer.accountlastclosechanneldesc,
            dim_customer.accountlastcloseposid,
            dim_customer.updateddate,
            dim_customer.lnd_updatedate,
            dim_customer.edw_updatedate,
            NULL AS isfleet,
            NULL AS regcustrefid
          FROM
            EDW_TRIPS.Dim_CUSTOMER
        ORDER BY
          customerid """ ;

        EXECUTE IMMEDIATE sql;

  SET log_message = concat('Loaded FILES_EXPORT.BI_CUSTOMERDATA',month_year);
  CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date,log_message, 'I', -1 , NULL );
  
  EXCEPTION WHEN ERROR THEN
    BEGIN 
        DECLARE error_message STRING DEFAULT @@error.message;
        CALL EDW_TRIPS_SUPPORT.ToLog(log_source, log_start_date,error_message, 'E', -1 , NULL ); 
        RAISE USING MESSAGE = error_message;  -- Rethrow the error!
    END;
  END;
END;