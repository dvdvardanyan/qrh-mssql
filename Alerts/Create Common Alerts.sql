use msdb
go

set xact_abort on;

begin transaction -- commit -- rollback

declare @operator_name sysname = 'SQLDBA';

declare @alert_name sysname;

if(exists(select * from sysoperators where name = @operator_name))
begin

	--> Severity 19

	set @alert_name = 'Severity 19 - Fatal Error in Resource';

	if(not exists (select * from msdb.dbo.sysalerts where name = @alert_name))
	begin
		exec msdb.dbo.sp_add_alert @name=@alert_name, @message_id=0, @severity=19, @enabled=1, @delay_between_responses=900, @include_event_description_in=1, @job_id=N'00000000-0000-0000-0000-000000000000';
		exec msdb.dbo.sp_add_notification @alert_name=@alert_name, @operator_name=@operator_name, @notification_method = 1;
		print(char(13) + char(10) + 'Created alert "' + @alert_name + '".');
	end
	else
	begin
		print(char(13) + char(10) + 'X - Alert "' + @alert_name + '" already exists.');
	end

	--> Severity 20

	set @alert_name = 'Severity 20 - Fatal Error in Current Process';

	if(not exists (select * from msdb.dbo.sysalerts where name = @alert_name))
	begin
		exec msdb.dbo.sp_add_alert @name=@alert_name, @message_id=0, @severity=20, @enabled=1, @delay_between_responses=900, @include_event_description_in=1, @job_id=N'00000000-0000-0000-0000-000000000000';
		exec msdb.dbo.sp_add_notification @alert_name=@alert_name, @operator_name=@operator_name, @notification_method = 1;
		print(char(13) + char(10) + 'Created alert "' + @alert_name + '".');
	end
	else
	begin
		print(char(13) + char(10) + 'X - Alert "' + @alert_name + '" already exists.');
	end
	
	--> Severity 21

	set @alert_name = 'Severity 21 - Fatal Error in Database Process';

	if(not exists (select * from msdb.dbo.sysalerts where name = @alert_name))
	begin
		exec msdb.dbo.sp_add_alert @name=@alert_name, @message_id=0, @severity=21, @enabled=1, @delay_between_responses=900, @include_event_description_in=1, @job_id=N'00000000-0000-0000-0000-000000000000';
		exec msdb.dbo.sp_add_notification @alert_name=@alert_name, @operator_name=@operator_name, @notification_method = 1;
		print(char(13) + char(10) + 'Created alert "' + @alert_name + '".');
	end
	else
	begin
		print(char(13) + char(10) + 'X - Alert "' + @alert_name + '" already exists.');
	end
	
	--> Severity 22

	set @alert_name = 'Severity 22 - Table Integrity Suspect';

	if(not exists (select * from msdb.dbo.sysalerts where name = @alert_name))
	begin
		exec msdb.dbo.sp_add_alert @name=@alert_name, @message_id=0, @severity=22, @enabled=1, @delay_between_responses=900, @include_event_description_in=1, @job_id=N'00000000-0000-0000-0000-000000000000';
		exec msdb.dbo.sp_add_notification @alert_name=@alert_name, @operator_name=@operator_name, @notification_method = 1;
		print(char(13) + char(10) + 'Created alert "' + @alert_name + '".');
	end
	else
	begin
		print(char(13) + char(10) + 'X - Alert "' + @alert_name + '" already exists.');
	end

	--> Severity 23

	set @alert_name = 'Severity 23 - Database Integrity Suspect';

	if(not exists (select * from msdb.dbo.sysalerts where name = @alert_name))
	begin
		exec msdb.dbo.sp_add_alert @name=@alert_name, @message_id=0, @severity=23, @enabled=1, @delay_between_responses=900, @include_event_description_in=1, @job_id=N'00000000-0000-0000-0000-000000000000';
		exec msdb.dbo.sp_add_notification @alert_name=@alert_name, @operator_name=@operator_name, @notification_method = 1;
		print(char(13) + char(10) + 'Created alert "' + @alert_name + '".');
	end
	else
	begin
		print(char(13) + char(10) + 'X - Alert "' + @alert_name + '" already exists.');
	end

	--> Severity 24

	set @alert_name = 'Severity 24 - Fatal Hardware Error';

	if(not exists (select * from msdb.dbo.sysalerts where name = @alert_name))
	begin
		exec msdb.dbo.sp_add_alert @name=@alert_name, @message_id=0, @severity=24, @enabled=1, @delay_between_responses=900, @include_event_description_in=1, @job_id=N'00000000-0000-0000-0000-000000000000';
		exec msdb.dbo.sp_add_notification @alert_name=@alert_name, @operator_name=@operator_name, @notification_method = 1;
		print(char(13) + char(10) + 'Created alert "' + @alert_name + '".');
	end
	else
	begin
		print(char(13) + char(10) + 'X - Alert "' + @alert_name + '" already exists.');
	end

	--> Severity 25

	set @alert_name = 'Severity 25 - Fatal Error';

	if(not exists (select * from msdb.dbo.sysalerts where name = @alert_name))
	begin
		exec msdb.dbo.sp_add_alert @name=@alert_name, @message_id=0, @severity=25, @enabled=1, @delay_between_responses=900, @include_event_description_in=1, @job_id=N'00000000-0000-0000-0000-000000000000';
		exec msdb.dbo.sp_add_notification @alert_name=@alert_name, @operator_name=@operator_name, @notification_method = 1;
		print(char(13) + char(10) + 'Created alert "' + @alert_name + '".');
	end
	else
	begin
		print(char(13) + char(10) + 'X - Alert "' + @alert_name + '" already exists.');
	end

	--> Error 825 - IO error, Sql server read the data but not with first attempt after trying couple of attempts (max 4).

	set @alert_name = 'Error 825 - Read-Retry Required';

	if(not exists (select * from msdb.dbo.sysalerts where name = @alert_name))
	begin
		exec msdb.dbo.sp_add_alert @name=@alert_name, @message_id=825, @severity=0, @enabled=1, @delay_between_responses=900, @include_event_description_in=1, @job_id=N'00000000-0000-0000-0000-000000000000';
		exec msdb.dbo.sp_add_notification @alert_name=@alert_name, @operator_name=@operator_name, @notification_method = 1;
		print(char(13) + char(10) + 'Created alert "' + @alert_name + '".');
	end
	else
	begin
		print(char(13) + char(10) + 'X - Alert "' + @alert_name + '" already exists.');
	end

	--> Error 832 - Memory Error, Sql server read data in memory but due to memory problem data is lost/corrupt in memory.

	set @alert_name = 'Error 832 - Page Checksum Memory Error';

	if(not exists (select * from msdb.dbo.sysalerts where name = @alert_name))
	begin
		exec msdb.dbo.sp_add_alert @name=@alert_name, @message_id=832, @severity=0, @enabled=1, @delay_between_responses=900, @include_event_description_in=1, @job_id=N'00000000-0000-0000-0000-000000000000';
		exec msdb.dbo.sp_add_notification @alert_name=@alert_name, @operator_name=@operator_name, @notification_method = 1;
		print(char(13) + char(10) + 'Created alert "' + @alert_name + '".');
	end
	else
	begin
		print(char(13) + char(10) + 'X - Alert "' + @alert_name + '" already exists.');
	end

	--> Error 9002 - Transaction log is full.

	/*

	set @alert_name = 'Error 9002 - Transaction log is full';

	if(not exists (select * from msdb.dbo.sysalerts where name = @alert_name))
	begin
		exec msdb.dbo.sp_add_alert @name=@alert_name, @message_id=9002, @severity=0, @enabled=1, @delay_between_responses=900, @include_event_description_in=1, @job_id=N'00000000-0000-0000-0000-000000000000';
		exec msdb.dbo.sp_add_notification @alert_name=@alert_name, @operator_name=@operator_name, @notification_method = 1;
		print(char(13) + char(10) + 'Created alert "' + @alert_name + '".');
	end
	else
	begin
		print(char(13) + char(10) + 'X - Alert "' + @alert_name + '" already exists.');
	end

	*/

end
else
begin
	declare @message varchar(300) = 'Operator "' + @operator_name + '" does not exist.';
	raiserror(@message, 16, 1);
end
go
