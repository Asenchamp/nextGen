use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('readorfilterUsers','You are able to read or filter  users')

-- permissions for particular roles
insert into users.Role_Permissions values
(101,106)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

-- readorfilter users stored procedure
create or alter procedure users.readorfilterUsers
@staffroleId int, @firstname nvarchar(50) = null,
@lastname nvarchar(50) = null, @user_email nvarchar(100) = null,
@user_phone_num nvarchar(20) = null,
@user_gender nvarchar(5) = null, @user_DOB date = null,
@user_marital_status nvarchar(25) = null, @user_address nvarchar(50) = null,
@readorfilter_user_message nvarchar(max) output
with encryption
as
begin
		begin try
			-- stores the permission id
			declare @permmissionId int
			select @permmissionId = permission_id from users.Permissions
			where permission_name = 'readorfilterUsers'

			-- check whether the user has that permission
			if exists(select * from users.Role_Permissions
					  where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
				begin
					print('You can read or filter users')
					select 
						user_full_Name as 'FULL NAME',
						user_email as 'EMAIL',
						user_phone_num as 'PHONE NUMBER',
						user_gender as 'GENDER',
						user_DOB as 'DATE OF BIRTH',
						user_marital_status as 'MARITAL STATUS',
						user_address as 'ADDRESS',
						user_status as 'STATUS'
					from users.Users
					where
					( @firstname is null or user_full_Name like '%' + @firstname + '%') and
					( @lastname is null or user_full_Name like '%' + @lastname + '%') and
					( @user_email is null or user_email like '%' + @user_email + '%') and
					( @user_phone_num is null or user_phone_num like '%' + @user_phone_num + '%') and
					( @user_gender is null or user_gender = @user_gender) and
					( @user_DOB is null or user_DOB =  @user_DOB ) and
					( @user_marital_status is null or user_marital_status like '%' + @user_marital_status + '%') and
					( @user_address is null or user_address like '%' + @user_address + '%') and
					is_deleted != 1;
										
				end
			else
				begin
					set @readorfilter_user_message = 'cannot read or filter users';
					print 'You can not read or filter users';
				end
		end try
		begin catch
			set @readorfilter_user_message = ERROR_NUMBER();
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

exec users.readorfilterUsers 
@staffroleId = 101, -- @userId = 6,
-- @firstname = 'Benja', 
-- @lastname = 'Bisaso', @user_email = 'warid@gmail.com',
-- @user_phone_num = '+25675457233', @user_password_hash = 'xxxx!@33',
-- @user_gender = 'M', @user_DOB = '2000-01-16',
-- @user_marital_status = 'Single',
-- @user_address = 'Bukasa',
@readorfilter_user_message = @result output;

print 'Result: ' + @result;














