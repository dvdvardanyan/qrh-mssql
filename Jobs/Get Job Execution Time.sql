use msdb
go

with JobInfo(ID, JobName, StartTime, Duration) as
(
	select
		Jobs.job_id as ID
		,Jobs.name as JobName
		, convert(datetime, convert(char(8), run_date) + ' ' +  stuff(stuff((left('000000', 6 - len(run_time))+ convert(varchar(6), run_time)), 3, 0, ':'), 6, 0, ':')) as StartTime
		, cast(stuff(stuff((left('000000', 6 - len(run_duration)) + convert(VARCHAR(6),run_duration)), 3, 0, ':'), 6, 0, ':') as time) as Duration
	from msdb.dbo.sysjobs as Jobs
	inner join msdb.dbo.sysjobhistory as JobHistory
	on Jobs.job_id = JobHistory.job_id
	where convert(datetime, convert(char(8),run_date)) >= '2014-09-01'
	and step_id = 0
)
select 
	ID
	, JobName
	, convert(varchar, dateadd(ms, avg(datediff(SECOND, '0:00:00', Duration)) * 1000, 0), 108) as AvgDuration
	, convert(varchar, max(Duration), 108) as MaxDuration
	, convert(varchar, min(Duration), 108) as MinDuration 
	, max(StartTime) as LastExecution
from JobInfo group by ID, JobName order by max(Duration) desc
go
