use HospitalERp;

-- dummy data
-- system roles
insert into users.Roles values
('admin','top guy');

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('createRolePermission','You are able to add a permission to a role')

-- permissions for particular roles
insert into users.Role_Permissions values
(101,113)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure users.createRolePermission
@staffroleId int, 
@roleId int, @permissionId int,
@create_role_permission_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'createRolePermission'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
					where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				if exists(select * from users.Roles where role_id = @roleId) and
				   exists(select * from users.Permissions where permission_id = @permissionId) 
				   begin
						print('You can add a Permission to a Role')
						insert into users.Role_Permissions
						(role_id,permission_id)
						values
						(@roleId,@permissionId)
						set @create_role_permission_message = 'permission added to role';
						print '=====================================================';
						print 'Permission added to Role successfully';					
				   end
				else
					begin
						set @create_role_permission_message = 'Either permission or role dont exist';
						print 'Either permission or role dont exist';
					end
			end
		else
			begin
				set @create_role_permission_message = 'cannot add Permission to Role';
				print 'You can not cannot add Permission to Role';
			end
	end try
	begin catch
		set @create_role_permission_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING ADDING A PERMISSION TO ROLE';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

-- trying it out
declare @result nvarchar(max);

exec users.createRolePermission 
@staffroleId = 101,  
@roleId = 100 , @permissionId = 101,
@create_role_permission_message = @result output;

print 'Result: ' + @result;

select * from users.Roles






















