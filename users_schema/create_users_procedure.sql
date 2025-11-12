use HospitalERp;

-- dumy data
-- system roles
insert into users.Roles values
('Receptionist','they sit on the front desk')

select * from users.Roles

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('createUser','You are able to add a user')

select * from users.Permissions

-- permissions for particular roles
insert into users.Role_Permissions values
(100,100)

select * from users.Role_Permissions

go

-- create users stored procedure
create or alter procedure users.createUser
@staffroleId int,  @firstname nvarchar(50),
@lastname nvarchar(50), @user_email nvarchar(100),
@user_phone_num nvarchar(20), @user_password_hash nvarchar(255),
@user_gender nvarchar(5), @user_DOB date,
@user_marital_status nvarchar(25), @user_address nvarchar(50),
@message nvarchar(max) output
with encryption
as
begin
		begin try
			-- stores the permission id
			declare @permmissionId int
			select @permmissionId = permission_id from users.Permissions
			where permission_name = 'createUser'

			-- check whether the user has that permission
			if exists(select * from users.Role_Permissions
					  where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
				begin
					print('You can add a user')
					insert into users.Users
					(user_full_Name,user_email,user_phone_num,user_password_hash,user_gender,
					user_DOB,user_marital_status,user_address,user_status,created_at)
					values
					(CONCAT(@firstname,' ',@lastname), @user_email, @user_phone_num, @user_password_hash,
					@user_gender, @user_DOB, @user_marital_status, @user_address, 'active', getdate())
					set @message = 'user added';
					print '=====================================================';
					print 'User: '+CONCAT(@firstname,' ',@lastname)+' added successfully';
				end
			else
				begin
					set @message = 'cannot add user';
					print 'You can not add a user';
				end
		end try
		begin catch
			set @message = ERROR_NUMBER();
			print '=====================================================';
			print 'ERROR OCCURED DURING ADDING A USER';
			print 'Error Message '+ERROR_MESSAGE();
			print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
			print 'Error State '+cast(ERROR_STATE() as nvarchar);
			print '=====================================================';
		end catch
end

go

-- trying it out
declare @result nvarchar(max);

exec users.createUser 
@staffroleId = 101,  @firstname = 'Ntalo',
@lastname = 'Walid', @user_email = 'warid@gmail.com',
@user_phone_num = '+25675457233', @user_password_hash = 'xxxx!@33',
@user_gender = 'M', @user_DOB = '2000-01-16',
@user_marital_status = 'Single', @user_address = 'Bukasa',
@message = @result output;

print 'Result: ' + @result;
	


select * from users.Users
