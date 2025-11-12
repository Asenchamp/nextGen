use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('updateAmbulancesDispatchLogs','You are able to update Ambulance Dispatch Logs')

-- permissions for particular roles
insert into users.Role_Permissions values
(106,170)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

-- procedure to register patient
create or alter procedure accommodation.updateAmbulancesDispatchLogs
@_staffroleId int, 
@dispatchId int,
@ambulanceRegno nvarchar(100),
@staffId int,
@Destination nvarchar(300) = null,
@Notes text = null,
@returnedAt datetime = null,
@Deleted bit = null,
@update_AmbulancesDispatchLogs_message nvarchar(max) output
with encryption
as
begin
    begin try
        -- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'updateAmbulancesDispatchLogs'

        -- check whether the user has that permission to update a staff
		if exists(select * from users.Role_Permissions
    			  where role_id = @_staffroleId and permission_id = @permmissionId and is_deleted != 1)
            begin
                print 'You can update Ambulance Dispatch Log';
                if exists(select * from accommodation.AmbulancesDispatchLogs
                          where dispatch_id = @dispatchId and staff_id = @staffId and ambulance_registration_number = @ambulanceRegno and returned_at is null and is_deleted = 0)
                    begin                  
                        update accommodation.AmbulancesDispatchLogs
                        set 
                        ambulance_registration_number = isnull(@ambulanceRegno, ambulance_registration_number),
                        staff_id = isnull(@staffId, staff_id),
                        destination = isnull(@Destination, destination),
                        notes = isnull(@Notes, notes),
                        returned_at = isnull(@returnedAt, returned_at),
                        is_deleted = isnull(@Deleted, is_deleted),
                        updated_at = getdate()
                        where 
                        dispatch_id = @dispatchId and staff_id = @staffId and ambulance_registration_number = @ambulanceRegno and returned_at is null and is_deleted = 0

                        set @update_AmbulancesDispatchLogs_message = 'Ambulance Dispatch Log updated'
                        print '=====================================================';
				        print 'Ambulance Dispatch Log:  updated successfully';
                    end
                else
                    begin
                        set @update_AmbulancesDispatchLogs_message = 'Ambulance Dispatch Log dont exist or ended'
                    end                                 
            end
        else
            begin
                set @update_AmbulancesDispatchLogs_message = 'cannot update Ambulance Dispatch Log'
                print 'You cannot update Ambulance Dispatch Log';
            end
    end try
    begin catch
        set @update_AmbulancesDispatchLogs_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING UPDATING AMBULANCE DISPATCH LOG';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
    end catch
end;

go

declare @result nvarchar(max);
declare @date datetime = getdate();
exec accommodation.updateAmbulancesDispatchLogs
@_staffroleId = 106, 
@dispatchId = 1,
@ambulanceRegno = '##0994',
@staffId = 1,
@Destination = null,
@Notes = null,
@returnedAt = null,
@Deleted = 0, 
@update_AmbulancesDispatchLogs_message = @result output

print 'Result ' + @result;

select * from accommodation.AmbulancesDispatchLogs





