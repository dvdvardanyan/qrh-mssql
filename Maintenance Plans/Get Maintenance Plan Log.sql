use msdb
go

declare @from_days_ago int = 1;
declare @generate_html_report bit = 1;

------------------------------------------------------------------------------------------------

declare @plan_name nvarchar(300) = null;
declare @show_failed_only bit = 0;
declare @font_size int = 18;

------------------------------------------------------------------------------------------------

if(@from_days_ago is not null and @from_days_ago >= 0 and @show_failed_only is not null)
begin

	if(@generate_html_report = 0)
	begin
		select
			MP.name as "Plan Name",
			MPL.start_time as "Start Time",
			MPL.end_time as "End Time",
			convert(varchar(30), MPL.end_time - MPL.start_time, 108) as "Duration",
			case when MPL.succeeded = 1 then 'Succeeded' else 'Failed' end as "Status",
			MPLD.error_message as "Error Message",
			MPLD.command as "Command",
			case when MPLD.succeeded = 1 then 'Succeeded' else 'Failed' end as "Item Status"
		from dbo.sysmaintplan_plans as MP
		inner join dbo.sysmaintplan_log as MPL on MP.id = MPL.plan_id
		inner join dbo.sysmaintplan_logdetail as MPLD on MPL.task_detail_id = MPLD.task_detail_id
		where (@plan_name is null or MP.name = @plan_name)
			and datediff(dd, MPL.start_time, getdate()) <= @from_days_ago
			and (@show_failed_only = 0 or (MPL.succeeded & @show_failed_only = 0 and MPLD.succeeded & @show_failed_only = 0))
	end
	else
	begin

		select
			(
				select
					'text/javascript' as "@type",
					'function toggleDetails(id) {var dtl = document.getElementById(id + "_dtl");var btn = document.getElementById(id + "_a");if(dtl.style.display === "none") {dtl.style.display = "block";btn.innerHTML = "- Hide Details";} else {dtl.style.display = "none";btn.innerHTML = "+ Expand Details";}}' as [text()]
				for xml path('script'), root('header'), type
			),
			--> BODY element
			(
				select
					--> Style of BODY element
					'font-family: Verdana, Geneva, sans-serif; padding: 20px;' as "@style",
					(
						select
							'padding: 10px; font-size: ' + cast(@font_size as varchar(30)) + 'px; background-color: #ffef96; border: 1px solid #909090; margin-bottom: 20px;' as "@style",
							'Maintenance plan execution log for the last ' + cast(@from_days_ago as varchar(30)) + ' day(s). Server: ' + @@SERVERNAME + '. Date: ' + convert(varchar(30), getdate(), 22) as [text()]
						for xml path('div'), type
					),
					(
						select
							--> Plan name DIV element
							(select 'font-size: ' + cast(@font_size as varchar(30)) + 'px; background-color: #e5e5e5; padding: 10px;' as "@style", MP.name as "b" for xml path('div'), type),
							--> Plan log records DIV element
							(
								select 'font-size: ' + cast(@font_size - 2 as varchar(30)) + 'px; text-align: center; padding: 5px 0 5px 0;' as "@style",
								(
									select
										--> Plan detail start time
										(select 'vertical-align: top; padding: 5px 5px 5px 20px;' as "@style", convert(varchar(30), MPL.start_time, 101) as [text()] for xml path('td'), type),
										--> Plan detail end time
										(select 'vertical-align: top; padding: 5px 5px 5px 20px;' as "@style", convert(varchar(30), MPL.start_time, 108) as [text()] for xml path('td'), type),
										--> Plan detail duration
										(select 'vertical-align: top; padding: 5px 20px 5px 20px;' as "@style", convert(varchar(30), MPL.end_time - MPL.start_time, 108) as [text()] for xml path('td'), type),
										--> Plan detail status
										(
											select
												'vertical-align: top; padding: 5px; color: #ffffff; background-color: #' + case when MPL.succeeded = 1 then '00ad42;' else 'e03c2a;' end as "@style",
												case when MPL.succeeded = 1 then 'Succeeded' else 'Failed' end as [text()]
											for xml path('td'), type
										),
										--> Plan step details
										(
											select
												'text-align: left; padding: 5px 5px 5px 20px;' as "@style",
												case
													when MPL.succeeded = 1 then ''
													else
													(
														select
															--> Button to expand or hide details
															(select cast(MPL.task_detail_id as varchar(36)) + '_a' as "a/@id", 'javascript:toggleDetails("' + cast(MPL.task_detail_id as varchar(36)) + '");' as "a/@href", '+ Expand Details' as "a" for xml path('div'), type),
															--> Step details
															(
																select
																	cast(MPL.task_detail_id as varchar(36)) + '_dtl' as "@id",
																	'display: none;' as "@style",
																	(
																		select
																			--> Style of step details
																			'font-size: ' + cast(@font_size - 2 as varchar(30)) + 'px; text-align: center;' as "@style",
																			--> Step error messages
																			(
																				select isnull
																				(
																					(select
																						(select 'padding: 5px;' as "@style", MPLD.Line2 as [text()] for xml path('td'), type),
																						(
																							select
																								'vertical-align: top; padding: 5px; color: #ffffff; background-color: #' + case when MPLD.succeeded = 1 then '00ad42;' else 'e03c2a;' end as "@style",
																								case when MPLD.succeeded = 1 then 'Succeeded' else 'Failed' end as [text()]
																							for xml path('td'), type
																						),
																						(select 'text-align: left; padding: 5px;' as "@style", MPLD.error_message as [text()] for xml path('td'), type)
																					from dbo.sysmaintplan_logdetail as MPLD where MPLD.task_detail_id = MPL.task_detail_id
																					and (@show_failed_only = 0 or (MPLD.succeeded & @show_failed_only = 0))
																					order by MPLD.start_time desc
																					for xml path('tr'), type)
																					, 'Details could not be found'
																				)
																				
																			)
																		for xml path('table'), type
																	)
																for xml path('div'), type
															)
														for xml path(''), type
													)
												end
											for xml path('td'), type
										)
									from dbo.sysmaintplan_log as MPL
									where MPL.plan_id = MP.id
										and datediff(dd, MPL.start_time, getdate()) <= @from_days_ago
										and (@show_failed_only = 0 or (MPL.succeeded & @show_failed_only = 0))
									order by MPL.start_time desc
									for xml path('tr'), type
								)
								for xml path('table'), root('div'), type
							)
						from dbo.sysmaintplan_plans as MP
						order by MP.name
						for xml path('div'), type
					)
				for xml path('body'), type
			)
		for xml path('root')
	end
	
end
else
begin
	print('@from_days_ago or @show_failed_only parameter is invalid.');
end
go