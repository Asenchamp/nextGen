use HospitalERp;

-- dummy data
-- system roles
insert into users.Roles values
('admin','top guy');

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('createRole','You are able to add a role')

-- permissions for particular roles
insert into users.Role_Permissions values
(101,109)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure users.createRole
@staffroleId int, 
@rolename nvarchar(35),@roledescription nvarchar(100),
@create_role_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'createRole'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
					where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can add a Role')
				insert into users.Roles
				(role_name,role_description)
				values
				(@rolename,@roledescription)
				set @create_role_message = 'role added';
				print '=====================================================';
				print 'Role: '+@rolename+' added successfully';
			end
		else
			begin
				set @create_role_message = 'cannot add role';
				print 'You can not add a role';
			end
	end try
	begin catch
		set @create_role_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING ADDING A ROLE';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

go

-- trying it out
declare @result nvarchar(max);
exec users.createRole 
@staffroleId = 101,  
@rolename = '', @roledescription = 'Walid',
@create_role_message = @result output;

print 'Result: ' + @result;

select * from users.Roles






















