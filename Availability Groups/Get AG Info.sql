use master
go

declare @AGName varchar(128) = null;

declare @ShowUnhealthyOnly bit = 0;

declare @ShowReplicas bit = 1;
declare @ShowDatabases bit = 1;
declare @ShowExHistory bit = 0;

------------------------------------------------------------------------------------------------------------------------

declare @AGGroupId uniqueidentifier;

if(@AGName is not null)
begin
	select @AGGroupId = AG.group_id from sys.availability_groups as AG where AG.name = @AGName;
end

select
	AG.group_id
	, AG.name as "AG Name"
	, AGL.dns_name as "DNS"
	, '(' + cast(AGS.primary_recovery_health as varchar(30)) + ') ' + AGS.primary_recovery_health_desc as "Primary Recovery Health"
	, '(' + cast(AGS.secondary_recovery_health as varchar(30)) + ') ' + AGS.secondary_recovery_health_desc as "Secondary Recovery Health"
	, '(' + cast(AGS.synchronization_health as varchar(30)) + ') ' + AGS.synchronization_health_desc as "Synchronization Health"
	, AGL.port as "Port"
	--, AG.resource_id
	--, AG.resource_group_id
	, case
		when AG.failure_condition_level = 1 then '(1) The SQL Server service is down'
		when AG.failure_condition_level = 2 then '(2) Health check timeout threshold'
		when AG.failure_condition_level = 3 then '(3) Critical SQL server internal errors'
		when AG.failure_condition_level = 4 then '(4) Moderate SQL Server internal errors'
		when AG.failure_condition_level = 5 then '(5) Qualified failure conditions'
	end as "Failure Condition Level"
	, AG.health_check_timeout
	, '(' + cast(AG.automated_backup_preference as varchar(30)) + ') ' + AG.automated_backup_preference_desc as "Backup Preference"
	, AGL.ip_configuration_string_from_cluster as "Cluster IP Configuration"
	, cast((select
			AGLIP.ip_address as "IP"
			, AGLIP.ip_subnet_mask as "SubnetMask"
			, iif(AGLIP.is_dhcp = 1, 'Yes', 'No') as "IsDHCP"
			, AGLIP.network_subnet_ip as "NetworkSubnetIP"
			, AGLIP.network_subnet_prefix_length as "NetworkSubnetPrefixLength"
			, AGLIP.network_subnet_ipv4_mask as "NetworkSubnetIPv4Mask"
			, AGLIP.state_desc as "State"
		from sys.availability_group_listener_ip_addresses as AGLIP
		where AGL.listener_id = AGLIP.listener_id
		for xml path('IPConfiguration'), root('Configuration')) as xml) as "Cluster IP Configuration Detail"
	, iif(AGL.is_conformant = 1, 'Yes', 'No') as "Is Conformant"
from sys.availability_groups as AG
left outer join sys.availability_group_listeners as AGL on AG.group_id = AGL.group_id
left outer join sys.dm_hadr_availability_group_states as AGS on AG.group_id = AGS.group_id
where (@AGGroupId is null or AG.group_id = @AGGroupId);

if(@AGGroupId is not null and @ShowReplicas = 1)
begin

	select
		AGR.replica_server_name as "Server Name"
		, '(' + cast(RSS.role as varchar(30)) + ') ' + RSS.role_desc as "Server Role"
		, '(' + cast(RSS.operational_state as varchar(30)) + ') ' + RSS.operational_state_desc as "Operational State"
		, '(' + cast(RSS.connected_state as varchar(30)) + ') ' + RSS.connected_state_desc as "Connection State"
		, '(' + cast(RSS.recovery_health as varchar(30)) + ') ' + RSS.recovery_health_desc as "Recovery State"
		, '(' + cast(RSS.synchronization_health as varchar(30)) + ') ' + RSS.synchronization_health_desc as "Synchronization State"
		, '(' + cast(RSS.last_connect_error_number as varchar(30)) + ') ' + RSS.last_connect_error_description as "Last Connection Error"
		, AGR.endpoint_url as "Endpoint Url"
		, AGR.read_only_routing_url as "Read Only Routing URL"
		, cast((
			select ARORL.routing_priority as "ServerName/@priority", RAGR.replica_server_name as ServerName
			from sys.availability_read_only_routing_lists as ARORL
			inner join sys.availability_replicas as RAGR on ARORL.read_only_replica_id = RAGR.replica_id
			where AGR.replica_id = ARORL.replica_id
			order by ARORL.routing_priority
			for xml path(''), root('Routing')
		) as xml) as "Read Only Routing Configuration"
		, '(' + cast(AGR.availability_mode as varchar(30)) + ') ' + AGR.availability_mode_desc as "Availability Mode"
		, '(' + cast(AGR.failover_mode as varchar(30)) + ') ' + AGR.failover_mode_desc as "Failover Mode"
		, AGR.session_timeout as "Session Timeout"
		, '(' + cast(AGR.primary_role_allow_connections as varchar(30)) + ') ' + AGR.primary_role_allow_connections_desc as "Allow Connections to Primary"
		, '(' + cast(AGR.secondary_role_allow_connections as varchar(30)) + ') ' + AGR.secondary_role_allow_connections_desc as "Allow Connections to Secondary"
		, backup_priority as "Backup Priority"
	from sys.availability_replicas as AGR
	left outer join sys.dm_hadr_availability_replica_states as RSS on AGR.replica_id = RSS.replica_id and AGR.group_id = RSS.group_id
	where AGR.group_id = @AGGroupId and (@ShowUnhealthyOnly = 0 or RSS.synchronization_health <> 2)

