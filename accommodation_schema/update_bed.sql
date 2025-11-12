use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('updateBed','You are able to update a specialisation')

-- permissions for particular roles
insert into users.Role_Permissions values
(106,156)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

-- update users stored procedure
create or alter procedure accommodation.updateBed
@staffroleId int, 
@bedId int,
@bedNumber nvarchar(25), 
@wardId int,
@Deleted bit = null,
@update_Bed_message nvarchar(max) output
with encryption
as
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'updateBed'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
					where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can update a bed')
				if exists(select * from accommodation.Beds where bed_id = @bedId and is_deleted != 1)
					begin
						update accommodation.Beds
						set
							bed_number = isnull(@bedNumber, bed_number),
							ward_id = isnull(@wardId, ward_id),
							is_deleted = isnull(@Deleted, is_deleted),
							updated_at = getdate()
						where
							bed_id = @bedId and is_deleted != 1
						set @update_Bed_message = 'Bed updated';
						print '=====================================================';
						print 'Bed: updated successfully';
					end
				else
					begin
						set @update_Bed_message = 'bed dont exist';
					end
			end
		else
			begin
				set @update_Bed_message = 'cannot update bed';
				print 'You can not update a bed';
			end
	end try
	begin catch
		set @update_Bed_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING UPDATING A BED';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end


-- trying it out
declare @result nvarchar(max);

exec accommodation.updateBed
@staffroleId = 106,  
@bedId = 2,
@bedNumber = null, 
@wardId = null,
@update_Bed_message = @result output;

print 'Result: ' + @result;

select * from accommodation.Beds