use master
go

/*

INFO:

--> Physical Memory -------------------------------------------------------------------------------------------------------------

If total is >= 16 GB -> reserve additional 4 GB + 1 GB for every 8 GB above 16 GB for OS.
If total is > 4 GB and <= 16 GB -> reserve 1 GB for every 4 GB for OS.

--> Workers --------------------------------------------------------------------------------------------------------------------

For 32 bit operating system:

Total available logical CPU’s <= 4 : max worker threads = 256 
Total available logical CPU’s > 4 : max worker threads = 256 + ((logical CPUS’s - 4) * 8)

For 64 bit operating system:

Total available logical CPU’s <= 4 : max worker threads = 512 
Total available logical CPU’s > 4 : max worker threads = 512 + ((logical CPUS’s - 4) * 16)

*/

--> Other info

select @@VERSION as "SQL Version"

select distinct
	@@SERVERNAME as "Server Name",
	local_net_address as "Server IP",
	local_tcp_port as "Server Port"
from sys.dm_exec_connections as con

--> Services info

select
	svc.servicename as "Name",
	svc.startup_type_desc as "Startup Mode",
	svc.status_desc as "Status",
	svc.process_id as "Process Id",
	svc.service_account as "Service Account"
from sys.dm_server_services as svc

--> CPU and Memory info

declare @min_server_memory sql_variant;
select @min_server_memory = config.value_in_use
from sys.configurations as config where name = 'min server memory (MB)';

declare @max_server_memory sql_variant;
select @max_server_memory = config.value_in_use
from sys.configurations as config where name = 'max server memory (MB)';

with SystemInfo as
(
	select
		info.physical_memory_kb / 1024 as physical_memory_mb,
		info.virtual_memory_kb / 1024 as virtual_memory_mb,
		info.max_workers_count,
		info.cpu_count
	from sys.dm_os_sys_info as info
)
, SystemInfoCalculated as
(
	select
		SI.physical_memory_mb
		, @min_server_memory as sql_min_server_memory
		, @max_server_memory as sql_max_server_memory
		, sql_recommended_max_memory_mb = SI.physical_memory_mb - 1024 - case
			when SI.physical_memory_mb >= 16384 then 4092
			when SI.physical_memory_mb > 4092 and SI.physical_memory_mb < 16384 then SI.physical_memory_mb / 4
			else 0
		end - iif(SI.physical_memory_mb > 16384, (SI.physical_memory_mb - 16384) / 8, 0)
		, SI.max_workers_count
		, SI.cpu_count
	from SystemInfo as SI
)
select
	SIC.cpu_count as "CPU Count"
	, SIC.physical_memory_mb as "Physical Memory (MB)"
	, (select physical_memory_in_use_kb / 1024 from sys.dm_os_process_memory) as "Physical Memory in Use (MB)"
	, SIC.sql_min_server_memory as "Min SQL Server Memory (MB)"
	, cast(SIC.sql_max_server_memory as varchar(30)) + ' / ' + cast(SIC.sql_recommended_max_memory_mb as varchar(30)) as "Max SQL Server Memory (Actual / Recommended) (MB)"
	, SIC.max_workers_count as "Max Workers Count"
	, (select count(*) from sys.dm_os_workers) as "Workers Count"
	, (select count(*) from sys.dm_os_schedulers) as "Schedulers Count"
from SystemInfoCalculated as SIC
go
