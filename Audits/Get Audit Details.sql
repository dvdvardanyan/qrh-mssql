use master
go

declare @audit_name nvarchar(521) = null;

------------------------------------------------------------------------------------

declare @show_audit_info bit = 1;
declare @show_audit_records bit = 1;
declare @show_all_records bit = 0;

------------------------------------------------------------------------------------

if(@show_audit_info = 1)
begin
	select
		AU.name as "Audit Name",
		AU.status_desc as "Audit Status",
		AU.audit_file_path as "Audit File Path",
		cast(AU.audit_file_size as decimal(18, 2)) / 1024 / 1024 as "Audit File Size (MB)"
	from sys.dm_server_audit_status as AU
	where @audit_name is null or AU.name = @audit_name
	order by AU.name
end

if(@show_audit_records = 1 and @audit_name is not null)
begin

	declare @audit_folder nvarchar(512);

	if(@show_all_records = 1)
	begin
		select
			@audit_folder = left(AU.audit_file_path, len(AU.audit_file_path) - charindex('\', reverse(AU.audit_file_path))) + '\*'
		from sys.dm_server_audit_status as AU where AU.name = @audit_name;
	end
	else
	begin
		select
			@audit_folder = AU.audit_file_path
		from sys.dm_server_audit_status as AU where AU.name = @audit_name;
	end

	select
		AF.event_time as "Event Time (UTC)",
		CLM.class_type_desc as "Class",
		AF.class_type as "Class Code",
		ACT.name as "Action",
		AF.action_id as "Action Code",
		ACT.containing_group_name as "Group",
		AF.server_instance_name as "Instance Name",
		AF.session_server_principal_name as "Session Principal",
		AF.server_principal_name as "Server Principal",
		AF.database_principal_name as "Database Principal",
		AF.database_name as "Database Name",
		AF.schema_name as "Schema Name",
		AF.object_name as "Object Name",
		AF.statement as "Statement",
		cast(AF.additional_information as xml) as "Additional Information",
		AF.file_name as "Audit File Name"
	from fn_get_audit_file(@audit_folder, default, default) as AF
	left outer join sys.dm_audit_class_type_map as CLM on AF.class_type = CLM.class_type
	left outer join sys.dm_audit_actions as ACT on AF.action_id = ACT.action_id and CLM.securable_class_desc = ACT.class_desc
	order by AF.event_time desc

end
go
