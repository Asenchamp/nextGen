use HospitalERp;

-- system Permissions
insert into users.Permissions (permission_name, permission_description) values
('readorfilterRoles','You are able to read or filter  roles')

-- permissions for particular roles
insert into users.Role_Permissions values
(101,111)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

-- readorfilter users stored procedure
create or alter procedure users.readorfilterRoles
@staffroleId int, 
@rolename nvarchar(35) = null,@roledescription nvarchar(100) = null,
@readorfilter_role_message nvarchar(max) output
with encryption
as
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'readorfilterRoles'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
					where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can read or filter roles')
				select 
					role_name as 'ROLE NAME',
					role_description as 'ROLE DESCRIPTION'
				from users.Roles
				where
				( @rolename is null or role_name like '%' + @rolename + '%') and
				( @roledescription is null or role_description like '%' + @roledescription + '%') and
				is_deleted != 1;										
			end
		else
			begin
				set @readorfilter_role_message = 'cannot read or filter roles';
				print 'You can not read or filter roles';
			end
	end try
	begin catch
		set @readorfilter_role_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING READING OR FILTERING A ROLE';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

-- trying it out
declare @result nvarchar(max);

exec users.readorfilterRoles 
@staffroleId = 101, 
-- @rolename = 'Doctors', @roledescription = 'treat patients',
@readorfilter_role_message = @result output;

print 'Result: ' + @result;
