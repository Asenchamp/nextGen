use HospitalERp;

-- dumy data
-- system roles
insert into users.Roles values
('Accomodation', 'accomodation people');

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('updateWard','You are able to update a ward')

-- permissions for particular roles
insert into users.Role_Permissions values
(106,153)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure accommodation.updateWard
@staffroleId int,
@wardId int,
@departmentId int = null,
@wardNumber nvarchar(25) = null,
@wardType nvarchar(25) = null,
@Deleted bit = null,
@update_Ward_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'updateWard'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
				  where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can update a ward')
				if exists(select * from accommodation.Wards
						  where ward_id = @wardId and is_deleted != 1)
					begin
						update accommodation.Wards
						set
							department_id = isnull(@departmentId, department_id),
							ward_number = isnull(@wardNumber, ward_number),
							ward_type = isnull(@wardType, ward_type),
							is_deleted = isnull(@Deleted, is_deleted),
							updated_at = getdate()
						where ward_id = @wardId and is_deleted != 1
						set @update_Ward_message = 'Ward updated';
						print '=====================================================';
						print 'Ward updated successfully';
					end
				else
					begin
						set @update_Ward_message = 'Ward dont exist';
					end
			end
		else
				begin
					set @update_Ward_message = 'cannot update Ward';
					print 'You can not update Ward';
				end
	end try
	begin catch
			set @update_Ward_message = ERROR_NUMBER();
			print '=====================================================';
			print 'ERROR OCCURED DURING UPDATING A WARD';
			print 'Error Message '+ERROR_MESSAGE();
			print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
			print 'Error State '+cast(ERROR_STATE() as nvarchar);
			print '=====================================================';
		end catch
end



-- trying it out
declare @result nvarchar(max);
exec accommodation.updateWard
@staffroleId = 106,
@wardId = 1,
@departmentId = null,
@wardNumber = null,
@wardType = 'public',
@update_Ward_message = @result output;

print 'Result: ' + @result;

select * from accommodation.Wards

