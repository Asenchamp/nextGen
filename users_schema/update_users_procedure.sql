use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('updateUser','You are able to update a user')

-- permissions for particular roles
insert into users.Role_Permissions values
(101,103)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

-- update users stored procedure
create or alter procedure users.updateUser
@staffroleId int, @userId int,  @firstname nvarchar(50) = null,
@lastname nvarchar(50) = null, @user_email nvarchar(100) = null,
@user_phone_num nvarchar(20) = null, @user_password_hash nvarchar(255) = null,
@user_gender nvarchar(5) = null, @user_DOB date = null,
@user_marital_status nvarchar(25) = null, @user_address nvarchar(50) = null,
@Deleted bit = null,
@update_user_message nvarchar(max) output
with encryption
as
begin
		begin try
			-- stores the permission id
			declare @permmissionId int
			select @permmissionId = permission_id from users.Permissions
			where permission_name = 'updateUser'

			-- check whether the user has that permission
			if exists(select * from users.Role_Permissions
					  where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
				begin
					print('You can update a user')
					if exists(select * from users.Users where user_id = @userId and is_deleted != 1)
						begin
							update users.Users
							set
								-- user_full_Name = isnull(CONCAT(@firstname,' ',@lastname), user_full_Name), 
								user_full_Name = case
									when @firstname is not null and @lastname is not null
									then concat(@firstname, ' ', @lastname)
									when @firstname is not null and @lastname is null
									then concat(@firstname, ' ', isnull((select substring(user_full_Name, charindex(' ', user_full_Name) + 1, len(user_full_Name))), ''))
									when @lastname is not null and @firstname is null
									then concat(isnull((select substring(user_full_Name, 1, charindex(' ', user_full_Name) - 1)), ''), ' ', @lastname)
									else user_full_Name
								end,
								user_email = isnull(@user_email, user_email), user_phone_num = isnull(@user_phone_num, user_phone_num),
								user_password_hash = isnull(@user_password_hash, user_password_hash), user_gender = isnull(@user_gender, user_gender),
								user_DOB = isnull(@user_DOB, user_DOB),user_marital_status = isnull(@user_marital_status, user_marital_status),
								user_address = isnull(@user_address, user_address),
								is_deleted = isnull(@Deleted, is_deleted),
								updated_at = getdate()
							where
								user_id = @userId and is_deleted != 1
							set @update_user_message = 'user updated';
							print '=====================================================';
							print 'User: '+CONCAT(@firstname,' ',@lastname)+' updated successfully';
						end
					else
						begin
							set @update_user_message = 'user dont exist';
						end
				end
			else
				begin
					set @update_user_message = 'cannot update user';
					print 'You can not update a user';
				end
		end try
		begin catch
			set @update_user_message = ERROR_NUMBER();
			print '=====================================================';
			print 'ERROR OCCURED DURING UPDATING A USER';
			print 'Error Message '+ERROR_MESSAGE();
			print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
			print 'Error State '+cast(ERROR_STATE() as nvarchar);
			print '=====================================================';
		end catch
end


-- trying it out
declare @result nvarchar(max);

exec users.updateUser 
@staffroleId = 101, @userId = 6,
-- @firstname = 'Benjamin2', 
-- @lastname = 'Bisaso', @user_email = 'warid@gmail.com',
-- @user_phone_num = '+25675457233', @user_password_hash = 'xxxx!@33',
-- @user_gender = 'M', @user_DOB = '2000-01-16',
-- @user_marital_status = 'Single', @user_address = 'Bukasa',
@update_user_message = @result output;

print 'Result: ' + @result;

select * from users.Users