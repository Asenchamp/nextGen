use HospitalERp;

-- system Permissions
insert into users.Permissions (permission_name, permission_description) values
('updateRole','You are able to update a role')

-- permissions for particular roles
insert into users.Role_Permissions values
(101,110)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

-- update users stored procedure
create or alter procedure users.updateRole
@staffroleId int, @roleId int,
@rolename nvarchar(35) = null,@roledescription nvarchar(100) = null,
@Deleted bit = null,
@update_role_message nvarchar(max) output
with encryption
as
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'updateRole'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
					where role_id = @staffroleId and permission_id = @permmissionId)
			begin
				print('You can update a role')
				if exists(select * from users.Roles where role_id = @roleId and is_deleted != 1)
					begin
						update users.Roles
						set
							role_name = isnull(@rolename, role_name),
							role_description = isnull(@roledescription, role_description),
							is_deleted = isnull(@Deleted, is_deleted),
							updated_at = getdate()
						where
							role_id = @roleId and is_deleted != 1
						set @update_role_message = 'role updated';
						print '=====================================================';
						print 'Role: '+@rolename+' updated successfully';
					end
				else
					begin
						set @update_role_message = 'role dont exist';
					end
			end
		else
			begin
				set @update_role_message = 'cannot update role';
				print 'You can not update a role';
			end
	end try
	begin catch
		set @update_role_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING UPDATING A ROLE';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end


-- trying it out
declare @result nvarchar(max);

exec users.updateRole 
@staffroleId = 101,  @roleId = 103,
@rolename = 'Doctors', @roledescription = 'treat patients',
@update_role_message = @result output;

print 'Result: ' + @result;

select * from users.Roles