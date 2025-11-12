use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('updateDepartment','You are able to update a department')

-- permissions for particular roles
insert into users.Role_Permissions values
(101,117)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

-- update users stored procedure
create or alter procedure users.updateDepartment
@staffroleId int, @departmentId int,
@department_name nvarchar(35) = null,@department_description nvarchar(100) = null,
@Deleted bit = null,
@update_department_message nvarchar(max) output
with encryption
as
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'updateDepartment'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
					where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can update a department')
				if exists(select * from users.Department where department_id = @departmentId and is_deleted != 1)
					begin
						update users.Department
						set
							department_name = isnull(@department_name, department_name),
							department_description = isnull(@department_description, department_description),
							is_deleted = isnull(@Deleted, is_deleted),
							updated_at = getdate()
						where
							department_id = @departmentId and is_deleted != 1
						set @update_department_message = 'department updated';
						print '=====================================================';
						print 'Department: '+@department_name+' updated successfully';
					end
				else
					begin
						set @update_department_message = 'Department dont exist';
					end
			end
		else
			begin
				set @update_department_message = 'cannot update department';
				print 'You can not update a department';
			end
	end try
	begin catch
		set @update_department_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING UPDATING A DEPARTMENT';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end


-- trying it out
declare @result nvarchar(max);

exec users.updateDepartment 
@staffroleId = 101,  @departmentId = 100,
@department_name = 'heart', @department_description = 'treat hearts',
@update_department_message = @result output;

print 'Result: ' + @result;

select * from users.Department