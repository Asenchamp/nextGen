use HospitalERp;

-- dummy data

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('createStaff','You are able to add staff')

-- permissions for particular roles
insert into users.Role_Permissions values
(101,102)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

-- procedure to register a staff
create or alter procedure users.registerStaff
@_staffroleId int,  @_firstname nvarchar(50),
@_lastname nvarchar(50), @_user_email nvarchar(100),
@_user_phone_num nvarchar(20), @_user_password_hash nvarchar(255),
@_user_gender nvarchar(5), @_user_DOB date,
@_user_marital_status nvarchar(25), @_user_address nvarchar(50),

@staff_specialization int, @staff_biodata varchar(20),
@staff_license_number varchar(20), @role_id INT,
@create_staff_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'createStaff'
		-- check whether the user has that permission to add a staff
		if exists(select * from users.Role_Permissions
    			  where role_id = @_staffroleId and permission_id = @permmissionId and is_deleted != 1)
            begin
                print 'You can add a staff';
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
                        set @create_staff_message = @result
                    end
                else
                    begin
                        -- get the user id
                        declare @userId int
		                select @userId = user_id from users.Users
		                where user_full_Name = CONCAT(@_firstname,' ',@_lastname) and is_deleted != 1
                        -- create the satff profile
                        insert into users.Staff
                        (user_id, staff_specialization, staff_biodata, staff_license_number,role_id,created_at)
                        values
                        (@userId, @staff_specialization, @staff_biodata, @staff_license_number, @role_id, getdate())
                        set @create_staff_message = 'staff added'
                        print '=====================================================';
				        print 'Staff: '+CONCAT(@_firstname,' ',@_lastname)+' added successfully';
                    end             
            end
        else
            begin
                set @create_staff_message = 'cannot add Staff'
                print 'You cannot add a Satff';
            end
	end try
	begin catch
        if not exists(select * from users.Staff where user_id = @userId)
            begin
                -- remove the user profile
                delete from users.Users where user_id = @userId
                print 'User: '+CONCAT(@_firstname,' ',@_lastname)+' removed';
            end
        set @create_staff_message = 'Error Message '+ERROR_MESSAGE();
		print '=====================================================';
		print 'ERROR OCCURED DURING ADDING A PATIENT';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
    end catch
end

go

declare @create_staff_result nvarchar(max);

exec users.registerStaff 
@_staffroleId = 101,  @_firstname = 'Odongo',
@_lastname = 'Timothy', @_user_email = 'timoOdongo@gmail.com',
@_user_phone_num = '+2567477756463', @_user_password_hash = 'xxxx!@33',
@_user_gender = 'M', @_user_DOB = '2005-10-26',
@_user_marital_status = 'Single', @_user_address = 'Mutungo',
@staff_specialization = null, @staff_biodata = 'confused',
@staff_license_number = 'ug-doc-077', @role_id = 3,
@create_staff_message = @create_staff_result output

print 'Result For Creating A Staff: ' + @create_staff_result;


select * from users.Staff

select * from users.Users
delete from users.Users where user_id = 29









