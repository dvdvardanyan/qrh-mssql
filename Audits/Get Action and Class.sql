/* SOURCE: https://blogs.msdn.microsoft.com/sqlsecurity/2012/10/03/filter-sql-server-audit-on-action_id-class_type-predicate/ */

use master
go

declare @action_id varchar(4) = null;
declare @class_type varchar(2) = null;

----------------------------------------------------------------------------------------------

declare @x int;

if(@class_type is not null)
begin

	SET @x = convert(int, convert(varbinary(1), upper(substring(@class_type, 1, 1))));

	if LEN(@class_type)>=2
	begin
		SET @x = convert(int, convert(varbinary(1), upper(substring(@class_type, 2, 1)))) * power(2,8) + @x;
	end
	else
	begin
		SET @x = convert(int, convert(varbinary(1), ' ')) * power(2,8) + @x;
	end

	select @x as class_type;

end

if(@action_id is not null)
begin

	SET @x = convert(int, convert(varbinary(1), upper(substring(@action_id, 1, 1))));

	if LEN(@action_id) >= 2
	begin
		SET @x = convert(int, convert(varbinary(1), upper(substring(@action_id, 2, 1)))) * power(2,8) + @x;
	end
	else
	begin
		SET @x = convert(int, convert(varbinary(1), ' ')) * power(2,8) + @x;
	end

	if LEN(@action_id) >= 3
	begin
		SET @x = convert(int, convert(varbinary(1), upper(substring(@action_id, 3, 1)))) * power(2,16) + @x;
	end
	else
	begin
		SET @x = convert(int, convert(varbinary(1), ' ')) * power(2,16) + @x;
	end

	if LEN(@action_id) >= 4
	begin
		SET @x = convert(int, convert(varbinary(1), upper(substring(@action_id, 4, 1)))) * power(2,24) + @x;
	end
	else
	begin
		SET @x = convert(int, convert(varbinary(1), ' ')) * power(2,24) + @x;
	end

	select @x as action_id;

end
go
