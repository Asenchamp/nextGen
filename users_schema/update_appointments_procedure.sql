use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('updateAppointments','You are able to update an Appointment')

-- permissions for particular roles
insert into users.Role_Permissions values
(101,159)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

-- procedure to register patient
create or alter procedure users.updateAppointments
@_staffroleId int, 
@appointmentId int,
@appointmentDate datetime = null, 
@notes text = null,
@departmentId int = null, 
@staffId int = null,
@patientId int, 
@appointment_status varchar(40) = null,
@Deleted bit = null,
@update_Appointment_message nvarchar(max) output
with encryption
as
begin
    begin try
        -- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'updateAppointments'

        -- check whether the user has that permission to update a staff
		if exists(select * from users.Role_Permissions
    			  where role_id = @_staffroleId and permission_id = @permmissionId and is_deleted != 1)
            begin
                print 'You can update an Appointment';
                if exists(select * from users.Appointments 
                          where appointment_id = @appointmentId and patient_id = @patientId and appointment_status not like 'Finished' and is_deleted != 1)
                    begin                  
                        update users.Appointments
                        set 
                        appointment_date = isnull(@appointmentDate, appointment_date),
                        appointment_status = isnull(@appointment_status, appointment_status),
                        notes = isnull(@notes, notes),
                        department_id = isnull(@departmentId, department_id),
                        staff_id = isnull(@staffId, staff_id),
                        is_deleted = isnull(@Deleted, is_deleted),
                        updated_at = getdate()
                        where 
                        appointment_id = @appointmentId and patient_id = @patientId and appointment_status not like 'Finished' and is_deleted != 1

                        set @update_Appointment_message = 'appointment updated'
                        print '=====================================================';
				        print 'Appointment:  added successfully';
                    end
                else
                    begin
                        set @update_Appointment_message = 'appointment dont exist or finished'
                    end                                 
            end
        else
            begin
                set @update_Appointment_message = 'cannot update appointment'
                print 'You cannot update appointment';
            end
    end try
    begin catch
        set @update_Appointment_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING UPDATING AN APPOINTMENT';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
    end catch
end;

go

declare @result nvarchar(max);
exec users.updateAppointments 
@_staffroleId = 101, 
@appointmentId = 1,
@appointmentDate = null, 
@notes = null,
@departmentId = null, 
@staffId = null,
@patientId = 2, 
@appointment_status = 'Approved',
@update_Appointment_message = @result output

print 'Result ' + @result;

select * from users.Appointments