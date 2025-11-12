use HospitalERp;

-- dummy data
-- system roles
insert into users.Roles values
('admin','top guy');

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('createDepartment','You are able to add a department')

-- permissions for particular roles
insert into users.Role_Permissions values
(101,116)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure users.createDepartment
@staffroleId int, 
@department_name nvarchar(35),@department_description nvarchar(100),
@create_dept_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'createDepartment'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
					where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can add a Department')
				insert into users.Department
				(department_name,department_description)
				values
				(@department_name,@department_description)
				set @create_dept_message = 'Department added';
				print '=====================================================';
				print 'Department: '+@department_name+' added successfully';
			end
		else
			begin
				set @create_dept_message = 'cannot add Department';
				print 'You can not add a Department';
			end
	end try
	begin catch
		set @create_dept_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING ADDING A DEPARTMENT';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

-- trying it out
declare @result nvarchar(max);

exec users.createDepartment 
@staffroleId = 101,  
@department_name = 'Heart', @department_description = 'treat heart',
@create_dept_message = @result output;

print 'Result: ' + @result;

select * from users.Department






















