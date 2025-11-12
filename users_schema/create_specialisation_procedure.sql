use HospitalERp;

-- dummy data
-- system roles
insert into users.Roles values
('admin','top guy');

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('createSpecialisation','You are able to add a specialisation')

-- permissions for particular roles
insert into users.Role_Permissions values
(101,120)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure users.createSpecialisation
@staffroleId int, @departmentId int,
@specialisation_name nvarchar(35), @description nvarchar(100),
@create_specialisation_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'createSpecialisation'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
					where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				if exists(select * from users.Department where department_id = @departmentId and is_deleted != 1)
				   begin
						print('You can add a Specialisation')
						insert into users.Specialisation
						(department_id,specialisation_name, description)
						values
						(@departmentId, @specialisation_name, @description)
						set @create_specialisation_message = 'specialisation added';
						print '=====================================================';
						print 'Specialisation added successfully';					
				   end
				else
					begin
						set @create_specialisation_message = 'Department dont exist';
						print 'Department dont exist';
					end
			end
		else
			begin
				set @create_specialisation_message = 'cannot add Specialisation';
				print 'You can not cannot add Specialisation';
			end
	end try
	begin catch
		set @create_specialisation_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING ADDING A SPECIALISATON';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

-- trying it out
declare @result nvarchar(max);

exec users.createSpecialisation 
@staffroleId = 101,  @departmentId = 101,
@specialisation_name = 'heart specialisation', @description = 'heart specialisation',
@create_specialisation_message = @result output;

print 'Result: ' + @result;

select * from users.Specialisation






















