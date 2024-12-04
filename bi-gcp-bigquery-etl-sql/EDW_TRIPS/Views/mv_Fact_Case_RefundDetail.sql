CREATE MATERIALIZED VIEW EDW_TRIPS.mv_Fact_Case_RefundDetail
OPTIONS (enable_refresh = true)
AS (
select     
             a.caseid, 
             a.customerid, 
             V.vehicleid,
             vt.vehicletagid,
             pct.casetypeid,
             casestatus casestatusid,
             cast(a.datereported as date) casecreated, 
             b.approveddate refundissueddate, -- This column is taken based on TRIPS UI
             assignedto,    -- This column needs to be joined to customer table to get the details of assigned person
             b.approvedby,	
             b.amount refundrequestamount, 
             case when lkp.lookuptypecode='Closed(Rejected)' then 0 else b.Amount end as refundamount,  -- This is populated only when the refund is resolved.            
from   LND_TBOS.CaseManager_PmCase a 
             JOIN LND_TBOS.CaseManager_PmCaseTypes pct
                    on pct.CaseTypeID = a.CaseTypeId
            LEFT JOIN  LND_TBOS.Tollplus_CaseLinks cl 
                    on a.caseId = cl.caseID                     
            LEFT JOIN   LND_TBOS.finance_REFUNDREQUESTS_QUEUE b
                    on cl.linkID = b.REFUNDREQUESTID
                    and linksource = 'FINANCE.REFUNDREQUESTS_QUEUE'
            LEFT JOIN LND_TBOS.TollPlus_TP_Customer_Contacts CT
                    on CT.customerid = assignedto
             LEFT JOIN edw_trips.dim_customer C
                    on a.customerid=C.customerid
             LEFT JOIN edw_trips.dim_Vehicle v
                    on v.customerid=C.customerid
             LEFT JOIN  edw_trips.dim_Vehicletag vt
                    on vt.vehicleid =v.vehicleid
             LEFT JOIN LND_TBOS.TollPlus_Ref_LookupTypeCodes_Hierarchy Lkp 
                   on Lkp.lookuptypecodeid=cl.CaseStatus
where  a.CaseTypeID = 76 
)
