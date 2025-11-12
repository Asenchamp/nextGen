use HospitalERp;

-- dummy data
-- system roles
insert into users.Roles values
('admin','top guy');

-- system Permissions
insert into users.Permissions values
('deleteRole','You are able to delete a role')

-- permissions for particular roles
insert into users.Role_Permissions values
(101,112)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

create or alter procedure users.deleteRole
@staffroleId int, @roleId int,
@delete_role_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'deleteRole'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
					where role_id = @staffroleId and permission_id = @permmissionId)
			begin
				print('You can delete a role')
				if exists(select * from users.Roles where role_id = @roleId)
					begin
						delete from users.Roles						
						where
							role_id = @roleId

						set @delete_role_message = 'role delete';
						print '=====================================================';
						print 'Role deleted successfully';
					end
				else
					begin
						set @delete_role_message = 'role dont exist';
					end
			end
		else
			begin
				set @delete_role_message = 'cannot delete role';
				print 'You can not delete a role';
			end
	end try
	begin catch
		set @delete_role_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING ADDING A ROLE';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

-- trying it out
declare @result nvarchar(max);

exec users.deleteRole 
@staffroleId = 101,  @roleId = 103,
@delete_role_message = @result output;

print 'Result: ' + @result;

select * from users.Roles






















