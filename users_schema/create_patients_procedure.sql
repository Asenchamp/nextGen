use HospitalERp;

-- dummy data
-- system roles
insert into users.Roles values
('admin','top guy');

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('createPatient','You are able to add a patient')

-- permissions for particular roles
insert into users.Role_Permissions values
(101,100)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

-- procedure to register patient
create or alter procedure users.registerPatient
@_staffroleId int,  @_firstname nvarchar(50),
@_lastname nvarchar(50), @_user_email nvarchar(100),
@_user_phone_num nvarchar(20), @_user_password_hash nvarchar(255),
@_user_gender nvarchar(5), @_user_DOB date,
@_user_marital_status nvarchar(25), @_user_address nvarchar(50),

@patient_medical_record_number nvarchar(25), @patient_blood_group nvarchar(5),
@patient_bmi nvarchar(25), @patient_notes nvarchar(50),
@patient_emergency_name nvarchar(100), @patient_emergency_contact nvarchar(100),
@create_patient_message nvarchar(max) output
with encryption
as
begin
    begin try
        -- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'createPatient'

        -- check whether the user has that permission to add a patient
		if exists(select * from users.Role_Permissions
    			  where role_id = @_staffroleId and permission_id = @permmissionId and is_deleted != 1)
            begin
                print 'You can add a patient';
                -- first register as a user
                declare @result nvarchar(max);
                exec users.createUser 
                @staffroleId = @_staffroleId,  @firstname = @_firstname,
                @lastname = @_lastname, @user_email = @_user_email,
                @user_phone_num = @_user_phone_num, @user_password_hash = @_user_password_hash,
                @user_gender = @_user_gender, @user_DOB = @_user_DOB,
                @user_marital_status = @_user_marital_status, @user_address = @_user_address,
                @message = @result output;

                -- make sure user is created first
                if @result != 'user added'
                    begin
                        set @create_patient_message = @result
                    end
                else
                    begin
                        -- get the user id
                        declare @userId int
		                select @userId = user_id from users.Users
		                where user_full_Name = CONCAT(@_firstname,' ',@_lastname) and is_deleted != 1

                        -- create the patient profile
                        insert into users.Patients
                        (user_id, patient_medical_record_number, patient_blood_group, patient_bmi,
                        patient_notes, patient_emergency_name, patient_emergency_contact, created_at)
                        values
                        (@userId, @patient_medical_record_number, @patient_blood_group, @patient_bmi,
                        @patient_notes, @patient_emergency_name, @patient_emergency_contact, getdate())
                        set @create_patient_message = 'patient added'
                        print '=====================================================';
				        print 'Patient: '+CONCAT(@_firstname,' ',@_lastname)+' added successfully';
                    end             
            end
        else
            begin
                set @create_patient_message = 'cannot add patient'
                print 'You cannot add a patient';
            end
    end try
    begin catch
        if not exists(select * from users.Patients where user_id = @userId)
            begin
                -- remove the user profile
                delete from users.Users where user_id = @userId
                print 'User: '+CONCAT(@_firstname,' ',@_lastname)+' removed';
            end
        set @create_patient_message = 'Error Message '+cast(ERROR_NUMBER() as nvarchar);
		print '=====================================================';
		print 'ERROR OCCURED DURING ADDING A PATIENT';
		print 'Error Message '+cast(ERROR_MESSAGE() as nvarchar);
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
    end catch
end;

go

declare @create_patient_result nvarchar(max);

exec users.registerPatient 
@_staffroleId = 101,  @_firstname = 'Rose',
@_lastname = 'Namubiru', @_user_email = 'namubiruRose@gmail.com',
@_user_phone_num = '+2567886463', @_user_password_hash = 'xxxx!@33',
@_user_gender = 'M', @_user_DOB = '2003-05-16',
@_user_marital_status = 'Single', @_user_address = 'Kawempe',
@patient_medical_record_number = '##76374', @patient_blood_group = 'O',
@patient_bmi = '25', @patient_notes = 'fucked real good',
@patient_emergency_name = 'Mugisha Micheal', @patient_emergency_contact = '+256725536372',
@create_patient_message = @create_patient_result output

print 'Result For Creating A Patient: ' + @create_patient_result;


select * from users.Patients

select * from users.Users
delete from users.Users where user_id = 32