end

if(@AGGroupId is not null and @ShowDatabases = 1)
begin

	declare @sql varchar(max) = 'select'
	set @sql = @sql + char(13) + char(10) + 'DB.Name as "Database Name"'
	set @sql = @sql + char(13) + char(10) + ', DB.state_desc as "Database State"'

	select @sql = @sql + char(13) + char(10) +
		+ ', max(iif(AGR.replica_id = ''' + cast(AGR.replica_id as varchar(36)) + ''', DBRS.synchronization_health_desc + '' / '' + DBRS.synchronization_state_desc, null)) as "' + AGR.replica_server_name + ' (' + isnull(RSS.role_desc, 'Unknown') + ')"'
		+ char(13) + char(10)
		+ ', max(iif(AGR.replica_id = ''' + cast(AGR.replica_id as varchar(36)) + ''', cast(DBRS.log_send_queue_size / 1024 as varchar(30)) + '' MB ('' + cast(DBRS.log_send_rate / 1024 as varchar(30)) + '' MB/s)'', null)) as "Data to Send (Rate)"'
		+ char(13) + char(10)
		+ ', max(iif(AGR.replica_id = ''' + cast(AGR.replica_id as varchar(36)) + ''', cast(DBRS.redo_queue_size / 1024 as varchar(30)) + '' MB ('' + cast(DBRS.redo_rate / 1024 as varchar(30)) + '' MB/s)'', null)) as "Data to Redo (Rate)"'
		+ char(13) + char(10)
		+ ', max(iif(AGR.replica_id = ''' + cast(AGR.replica_id as varchar(36)) + ''', case when DBRS.is_suspended = 0 then ''Resumed'' when DBRS.is_suspended = 1 then ''Suspended'' end, null)) as "Status"'
	from sys.availability_replicas as AGR
	left outer join sys.dm_hadr_availability_replica_states as RSS on AGR.replica_id = RSS.replica_id and AGR.group_id = RSS.group_id
	where AGR.group_id = @AGGroupId
	order by RSS.role

	set @sql = @sql + char(13) + char(10) + 'from sys.databases as DB'
	set @sql = @sql + char(13) + char(10) + 'left outer join sys.dm_hadr_database_replica_states as DBRS on DB.database_id = DBRS.database_id'
	set @sql = @sql + char(13) + char(10) + 'left outer join sys.availability_replicas as AGR on DBRS.replica_id = AGR.replica_id'
	set @sql = @sql + char(13) + char(10) + 'where DB.name not in (''master'', ''tempdb'', ''model'', ''msdb'') and (DBRS.group_id is null or DBRS.group_id = ''' + cast(@AGGroupId as varchar(36)) + ''')' + iif(@ShowUnhealthyOnly = 1, 'and DBRS.synchronization_health <> 2', '')
	set @sql = @sql + char(13) + char(10) + 'group by DB.Name, DB.state_desc'
	set @sql = @sql + char(13) + char(10) + 'order by DB.name'

	exec(@sql)

end

if(@ShowExHistory = 1)
begin

	declare @ExFilePath varchar(max);

	select @ExFilePath = cast(ssn_trg.target_data as xml).value('(EventFileTarget/File/@name)[1]', 'varchar(1024)')
	from sys.dm_xe_sessions as ssn
	inner join sys.dm_xe_session_targets as ssn_trg on ssn.address = ssn_trg.event_session_address
	where ssn.name = 'AlwaysOn_health' and ssn_trg.target_name = 'event_file';

	select object_name, cast(event_data as xml) as event_data
	from sys.fn_xe_file_target_read_file(@ExFilePath, null, null, null)

end