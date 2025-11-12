use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('readorfilterDepartments','You are able to read or filter  departments')

-- permissions for particular roles
insert into users.Role_Permissions values
(101,118)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

-- readorfilter users stored procedure
create or alter procedure users.readorfilterDepartments
@staffroleId int, 
@department_name nvarchar(35) = null, @department_description nvarchar(100) = null,
@readorfilter_dept_message nvarchar(max) output
with encryption
as
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'readorfilterDepartments'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
					where role_id = @staffroleId and permission_id = @permmissionId)
			begin
				print('You can read or filter departments')
				select 
					department_name as 'ROLE NAME',
					department_description as 'ROLE DESCRIPTION'
				from users.Department
				where
				( @department_name is null or department_name like '%' + @department_name + '%') and
				( @department_description is null or department_description like '%' + @department_description + '%') and
				is_deleted != 1;
			end
		else
			begin
				set @readorfilter_dept_message = 'cannot read or filter departments';
				print 'You can not read or filter departments';
			end
	end try
	begin catch
		set @readorfilter_dept_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING READING OR FILTERING A DEPARTMENT';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

-- trying it out
declare @result nvarchar(max);

exec users.readorfilterDepartments 
@staffroleId = 101, 
-- @department_name = 'Doctors', @department_description = 'treat patients',
@readorfilter_dept_message = @result output;

print 'Result: ' + @result;
