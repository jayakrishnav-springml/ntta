CREATE VIEW [dbo].[DIM_MONTH_TXN_VW] AS Select 

a.TripMonthID,
a.snapshotmonthid,
a.AsOfDayID,
 MaxAsOfDayID ,
  MinAsOfDayID	,
	  ROW_NUMBER() OVER	
 (PARTITION BY a.TripMonthID ORDER BY a.snapshotmonthid		
      )-1 as MthCount	


from (
select 	
distinct
TripMonthID , snapshotmonthid,		
AsOfDayID ,	


(case when AsOfDayID=  max(AsOfDayID) over (partition by TripMonthID  order by snapshotmonthid ) 
             then 1 else 0
        end) as MaxFirstEntryFlag,


max(AsOfDayID ) over( partition by TripMonthID) MaxAsOfDayID  ,		
min(AsOfDayID ) over( partition by TripMonthID) MinAsOfDayID	


from   dbo.Fact_UnifiedTransaction_SummarySnapshot 

	--where TripMonthID =202303 
		
		
	group by TripMonthID,snapshotmonthid,AsOfDayID

	)a 

	where MaxFirstEntryFlag<>0;