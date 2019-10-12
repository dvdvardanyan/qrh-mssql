use msdb
go

declare @WeekDays table(ID int not null, Value varchar(30) not null);
insert into @WeekDays(ID, Value) values(1, 'Sunday'),(2, 'Monday'),(4, 'Tuesday'),(8, 'Wednesday'),(16, 'Thursday'),(32, 'Friday'),(64, 'Saturday');

declare @WeekClass table(ID int not null, Value varchar(30) not null);
insert into @WeekClass(ID, Value) values(0, 'N/A'),(1, 'first'),(2, 'second'),(4, 'third'),(8, 'fourth'),(16, 'last');

declare @MonthlySchedule table(ID int not null,Value varchar(30) not null);
insert into @MonthlySchedule(ID, Value) values(1, 'Sunday'),(2, 'Monday'),(3, 'Tuesday'),(4, 'Wednesday'),(5, 'Thursday'),(6, 'Friday'),(7, 'Saturday'),(8, 'day'),(9, 'weekday'),(10, 'weekend day');

select
	'"' + Jobs.name + '"' as "Name"
	, '"' + replace(Jobs.description, '"', '') + '"' as "Description"
	, case when Jobs.enabled = 1 and Schedules.enabled = 1 then 'Yes' else 'No' end as "JobEnabled"
	, case when Schedules.enabled = 1 then 'Y' else '' end as "ScheduleEnabled"
	, case
		when Schedules.freq_type = 1 then
			'Occurs on ' + convert(varchar, convert(datetime, convert(char(8), Schedules.active_start_date)), 101) 
			+ ' at '
			+ stuff(stuff((left('000000', 6 - len(Schedules.active_start_time)) + convert(varchar(6), Schedules.active_start_time)), 3, 0, ':'), 6, 0, ':')
			+ '.'
		when Schedules.freq_type in (4, 8, 16, 32) then
			'Occurs every '
			+ case Schedules.freq_type
				when 4 then	cast(Schedules.freq_interval as varchar) + ' day(s)'
				when 8 then cast(Schedules.freq_recurrence_factor as varchar) + ' week(s) on ' + stuff((select ', ' + WeekDays.Value as [text()] from @WeekDays as WeekDays where Schedules.freq_interval & WeekDays.ID <> 0 order by WeekDays.ID for xml path('')), 1, 1, '')
				when 16 then cast(Schedules.freq_recurrence_factor as varchar) + ' month(s)' + ' on day ' + cast(freq_interval as varchar) + ' of that month'
				when 32 then 
					(select Value from @WeekClass as WeekClass where ID = Schedules.freq_relative_interval)
					+ ' ' + (select Value from @MonthlySchedule as MonthlySchedule where MonthlySchedule.ID = Schedules.freq_interval)
					+ ' of every ' + cast(Schedules.freq_recurrence_factor as varchar) + ' month(s)'
			end
			+ case
				when Schedules.freq_subday_type = 1
				then ' at ' + stuff(stuff((left('000000', 6 - len(Schedules.active_start_time)) + convert(varchar(6), Schedules.active_start_time)), 3, 0, ':'), 6, 0, ':')
				else ' every ' + cast(Schedules.freq_subday_interval as varchar)
					+ case Schedules.freq_subday_type
						when 2 then ' second(s) between '
						when 4 then ' minute(s) between '
						when 8 then ' hour(s) between '
					end
					+ stuff(stuff((left('000000', 6 - len(Schedules.active_start_time)) + convert(varchar(6), Schedules.active_start_time)), 3, 0, ':'), 6, 0, ':')
					+ ' and '
					+ stuff(stuff((left('000000', 6 - len(Schedules.active_end_time)) + convert(varchar(6), Schedules.active_end_time)), 3, 0, ':'), 6, 0, ':')
			end			
			+ '. Schedule will be used '
			+ case
				when Schedules.active_end_date = 99991231
				then + 'starting ' + convert(varchar, convert(datetime, convert(char(8), Schedules.active_start_date)), 101)
				else
					+ 'between ' + convert(varchar, convert(datetime, convert(char(8), Schedules.active_start_date)), 101)
					+ ' and ' + convert(varchar, convert(datetime, convert(char(8), Schedules.active_end_date)), 101)
			end			
			+ '.'
		when Schedules.freq_type = 64 then 'Runs when the SQL Server Agent service starts.'
		when Schedules.freq_type = 128 then 'Runs when the computer is idle.'
		else 'N/A'
	end as Schedule
	, JobSchedules.next_run_date
	, JobSchedules.next_run_time
from dbo.sysjobs as Jobs
left outer join dbo.sysjobschedules as JobSchedules
on Jobs.job_id = JobSchedules.job_id
left outer join dbo.sysschedules as Schedules
on JobSchedules.schedule_id = Schedules.schedule_id
where Jobs.enabled = 1 and Schedules.enabled = 1
order by 4
go
