use msdb
go

set xact_abort on;

begin transaction -- commit -- rollback

declare @operator_name sysname = 'SQLDBA';

declare @alert_name sysname;

if(exists(select * from sysoperators where name = @operator_name))
begin

	set @alert_name = 'Error 1480 - AlwaysOn Role Change';

	if(not exists (select * from msdb.dbo.sysalerts where name = @alert_name))
	begin
		exec msdb.dbo.sp_add_alert @name=@alert_name, @message_id=1480, @severity=0, @enabled=1, @delay_between_responses=0, @include_event_description_in=1, @job_id=N'00000000-0000-0000-0000-000000000000';
		exec msdb.dbo.sp_add_notification @alert_name=@alert_name, @operator_name=@operator_name, @notification_method = 1;
		print(char(13) + char(10) + 'Created alert "' + @alert_name + '".');
	end
	else
	begin
		print(char(13) + char(10) + 'X - Alert "' + @alert_name + '" already exists.');
	end
	
	set @alert_name = 'Error 35264 - AlwaysOn Data Movement Suspended';

	if(not exists (select * from msdb.dbo.sysalerts where name = @alert_name))
	begin
		exec msdb.dbo.sp_add_alert @name=@alert_name, @message_id=35264, @severity=0, @enabled=1, @delay_between_responses=0, @include_event_description_in=1, @job_id=N'00000000-0000-0000-0000-000000000000';
		exec msdb.dbo.sp_add_notification @alert_name=@alert_name, @operator_name=@operator_name, @notification_method = 1;
		print(char(13) + char(10) + 'Created alert "' + @alert_name + '".');
	end
	else
	begin
		print(char(13) + char(10) + 'X - Alert "' + @alert_name + '" already exists.');
	end
	
	set @alert_name = 'Error 35265 - AlwaysOn Data Movement Resumed';

	if(not exists (select * from msdb.dbo.sysalerts where name = @alert_name))
	begin
		exec msdb.dbo.sp_add_alert @name=@alert_name, @message_id=35265, @severity=0, @enabled=1, @delay_between_responses=0, @include_event_description_in=1, @job_id=N'00000000-0000-0000-0000-000000000000';
		exec msdb.dbo.sp_add_notification @alert_name=@alert_name, @operator_name=@operator_name, @notification_method = 1;
		print(char(13) + char(10) + 'Created alert "' + @alert_name + '".');
	end
	else
	begin
		print(char(13) + char(10) + 'X - Alert "' + @alert_name + '" already exists.');
	end

	/*
	
	set @alert_name = 'Error 976 - AlwaysOn Database not Accessible';

	if(not exists (select * from msdb.dbo.sysalerts where name = @alert_name))
	begin
		exec msdb.dbo.sp_add_alert @name=@alert_name, @message_id=976, @severity=0, @enabled=1, @delay_between_responses=0, @include_event_description_in=1, @job_id=N'00000000-0000-0000-0000-000000000000';
		exec msdb.dbo.sp_add_notification @alert_name=@alert_name, @operator_name=@operator_name, @notification_method = 1;
		print(char(13) + char(10) + 'Created alert "' + @alert_name + '".');
	end
	else
	begin
		print(char(13) + char(10) + 'X - Alert "' + @alert_name + '" already exists.');
	end
	
	set @alert_name = 'Error 19406 - AlwaysOn Replica Change State';

	if(not exists (select * from msdb.dbo.sysalerts where name = @alert_name))
	begin
		exec msdb.dbo.sp_add_alert @name=@alert_name, @message_id=19406, @severity=0, @enabled=1, @delay_between_responses=0, @include_event_description_in=1, @job_id=N'00000000-0000-0000-0000-000000000000';
		exec msdb.dbo.sp_add_notification @alert_name=@alert_name, @operator_name=@operator_name, @notification_method = 1;
		print(char(13) + char(10) + 'Created alert "' + @alert_name + '".');
	end
	else
	begin
		print(char(13) + char(10) + 'X - Alert "' + @alert_name + '" already exists.');
	end
	
	set @alert_name = 'Error 35206 - AlwaysOn Connection Timeout';

	if(not exists (select * from msdb.dbo.sysalerts where name = @alert_name))
	begin
		exec msdb.dbo.sp_add_alert @name=@alert_name, @message_id=35206, @severity=0, @enabled=1, @delay_between_responses=0, @include_event_description_in=1, @job_id=N'00000000-0000-0000-0000-000000000000';
		exec msdb.dbo.sp_add_notification @alert_name=@alert_name, @operator_name=@operator_name, @notification_method = 1;
		print(char(13) + char(10) + 'Created alert "' + @alert_name + '".');
	end
	else
	begin
		print(char(13) + char(10) + 'X - Alert "' + @alert_name + '" already exists.');
	end

	*/

end
go
