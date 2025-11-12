use HospitalERp;

-- dummy data
-- system roles
insert into users.Roles values
('admin','top guy');

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('readorfilterRolePermission','You are able to read or filter a role and see the permissions')

-- permissions for particular roles
insert into users.Role_Permissions values
(100,114)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure users.readorfilterRolePermission
@staffroleId int, 
@roleId int = null, @permissionId int = null,
@readorfilter_role_permission_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'readorfilterRolePermission'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
					where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can read or filter a Permission to a Role')
				select 
					role_name as 'ROLE NAME',
					role_description as 'ROLE DESCRIPTION',
					permission_name as 'PERMISSION NAME',
					permission_description as 'PERMISSION DESCRIPTION'
				from users.Role_Permissions as rp
				left join users.Roles as r
				on rp.role_id = r.role_id
				left join users.Permissions as p
				on rp.permission_id = p.permission_id
				where 
				-- r.role_id = @roleId or p.permission_id = @permissionId
				( @roleId is null or rp.role_id = @roleId ) and
				( @permissionId is null or rp.permission_id = @permissionId ) and
				rp.is_deleted != 1;
				set @readorfilter_role_permission_message = 'permission read or filtered for role';
				print '=====================================================';
				print 'Permission read or filtered for Role successfully';					
				   
			end
		else
			begin
				set @readorfilter_role_permission_message = 'cannot read or filter Permission for Role';
				print 'You can not cannot read or filter Permission for Role';
			end
	end try
	begin catch
		set @readorfilter_role_permission_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING READING OR FILTERING PERMISSIONS FOR A ROLE';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

-- trying it out
declare @result nvarchar(max);

exec users.readorfilterRolePermission 
@staffroleId = 100,  
 @roleId = 101 , @permissionId = null,
@readorfilter_role_permission_message = @result output;

print 'Result: ' + @result;

select * from users.Role_Permissions





select *
from users.Role_Permissions as rp
left join users.Roles as r
on rp.role_id = r.role_id
left join users.Permissions as p
on rp.permission_id = p.permission_id

select 
	role_name as 'ROLE NAME',
	role_description as 'ROLE DESCRIPTION',
	permission_name as 'PERMISSION NAME',
	permission_description as 'PERMISSION DESCRIPTION'
from users.Role_Permissions as rp
left join users.Roles as r
on rp.role_id = r.role_id
left join users.Permissions as p
on rp.permission_id = p.permission_id
where rp.role_id = null or rp.permission_id = null