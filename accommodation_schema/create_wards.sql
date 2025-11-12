use HospitalERp;

-- dumy data
-- system roles
insert into users.Roles values
('Accomodation', 'accomodation people');

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('createWard','You are able to add a ward')

-- permissions for particular roles
insert into users.Role_Permissions values
(106,152)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure accommodation.createWard
@staffroleId int,
@departmentId int = null,
@wardNumber nvarchar(25),
@wardType nvarchar(25),
@create_Ward_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'createWard'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
				  where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				insert into accommodation.Wards
				(department_id, ward_number, ward_type)
				values
				(@departmentId, @wardNumber, @wardType)
				set @create_Ward_message = 'Ward added';
				print '=====================================================';
				print 'Ward: added successfully';					
			end
		else
			begin
				set @create_Ward_message = 'cannot add a ward';
				print 'You can not add a ward';
			end
	end try
	begin catch
		set @create_Ward_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING ADDING A WARD';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

go

-- trying it out
declare @result nvarchar(max);
exec accommodation.createWard
@staffroleId = 106,  
@departmentId = null,
@wardNumber = '#007',
@wardType = 'private',
@create_Ward_message = @result output;
print 'Result: ' + @result;

select * from accommodation.Wards
