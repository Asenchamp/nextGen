use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('updateStaff','You are able to update a staff')

-- permissions for particular roles
insert into users.Role_Permissions values
(101,105)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

-- procedure to register patient
create or alter procedure users.updateStaff
@_staffroleId int, @_userId int, @_firstname nvarchar(50) = null,
@_lastname nvarchar(50) = null, @_user_email nvarchar(100) = null,
@_user_phone_num nvarchar(20) = null, @_user_password_hash nvarchar(255) = null,
@_user_gender nvarchar(5) = null, @_user_DOB date = null,
@_user_marital_status nvarchar(25) = null, @_user_address nvarchar(50) = null,

@staff_specialization int = null, @staff_biodata varchar(20) = null,
@staff_license_number varchar(20) = null, @role_id INT = null,
@Deleted bit = null,
@update_staff_message nvarchar(max) output
with encryption
as
begin
    begin try
        -- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'updateStaff'

        -- check whether the user has that permission to update a staff
		if exists(select * from users.Role_Permissions
    			  where role_id = @_staffroleId and permission_id = @permmissionId)
            begin
                print 'You can update a staff';
                if exists(select * from users.Staff where user_id = @_userId)
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
                                set @update_staff_message = @result
                            end
                        else
                            begin                        
                                update users.Staff
                                set 
                                staff_specialization = isnull(@staff_specialization, staff_specialization),
                                staff_biodata = isnull(@staff_biodata, staff_biodata),
                                staff_license_number = isnull(@staff_license_number, staff_license_number),
                                role_id = isnull(@role_id, role_id),
                                @Deleted = @Deleted,
                                updated_at = getdate()
                                where
                                user_id = @_userId and is_deleted != 1

                                set @update_staff_message = 'staff updated'
                                print '=====================================================';
				                print 'Staff: '+CONCAT(@_firstname,' ',@_lastname)+' added successfully';                                                  
                            end                                 
                    end
                else
                    begin
                        set @update_staff_message = 'staff dont exist'
                    end                                 
            end
        else
            begin
                set @update_staff_message = 'cannot update staff'
                print 'You cannot update a staff';
            end
    end try
    begin catch
        set @update_staff_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING UPDATING A STAFF';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
    end catch
end;

go

declare @update_staff_result nvarchar(max);

exec users.updateStaff 
@_staffroleId = 101,  @_userId = 19,
-- @_firstname = 'Savie',
-- @_lastname = 'Ngaka', @_user_email = 'saviengaka@gmail.com',
-- @_user_phone_num = '+25675456463', @_user_password_hash = 'xxxx!@33',
-- @_user_gender = 'M', @_user_DOB = '2002-05-16',
-- @_user_marital_status = 'Single', @_user_address = 'Wandegeya',
-- @patient_medical_record_number = '##76373', @patient_blood_group = 'O',
-- @patient_bmi = '25', @patient_notes = 'fucked real good',
-- @patient_emergency_name = 'Mugisha Micheal', @patient_emergency_contact = '+256725536372',
@update_staff_message = @update_staff_result output

print 'Result For Updating A Patient: ' + @update_staff_result;

select * from users.Staff