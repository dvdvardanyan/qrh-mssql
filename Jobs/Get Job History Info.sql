use msdb
go

declare @detailed bit = 0;

select
	j.name
	, case jh.run_status
		when 0 then 'Failed'
		when 1 then 'Succeeded'
		when 2 then 'Retry'
		when 3 then 'Canceled'
		when 4 then 'In Progress'
	end as "Status"
	, jh.run_date
	, jh.run_time
	, jh.run_duration
	, case when jh.run_status != 1 then jh.message else 'The job succeeded.' end as "Message"
from sysjobs as j
inner join sysjobhistory as jh on j.job_id = jh.job_id
where j.enabled = 1 and ((@detailed = 0 and jh.step_id = 0) or (@detailed = 1 and jh.step_id > 0))
order by j.name, jh.run_date, jh.run_time
go
