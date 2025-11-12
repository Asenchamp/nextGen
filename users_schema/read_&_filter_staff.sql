use HospitalERp;


-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('readorfilterStaff','You are able to read or filter staff')

-- permissions for particular roles
insert into users.Role_Permissions values
(101,108)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

-- readorfilter staff stored procedure
create or alter procedure users.readorfilterStaff
@staffroleId int, @firstname nvarchar(50) = null,
@lastname nvarchar(50) = null, @user_email nvarchar(100) = null,
@user_phone_num nvarchar(20) = null,
@user_gender nvarchar(5) = null, @user_DOB date = null,
@user_marital_status nvarchar(25) = null, @user_address nvarchar(50) = null,

@staff_specialization int = null, @staff_department int = null,
@staff_license_number varchar(20) = null, @role_id INT = null,
@readorfilter_staff_message nvarchar(max) output
with encryption
as
begin
		begin try
			-- stores the permission id
			declare @permmissionId int
			select @permmissionId = permission_id from users.Permissions
			where permission_name = 'readorfilterStaff'

			-- check whether the user has that permission
			if exists(select * from users.Role_Permissions
					  where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
				begin
					print('You can read or filter staff')
					select 
						u.user_full_Name as 'FULL NAME',
						u.user_email as 'EMAIL',
						u.user_phone_num as 'PHONE NUMBER',
						u.user_gender as 'GENDER',
						u.user_DOB as 'DATE OF BIRTH',
						u.user_marital_status as 'MARITAL STATUS',
						u.user_address as 'ADDRESS',
						u.user_status as 'STATUS',
						d.department_name as 'DEPARTMENT',
						sp.specialisation_name as 'SPECIALISATION',
						s.staff_license_number as 'LICENSE NUMBER',
						s.staff_biodata as 'BIO DATA'
					from users.Users as u
						left join users.Staff as s
						on u.user_id = s.user_id
						left join users.Specialisation as sp
						on s.staff_specialization = sp.specialisation_id
						left join users.Department as d
						on d.department_id = sp.department_id	
					where
					( @firstname is null or u.user_full_Name like '%' + @firstname + '%') and
					( @lastname is null or u.user_full_Name like '%' + @lastname + '%') and
					( @user_email is null or u.user_email like '%' + @user_email + '%') and
					( @user_phone_num is null or u.user_phone_num like '%' + @user_phone_num + '%') and
					( @user_gender is null or u.user_gender = @user_gender) and
					( @user_DOB is null or u.user_DOB =  @user_DOB ) and
					( @user_marital_status is null or u.user_marital_status like '%' + @user_marital_status + '%') and
					( @user_address is null or u.user_address like '%' + @user_address + '%') and
					( @staff_department is null or d.department_id = @staff_department) and
					( @staff_specialization is null or sp.specialisation_id = @staff_specialization) and
					( @role_id is null or s.role_id = @role_id) and
					( @staff_license_number is null or s.staff_license_number like '%' + @staff_license_number + '%')
					and s.is_deleted != 1;
				end
			else
				begin
					set @readorfilter_staff_message = 'cannot read or filter staff';
					print 'You can not read or filter staff';
				end
		end try
		begin catch
			set @readorfilter_staff_message = ERROR_NUMBER();
			print '=====================================================';
			print 'ERROR OCCURED DURING READING OR FILTERING A STAFF';
			print 'Error Message '+ERROR_MESSAGE();
			print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
			print 'Error State '+cast(ERROR_STATE() as nvarchar);
			print '=====================================================';
		end catch
end



declare @readorfilter_staff_result nvarchar(max);

exec users.readorfilterStaff 
@staffroleId = 10, 
@firstname = 'Savie',
-- @_lastname = 'Ngaka', @_user_email = 'saviengaka@gmail.com',
-- @_user_phone_num = '+25675456463', @_user_password_hash = 'xxxx!@33',
-- @_user_gender = 'M', @_user_DOB = '2002-05-16',
-- @_user_marital_status = 'Single', @_user_address = 'Wandegeya',
-- @staff_specialization = 2, @staff_department = 1,
-- @staff_license_number ='ug-doc-007' , @role_id = 5,
@readorfilter_staff_message = @readorfilter_staff_result output

print 'Result : ' + @readorfilter_staff_result;













select 
	u.user_full_Name as 'FULL NAME',
	u.user_email as 'EMAIL',
	u.user_phone_num as 'PHONE NUMBER',
	u.user_gender as 'GENDER',
	u.user_DOB as 'DATE OF BIRTH',
	u.user_marital_status as 'MARITAL STATUS',
	u.user_address as 'ADDRESS',
	u.user_status as 'STATUS',
	d.department_name as 'DEPARTMENT',
	sp.specialisation_name as 'SPECIALISATION',
	s.staff_license_number as 'LICENSE NUMBER',
	s.staff_biodata as 'BIO DATA'
from users.Users as u
	left join users.Staff as s
	on u.user_id = s.user_id
	left join users.Specialisation as sp
	on s.staff_specialization = sp.specialisation_id
	left join users.Department as d
	on d.department_id = sp.department_id	
where s.staff_id is not null


select * from users.Staff