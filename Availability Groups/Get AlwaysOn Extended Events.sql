use master
go

declare @ExFilePath varchar(max);

select @ExFilePath = cast(ssn_trg.target_data as xml).value('(EventFileTarget/File/@name)[1]', 'varchar(1024)')
from sys.dm_xe_sessions as ssn
inner join sys.dm_xe_session_targets as ssn_trg on ssn.address = ssn_trg.event_session_address
where ssn.name = 'AlwaysOn_health' and ssn_trg.target_name = 'event_file';

select
	object_name,
	cast(event_data as xml) as event_data
from sys.fn_xe_file_target_read_file(@ExFilePath, null, null, null)
go
