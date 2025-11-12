use HospitalERp;

-- dummy data
-- system roles
insert into users.Roles values
('admin','top guy');

-- system Permissions
insert into users.Permissions values
('deleteRolePermission','You are able to delete a Permission from a role')

-- permissions for particular roles
insert into users.Role_Permissions values
(101,115)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

create or alter procedure users.deleteRolePermission
@staffroleId int, @roleId int, @permissionId int,
@delete_role_permission_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'deleteRolePermission'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
					where role_id = @staffroleId and permission_id = @permmissionId)
			begin
				print('You can delete a Permission from a Role')
				if exists(select * from users.Role_Permissions
					where role_id = @roleId and permission_id = @permissionId)
					begin
						delete from users.Role_Permissions						
						where
							role_id = @roleId and permission_id = @permissionId

						set @delete_role_permission_message = 'permission deleted from role';
						print '=====================================================';
						print 'permission deleted from role';
					end
				else
					begin
						set @delete_role_permission_message = 'permission to role dont exist';
					end
			end
		else
			begin
				set @delete_role_permission_message = 'cannot delete permission from role';
				print 'You can not delete permission from role';
			end
	end try
	begin catch
		set @delete_role_permission_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING DELETING PERMISSION FROM A ROLE';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

-- trying it out
declare @result nvarchar(max);

exec users.deleteRolePermission 
@staffroleId = 101,  
@roleId = 100, @permissionId = 114,
@delete_role_permission_message = @result output;

print 'Result: ' + @result;

select * from users.Roles






















