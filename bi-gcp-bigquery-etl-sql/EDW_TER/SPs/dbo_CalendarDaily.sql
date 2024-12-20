CREATE PROC [dbo].[CalendarDaily] AS
IF OBJECT_ID('dbo.data_in')<>0
drop table dbo.data_in

IF OBJECT_ID('dbo.data_out')<>0
drop table dbo.data_out

-- -------------

create table dbo.data_in with (DISTRIBUTION = REPLICATE)
as
select	b.cal_day_bgn		cal_load_day_bgn
,	a.cal_dflt_day_bgn	cal_dflt_day_bgn
,	a.cal_dflt_day_end	cal_dflt_day_end
,	-201			etl_sid
from	land_perm.cal_load  a
  cross join
	(
	select	min(cal_day_bgn) as cal_day_bgn
	from
		(
		select	cast(max(TRANSACTION_DATE) as date)	as cal_day_bgn
		from	dbo.FACT_VIOLATOR_TRANSACTION
		union
		select	cast(max(INSERT_DATE) as date) as cal_day_bgn
		from	dbo.FACT_VIOLATOR_TRANSACTION
		)  latest
	)  b


truncate table stage.cal_load


insert into stage.cal_load
select	coalesce(a.cal_load_day_bgn, b.cal_load_day_bgn)
,	coalesce(a.cal_dflt_day_bgn, b.cal_dflt_day_bgn)
,	coalesce(a.cal_dflt_day_end, b.cal_dflt_day_end)
,	coalesce(a.etl_sid, b.etl_sid)
,	case
	  when b.etl_sid is null then 'i'
	  when a.etl_sid is null then 'd'
	  else 'u'
	end
from	dbo.data_in  a
  full outer join
	dto.cal_load  b
    on	a.etl_sid = b.etl_sid
except
select	coalesce(a.cal_load_day_bgn, b.cal_load_day_bgn)
,	coalesce(a.cal_dflt_day_bgn, b.cal_dflt_day_bgn)
,	coalesce(a.cal_dflt_day_end, b.cal_dflt_day_end)
,	coalesce(a.etl_sid, b.etl_sid)
,	case
	  when b.etl_chg like 'd' then 'd'
	  else 'u'
	end
from	dbo.data_in  a
  right outer join
	dto.cal_load  b
    on	a.etl_sid = b.etl_sid
    and	a.cal_load_day_bgn = b.cal_load_day_bgn
    and	a.cal_dflt_day_bgn = b.cal_dflt_day_bgn
    and	a.cal_dflt_day_end = b.cal_dflt_day_end


update dto.cal_load
set	cal_load_day_bgn = b.cal_load_day_bgn
,	cal_dflt_day_bgn = b.cal_dflt_day_bgn
,	cal_dflt_day_end = b.cal_dflt_day_end
,	etl_sid = b.etl_sid
,	etl_chg = b.etl_chg
,	etl_day = CURRENT_TIMESTAMP
from	stage.cal_load  b
where	dto.cal_load.etl_sid = b.etl_sid
  and	b.etl_chg in ('u', 'd')

insert into dto.cal_load
select	cal_load_day_bgn
,	cal_dflt_day_bgn
,	cal_dflt_day_end
,	etl_sid
,	etl_chg
,	CURRENT_TIMESTAMP
from	stage.cal_load
where	etl_chg in ('i')


IF OBJECT_ID('dbo.data_in')<>0
drop table dbo.data_in


-- -------------

create table dbo.data_in with (DISTRIBUTION = REPLICATE)
as
select	a.cal_id		cal_id
,	a.cal_yr_bgn		cal_yr_bgn
,	count(a.cal_yr_bgn) over(partition by a.cal_id order by a.cal_yr_bgn desc) - count(c.cal_load_day_bgn)
				cal_yr_ix
from	dto.cal_yr  a
  join	dto.cal_yr  b
    on	a.cal_id = b.cal_id
  join	dto.cal_load  c
    on	b.cal_yr_end > c.cal_load_day_bgn
group by	a.cal_id
,	a.cal_yr_bgn


update dto.cal_yr
set	cal_yr_ix = b.cal_yr_ix
from	dbo.data_in  b
where	dto.cal_yr.cal_id = b.cal_id
  and	dto.cal_yr.cal_yr_bgn = b.cal_yr_bgn


IF OBJECT_ID('dbo.data_in')<>0
drop table dbo.data_in

-- -------------

/*
with TABLE_IX as
(
select	a.cal_id			cal_id
,	a.cal_sea_bgn		cal_sea_bgn
,	count(a.cal_sea_bgn) over(partition by a.cal_id order by a.cal_sea_bgn desc) - count(c.cal_load_day_bgn)				cal_sea_ix
from	dto.CAL_SEA  a
  join	dto.CAL_SEA  b
    on	a.cal_id = b.cal_id
  join	dto.CAL_LOAD  c
    on	b.cal_sea_end > c.cal_load_day_bgn
group by	a.cal_id
,	a.cal_sea_bgn
)
update dto.CAL_SEA
set	cal_sea_ix = b.cal_sea_ix
,	cal_yr_ix = c.cal_yr_ix
from	dto.CAL_SEA  a
  join	TABLE_IX  b
    on	a.cal_id = b.cal_id
    and	a.cal_sea_bgn = b.cal_sea_bgn
  join	dto.CAL_YR  c
    on	a.cal_id = c.cal_id
    and	a.cal_yr_bgn = c.cal_yr_bgn
go

update statistics dto.CAL_SEA
go
*/

