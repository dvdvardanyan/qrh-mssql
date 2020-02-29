use [TARGET_DATABASE]
go

select
	pln.plan_id,
	pln.query_id,
	pln.count_compiles,
	pln.is_parallel_plan,
	cast(pln.avg_compile_duration * 1.0 / 1000000 as decimal(10, 3)) as avg_compile_duration_sec,
	cast(pln.last_compile_duration * 1.0 / 1000000 as decimal(10, 3)) as last_compile_duration_sec,
	pln.last_execution_time,
	cast(pln.query_plan as xml) as query_plan,
	qry.query_parameterization_type_desc,

	qry.count_compiles,

	cast(qry.avg_compile_duration * 1.0 / 1000000 as decimal(10, 3)) as avg_compile_duration_sec,
	cast(qry.last_compile_duration * 1.0 / 1000000 as decimal(10, 3)) as last_compile_duration_sec,

	cast(qry.avg_compile_memory_kb * 1.0 / 1024 as decimal(10, 3)) as avg_compile_memory_mb,
	cast(qry.last_compile_memory_kb * 1.0 / 1024 as decimal(10, 3)) as last_compile_memory_mb,
	cast(qry.max_compile_memory_kb * 1.0 / 1024 as decimal(10, 3)) as max_compile_memory_mb,

	cast(qry.avg_bind_duration * 1.0 / 1000000 as decimal(10, 3)) as avg_bind_duration_to_statistics_sec,
	cast(qry.last_bind_duration * 1.0 / 1000000 as decimal(10, 3)) as last_bind_duration_to_statistics_sec,
	cast(qry.avg_bind_cpu_time * 1.0 / 1000000 as decimal(10, 3)) as avg_bind_cpu_time_to_statistics_sec,
	cast(qry.last_bind_cpu_time * 1.0 / 1000000 as decimal(10, 3)) as last_bind_cpu_time_to_statistics_sec,

	cast(qry.avg_optimize_duration * 1.0 / 1000000 as decimal(10, 3)) as avg_optimize_duration_sec,
	cast(qry.last_optimize_duration * 1.0 / 1000000 as decimal(10, 3)) as last_optimize_duration_sec,
	cast(qry.avg_optimize_cpu_time * 1.0 / 1000000 as decimal(10, 3)) as avg_optimize_cpu_time_sec,
	cast(qry.last_optimize_cpu_time * 1.0 / 1000000 as decimal(10, 3)) as last_optimize_cpu_time_sec,

	qrytxt.query_sql_text
from sys.query_store_plan as pln
inner join sys.query_store_query as qry on pln.query_id = qry.query_id
inner join sys.query_store_query_text as qrytxt on qry.query_text_id = qrytxt.query_text_id
--cross apply sys.dm_exec_sql_text(qry.last_compile_batch_sql_handle) as qrytxt
where
--pln.is_trivial_plan = 0
--and
pln.plan_id = 86
go

select

	convert(varchar(30), cast(pln_stats_interval.start_time as datetime) , 120) + ' - ' + convert(varchar(30), cast(pln_stats_interval.end_time as datetime) , 120) as capture_interval,
	
	pln_stats.plan_id,
	execution_type_desc,
	cast(last_execution_time as datetime) as last_execution_time,
	count_executions,

	'Duration:' as Metric,
	cast(pln_stats.avg_duration * 1.0 / 1000000 as decimal(10, 3)) as avg_duration_sec,
	cast(pln_stats.last_duration * 1.0 / 1000000 as decimal(10, 3)) as last_duration_sec,
	cast(pln_stats.min_duration * 1.0 / 1000000 as decimal(10, 3)) as min_duration_sec,
	cast(pln_stats.max_duration * 1.0 / 1000000 as decimal(10, 3)) as max_duration_sec,
	cast(pln_stats.stdev_duration * 1.0 / 1000000 as decimal(10, 3)) as stdev_duration_sec,

	'Rows:' as Metric,
	pln_stats.avg_rowcount,
	pln_stats.last_rowcount,
	pln_stats.min_rowcount,
	pln_stats.max_rowcount,
	pln_stats.stdev_rowcount,

	'CPU Time:' as Metric,
	cast(pln_stats.avg_cpu_time * 1.0 / 1000000 as decimal(10, 3)) as avg_cpu_time_sec,
	cast(pln_stats.last_cpu_time * 1.0 / 1000000 as decimal(10, 3)) as last_cpu_time_sec,
	cast(pln_stats.min_cpu_time * 1.0 / 1000000 as decimal(10, 3)) as min_cpu_time_sec,
	cast(pln_stats.max_cpu_time * 1.0 / 1000000 as decimal(10, 3)) as max_cpu_time_sec,
	cast(pln_stats.stdev_cpu_time * 1.0 / 1000000 as decimal(10, 3)) as stdev_cpu_time_sec,

	'Logical I/O Reads:' as Metric,
	pln_stats.avg_logical_io_reads,
	pln_stats.last_logical_io_reads,
	pln_stats.min_logical_io_reads,
	pln_stats.max_logical_io_reads,
	pln_stats.stdev_logical_io_reads,

	'Logical I/O Writes:' as Metric,
	pln_stats.avg_logical_io_writes,
	pln_stats.last_logical_io_writes,
	pln_stats.min_logical_io_writes,
	pln_stats.max_logical_io_writes,
	pln_stats.stdev_logical_io_writes,

	'Physical I/O Reads:' as Metric,
	pln_stats.avg_physical_io_reads,
	pln_stats.last_physical_io_reads,
	pln_stats.min_physical_io_reads,
	pln_stats.max_physical_io_reads,
	pln_stats.stdev_physical_io_reads,

	'CLR Time:' as Metric,
	cast(pln_stats.avg_clr_time * 1.0 / 1000000 as decimal(10, 3)) as avg_clr_time,
	cast(pln_stats.last_clr_time * 1.0 / 1000000 as decimal(10, 3)) as last_clr_time,
	cast(pln_stats.min_clr_time * 1.0 / 1000000 as decimal(10, 3)) as min_clr_time,
	cast(pln_stats.max_clr_time * 1.0 / 1000000 as decimal(10, 3)) as max_clr_time,
	cast(pln_stats.stdev_clr_time * 1.0 / 1000000 as decimal(10, 3)) as stdev_clr_time,

	'DOP:' as Metric,
	pln_stats.avg_dop,
	pln_stats.last_dop,
	pln_stats.min_dop,
	pln_stats.max_dop,
	pln_stats.stdev_dop,

	'Memory Used:' as Metric,
	cast(pln_stats.avg_query_max_used_memory * 8.0 / 1024 as decimal(10, 3)) as avg_query_max_used_memory_mb,
	cast(pln_stats.last_query_max_used_memory * 8.0 / 1024 as decimal(10, 3)) as last_query_max_used_memory_mb,
	cast(pln_stats.min_query_max_used_memory * 8.0 / 1024 as decimal(10, 3)) as min_query_max_used_memory_mb,
	cast(pln_stats.max_query_max_used_memory * 8.0 / 1024 as decimal(10, 3)) as max_query_max_used_memory_mb,
	cast(pln_stats.stdev_query_max_used_memory * 8.0 / 1024 as decimal(10, 3)) as stdev_query_max_used_memory_mb

from sys.query_store_runtime_stats as pln_stats
inner join sys.query_store_runtime_stats_interval as pln_stats_interval on pln_stats.runtime_stats_interval_id = pln_stats_interval.runtime_stats_interval_id
order by pln_stats.plan_id desc
go
