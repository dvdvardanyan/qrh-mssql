--> https://littlekendra.com/2016/10/17/decoding-key-and-page-waitresource-for-deadlocks-and-blocking/

--> KEY:DatabaseID:HOBTID(HASH)

select DB_NAME([DatabaseID]) as "Database Name"
go

use [DATABASE_NAME]
go

select 
    sc.name as "Schema Name",
    so.name as "Object Name",
    si.name as "Index Name"
from sys.partitions as p
inner join sys.objects as so on p.object_id=so.object_id
inner join sys.indexes as si on p.index_id=si.index_id and p.object_id=si.object_id
inner join sys.schemas as sc on so.schema_id=sc.schema_id
where hobt_id = [HOBTID]
go

select *
from [TABLE_NAME] with (nolock)
where %%lockres%% = '(HASH)';
GO

--> PAGE:DatabaseID:FileID:PageID

select DB_NAME([DatabaseID]) as "Database Name"
go

use [DATABASE_NAME]
go

select
	df.name,
	df.physical_name
from sys.database_files as df where df.file_id = [FileID]
go

dbcc traceon(3604)
go

dbcc page('[DATABASE_NAME]', FileID, PageID, 2)
go

select 
    sc.name as schema_name, 
    so.name as object_name, 
    si.name as index_name
from sys.objects as so 
inner join sys.indexes as si on so.object_id=si.object_id
inner join sys.schemas AS sc on so.schema_id=sc.schema_id
WHERE so.object_id = [OBJECT_ID] and si.index_id = [INDEX_ID];
GO