-- -------------

create table dbo.data_in with (DISTRIBUTION = REPLICATE)
as
select	a.cal_id		cal_id
,	a.cal_qtr_bgn		cal_qtr_bgn
,	count(a.cal_qtr_bgn) over(partition by a.cal_id order by a.cal_qtr_bgn desc) - count(c.cal_load_day_bgn)
				cal_qtr_ix
,	d.cal_yr_ix		cal_yr_ix
from	dto.cal_qtr  a
  join	dto.cal_qtr  b
    on	a.cal_id = b.cal_id
  join	dto.cal_load  c
    on	b.cal_qtr_end > c.cal_load_day_bgn
  join	dto.cal_yr  d
    on	a.cal_id = d.cal_id
    and	a.cal_yr_bgn = d.cal_yr_bgn
group by	a.cal_id
,	a.cal_qtr_bgn
,	d.cal_yr_ix

update dto.cal_qtr
set	cal_qtr_ix = b.cal_qtr_ix
,	cal_yr_ix = b.cal_yr_ix
from	dbo.data_in  b
where	dto.cal_qtr.cal_id = b.cal_id
  and	dto.cal_qtr.cal_qtr_bgn = b.cal_qtr_bgn

IF OBJECT_ID('dbo.data_in')<>0
drop table dbo.data_in

-- -------------

create table dbo.data_in with (DISTRIBUTION = REPLICATE)
as
select	a.cal_id		cal_id
,	a.cal_prd_bgn		cal_prd_bgn
,	count(a.cal_prd_bgn) over(partition by a.cal_id order by a.cal_prd_bgn desc) - count(c.cal_load_day_bgn)
				cal_prd_ix
,	d.cal_qtr_ix		cal_qtr_ix
,	d.cal_yr_ix		cal_yr_ix
from	dto.cal_prd  a
  join	dto.cal_prd  b
    on	a.cal_id = b.cal_id
  join	dto.cal_load  c
    on	b.cal_prd_end > c.cal_load_day_bgn
  join	dto.cal_qtr  d
    on	a.cal_id = d.cal_id
    and	a.cal_qtr_bgn = d.cal_qtr_bgn
group by	a.cal_id
,	a.cal_prd_bgn
,	d.cal_qtr_ix
,	d.cal_yr_ix

update dto.cal_prd
set	cal_prd_ix = b.cal_prd_ix
,	cal_qtr_ix = b.cal_qtr_ix
,	cal_yr_ix = b.cal_yr_ix
from	dbo.data_in  b
where	dto.cal_prd.cal_id = b.cal_id
  and	dto.cal_prd.cal_prd_bgn = b.cal_prd_bgn


IF OBJECT_ID('dbo.data_in')<>0
drop table dbo.data_in

-- -------------

create table dbo.data_in with (DISTRIBUTION = REPLICATE)
as
select	a.cal_id		cal_id
,	a.cal_wk_bgn		cal_wk_bgn
,	count(a.cal_wk_bgn) over(partition by a.cal_id order by a.cal_wk_bgn desc) - count(c.cal_load_day_bgn)
				cal_wk_ix
from	dto.cal_wk  a
  join	dto.cal_wk  b
    on	a.cal_id = b.cal_id
  join	dto.cal_load  c
    on	b.cal_wk_end > c.cal_load_day_bgn
group by	a.cal_id
,	a.cal_wk_bgn


update dto.cal_wk
set	cal_wk_ix = b.cal_wk_ix
from	dbo.data_in  b
where	dto.cal_wk.cal_id = b.cal_id
  and	dto.cal_wk.cal_wk_bgn = b.cal_wk_bgn


IF OBJECT_ID('dbo.data_in')<>0
drop table dbo.data_in

-- -------------

create table dbo.data_in with (DISTRIBUTION = REPLICATE)
as
select	a.cal_id		cal_id
,	a.cal_day_bgn		cal_day_bgn
,	count(a.cal_day_bgn) over(partition by a.cal_id order by a.cal_day_bgn desc) - count(c.cal_load_day_bgn)
				cal_day_ix
,	d.cal_wk_ix		cal_wk_ix
,	e.cal_prd_ix		cal_prd_ix
,	e.cal_qtr_ix		cal_qtr_ix
,	e.cal_yr_ix		cal_yr_ix
from	dto.cal_day  a
  join	dto.cal_day  b
    on	a.cal_id = b.cal_id
  join	dto.cal_load  c
    on	b.cal_day_end > dateadd(day, 1, c.cal_load_day_bgn)
  join	dto.cal_wk  d
    on	a.cal_id = d.cal_id
    and	a.cal_wk_bgn = d.cal_wk_bgn
  join	dto.cal_prd  e
    on	a.cal_id = e.cal_id
    and	a.cal_prd_bgn = e.cal_prd_bgn
group by	a.cal_id
,	a.cal_day_bgn
,	d.cal_wk_ix
,	e.cal_prd_ix
,	e.cal_qtr_ix
,	e.cal_yr_ix


update dto.cal_day
set	cal_day_ix = b.cal_day_ix
,	cal_wk_ix = b.cal_wk_ix
,	cal_prd_ix = b.cal_prd_ix
,	cal_qtr_ix = b.cal_qtr_ix
,	cal_yr_ix = b.cal_yr_ix
from	dbo.data_in  b
where	dto.cal_day.cal_id = b.cal_id
  and	dto.cal_day.cal_day_bgn = b.cal_day_bgn

IF OBJECT_ID('dbo.data_in')<>0
drop table dbo.data_in


