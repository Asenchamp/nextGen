use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('updatePatient','You are able to update a patient')

-- permissions for particular roles
insert into users.Role_Permissions values
(101,104)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

-- procedure to register patient
create or alter procedure users.updatePatient
@_staffroleId int, @_userId int, @_firstname nvarchar(50) = null,
@_lastname nvarchar(50) = null, @_user_email nvarchar(100) = null,
@_user_phone_num nvarchar(20) = null, @_user_password_hash nvarchar(255) = null,
@_user_gender nvarchar(5) = null, @_user_DOB date = null,
@_user_marital_status nvarchar(25) = null, @_user_address nvarchar(50) = null,

@patient_medical_record_number nvarchar(25) = null, @patient_blood_group nvarchar(5) = null,
@patient_bmi nvarchar(25) = null, @patient_notes nvarchar(50) = null,
@patient_emergency_name nvarchar(100) = null, @patient_emergency_contact nvarchar(100) = null,
@Deleted bit = null,
@update_patient_message nvarchar(max) output
with encryption
as
begin
    begin try
        -- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'updatePatient'

        -- check whether the user has that permission to update a patient
		if exists(select * from users.Role_Permissions
    			  where role_id = @_staffroleId and permission_id = @permmissionId and is_deleted != 1)
            begin
                print 'You can update a patient';
                -- make sure patient exists
                if exists(select * from users.Patients where user_id = @_userId and is_deleted != 1)
                    begin
                        declare @result nvarchar(max);
                        exec users.updateUser 
                        @staffroleId = @_staffroleId, @userId = @_userId, @firstname = @_firstname,
                        @lastname = @_lastname, @user_email = @_user_email,
                        @user_phone_num = @_user_phone_num, @user_password_hash = @_user_password_hash,
                        @user_gender = @_user_gender, @user_DOB = @_user_DOB,
                        @user_marital_status = @_user_marital_status, @user_address = @_user_address,
                        @Deleted = @Deleted,
                        @update_user_message = @result output;

                        -- make sure user is exists
                        if @result != 'user updated'
                            begin
                                set @update_patient_message = @result
                            end
                        else
                            begin                        
                                update users.Patients
                                set 
                                patient_medical_record_number = isnull(@patient_medical_record_number, patient_medical_record_number),
                                patient_blood_group = isnull(@patient_blood_group, patient_blood_group),
                                patient_bmi = isnull(@patient_bmi, patient_bmi),
                                patient_notes = isnull(@patient_notes, patient_notes),
                                patient_emergency_name = isnull(@patient_emergency_name, patient_emergency_name),
                                patient_emergency_contact = isnull(@patient_emergency_contact, patient_emergency_contact),
                                is_deleted = isnull(@Deleted, is_deleted)
                                where
                                user_id = @_userId and is_deleted != 1

                                set @update_patient_message = 'patient updated'
                                print '=====================================================';
				                print 'Patient: '+CONCAT(@_firstname,' ',@_lastname)+' added successfully';                                                  
                            end                                 
                    end
                else
                    begin
                        set @update_patient_message = 'patient dont exist'
                    end                                 
            end
        else
            begin
                set @update_patient_message = 'cannot update patient'
                print 'You cannot update a patient';
            end
    end try
    begin catch
        set @update_patient_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING UPDATING A PATIENT';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
    end catch
end;

go

declare @update_patient_result nvarchar(max);

exec users.updatePatient 
@_staffroleId = 101,  @_userId = 16,
-- @_firstname = 'Savie',
-- @_lastname = 'Ngaka', @_user_email = 'saviengaka@gmail.com',
-- @_user_phone_num = '+25675456463', @_user_password_hash = 'xxxx!@33',
-- @_user_gender = 'M', @_user_DOB = '2002-05-16',
-- @_user_marital_status = 'Single', @_user_address = 'Wandegeya',
-- @patient_medical_record_number = '##76373', @patient_blood_group = 'O',
-- @patient_bmi = '25', @patient_notes = 'fucked real good',
-- @patient_emergency_name = 'Mugisha Micheal', @patient_emergency_contact = '+256725536372',
@update_patient_message = @update_patient_result output

print 'Result For Updating A Patient: ' + @update_patient_result;


select * from users.Patients



















