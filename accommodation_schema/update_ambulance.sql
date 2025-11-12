use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('updateAmbulance','You are able to update an Ambulance')

-- permissions for particular roles
insert into users.Role_Permissions values
(106,167)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure accommodation.updateAmbulance
@staffroleId int,
@ambulanceRegno nvarchar(100),
@ambulanceContactphone nvarchar(30) = null,
@ambulanceStatus nvarchar(25) = null,
@Deleted bit = null,
@update_Ambulance_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'updateAmbulance'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
				  where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can update an Ambulance')
				if exists(select * from accommodation.Ambulances
						  where ambulance_registration_number = @ambulanceRegno and is_deleted != 1)
					begin
						update accommodation.Ambulances
						set
							ambulance_contact_phone = isnull(@ambulanceContactphone, ambulance_contact_phone),
							ambulance_status = isnull(@ambulanceStatus, ambulance_status),
							is_deleted = isnull(@Deleted, is_deleted),
							updated_at = getdate()
						where ambulance_registration_number = @ambulanceRegno and is_deleted != 1
						
						set @update_Ambulance_message = 'Ambulance updated';
						print '=====================================================';
						print 'Ambulance updated successfully';
					end
				else
					begin
						set @update_Ambulance_message = 'Ambulance dont exist';
					end
			end
		else
				begin
					set @update_Ambulance_message = 'cannot update Ambulance';
					print 'You can not update Ambulance';
				end
	end try
	begin catch
			set @update_Ambulance_message = ERROR_NUMBER();
			print '=====================================================';
			print 'ERROR OCCURED DURING UPDATING AN AMBULANCE';
			print 'Error Message '+ERROR_MESSAGE();
			print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
			print 'Error State '+cast(ERROR_STATE() as nvarchar);
			print '=====================================================';
		end catch
end

go

-- trying it out
declare @result nvarchar(max);
exec accommodation.updateAmbulance
@staffroleId = 106,
@ambulanceRegno = '##0994',
@ambulanceContactphone = null,
@ambulanceStatus = null,
@Delete = null,
@update_Ambulance_message = @result output;

print 'Result: ' + @result;

select * from accommodation.Ambulances

