use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('updateSpecialisation','You are able to update a specialisation')

-- permissions for particular roles
insert into users.Role_Permissions values
(101,122)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

-- update users stored procedure
create or alter procedure users.updateSpecialisation
@staffroleId int, 
@departmentId int = null, @specialisationId int,
@specialisation_name nvarchar(35) = null, @description nvarchar(100) = null,
@Deleted bit = null,
@update_spec_message nvarchar(max) output
with encryption
as
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'updateSpecialisation'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
					where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can update a specialisation')
				if exists(select * from users.Specialisation where specialisation_id = @specialisationId and is_deleted != 1)
					begin
						update users.Specialisation
						set
							department_id = isnull(@departmentId, department_id),
							specialisation_name = isnull(@specialisation_name, specialisation_name),
							description = isnull(@description, description),
							is_deleted = isnull(@Deleted, is_deleted),
							updated_at = getdate()
						where
							specialisation_id = @specialisationId
						set @update_spec_message = 'specialisation updated';
						print '=====================================================';
						print 'Specialisation: '+@specialisation_name+' updated successfully';
					end
				else
					begin
						set @update_spec_message = 'specialisation dont exist';
					end
			end
		else
			begin
				set @update_spec_message = 'cannot update specialisation';
				print 'You can not update a specialisation';
			end
	end try
	begin catch
		set @update_spec_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING UPDATING A SPECIALISATION';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end


-- trying it out
declare @result nvarchar(max);

exec users.updateSpecialisation 
@staffroleId = 101,  
-- @departmentId = 10, 
@specialisationId = 100,
@specialisation_name = 'Doctors', @description = 'treat patients',
@update_spec_message = @result output;

print 'Result: ' + @result;

select * from users.Specialisation