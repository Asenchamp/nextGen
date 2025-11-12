use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('updateAdmission','You are able to update an Admission')

-- permissions for particular roles
insert into users.Role_Permissions values
(106,160)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

-- procedure to register patient
create or alter procedure accommodation.updateAdmission
@_staffroleId int, 
@admissionId int,
@staffId int,
@patientId int,
@bedId int = null,
@admissionNotes nvarchar(100) = null,
@admissionEndedAt datetime = null,
@Deleted bit = null,
@update_Admission_message nvarchar(max) output
with encryption
as
begin
    begin try
        -- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'updateAdmission'

        -- check whether the user has that permission to update a staff
		if exists(select * from users.Role_Permissions
    			  where role_id = @_staffroleId and permission_id = @permmissionId and is_deleted != 1)
            begin
                print 'You can update an Appointment';
                if exists(select * from accommodation.Admissions
                          where admission_id = @admissionId and staff_id = @staffId and patient_id = @patientId and is_deleted != 1 and admission_ended_at is null)
                    begin                  
                        update accommodation.Admissions
                        set 
                        bed_id = isnull(@bedId, bed_id),
                        admission_notes = isnull(@admissionNotes, admission_notes),
                        admission_ended_at = isnull(@admissionEndedAt, admission_ended_at),
                        is_deleted = isnull(@Deleted, is_deleted),
                        updated_at = getdate()
                        where 
                        admission_id = @admissionId and staff_id = @staffId and patient_id = @patientId and is_deleted != 1 and admission_ended_at is null

                        set @update_Admission_message = 'admission updated'
                        print '=====================================================';
				        print 'Admission:  added successfully';
                    end
                else
                    begin
                        set @update_Admission_message = 'admission dont exist or ended'
                    end                                 
            end
        else
            begin
                set @update_Admission_message = 'cannot update admission'
                print 'You cannot update admission';
            end
    end try
    begin catch
        set @update_Admission_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING UPDATING AN ADMISSION';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
    end catch
end;

go

declare @result nvarchar(max);
declare @date datetime = getdate();
exec accommodation.updateAdmission
@_staffroleId = 106, 
@admissionId = 1,
@staffId = 1,
@patientId = 8,
@bedId = null,
@admissionNotes = 'infected with covid',
@admissionEndedAt = @date,
@update_Admission_message = @result output

print 'Result ' + @result;

select * from accommodation.Admissions