use HospitalERp;

-- dummy data
-- system roles
insert into users.Roles values
('admin','top guy');

-- system Permissions
insert into users.Permissions values
('deleteSpecialisation','You are able to delete a Specialisation')

-- permissions for particular roles
insert into users.Role_Permissions values
(101,123)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

create or alter procedure users.deleteSpecialisation
@staffroleId int, @specialisationId int,
@delete_spec_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'deleteSpecialisation'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
					where role_id = @staffroleId and permission_id = @permmissionId)
			begin
				print('You can delete a Specialisation')
				if exists(select * from users.Specialisation where specialisation_id = @specialisationId)
					begin
						delete from users.Specialisation						
						where
							specialisation_id = @specialisationId

						set @delete_spec_message = 'specialisation deleted ';
						print '=====================================================';
						print 'specialisation deleted ';
					end
				else
					begin
						set @delete_spec_message = 'specialisation dont exist';
					end
			end
		else
			begin
				set @delete_spec_message = 'cannot delete specialisation';
				print 'You can not delete specialisation';
			end
	end try
	begin catch
		set @delete_spec_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING DELETING A SPECIALISATION';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

-- trying it out
declare @result nvarchar(max);

exec users.deleteSpecialisation 
@staffroleId = 101,  
@specialisationId = 100,
@delete_spec_message = @result output;

print 'Result: ' + @result;

select * from users.Specialisation






















