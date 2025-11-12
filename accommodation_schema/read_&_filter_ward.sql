use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('readorfilterWard','You are able to read or filter  wards')

-- permissions for particular roles
insert into users.Role_Permissions values
(106,154)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure accommodation.readorfilterWard
@staffroleId int, 
@departmentId int = null,
@wardType nvarchar(25) = null,
@readorfilter_Ward_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'readorfilterWard'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
				  where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can read or filter conditions')
				select 
					d.department_name as 'DEPARTMENT NAME',
					w.ward_number as 'WARD NUMBER',
					w.ward_type as 'WARD TYPE'
				from accommodation.Wards as w
				left join users.Department as d
				on w.department_id = d.department_id
				where 
				( @departmentId is null or w.department_id = @departmentId ) and
				( @wardType is null or w.ward_type like '%' + @wardType + '%') and
				w.is_deleted != 1;
			end
		else
			begin
				set @readorfilter_Ward_message = 'cannot read or filter wards';
				print 'You can not read or filter wards';
			end
	end try
	begin catch
		set @readorfilter_Ward_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING GETTING A WARD';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

go

-- trying it out
declare @result nvarchar(max);
exec accommodation.readorfilterWard
@staffroleId = 106,
@departmentId = null,
@wardType = null,
@readorfilter_Ward_message = @result output;

print 'Result: ' + @result;




select 
	d.department_name as 'DEPARTMENT NAME',
	w.ward_number as 'WARD NUMBER',
	w.ward_type as 'WARD TYPE'
from accommodation.Wards as w
left join users.Department as d
on w.department_id = d.department_id




