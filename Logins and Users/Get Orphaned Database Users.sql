use [TARGET_DATABASE]
go

select dp.name, sp.name, 'alter user [' + dp.name + '] with login = [' + dp.name + ']'
from sys.database_principals as dp
left outer join sys.server_principals as sp on dp.sid = sp.sid
where sp.sid is null and dp.type = 'S' and dp.sid is not null and dp.sid <> 0x00
go

select
	dp.name as UserName
	, dp.type_desc as UserType
	, dp.sid as UserSID
	, sp.name as LoginName
	, sp.type_desc as LoginType
	, sp.sid as LoginSID
	, sp.name as LoginName
from sys.database_principals as dp
left outer join sys.server_principals as sp on dp.name = sp.name
where dp.type = 'S' and dp.name not in ('dbo','guest','INFORMATION_SCHEMA','sys')
go

