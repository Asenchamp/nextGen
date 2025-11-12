use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('readorfilterPatients','You are able to read or filter  patients')

-- permissions for particular roles
insert into users.Role_Permissions values
(101,107)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

-- readorfilter patients stored procedure
create or alter procedure users.readorfilterPatients
@staffroleId int, @firstname nvarchar(50) = null,
@lastname nvarchar(50) = null, @user_email nvarchar(100) = null,
@user_phone_num nvarchar(20) = null,
@user_gender nvarchar(5) = null, @user_DOB date = null,
@user_marital_status nvarchar(25) = null, @user_address nvarchar(50) = null,

@patient_medical_record_number nvarchar(25) = null, @patient_blood_group nvarchar(5) = null,
@patient_bmi nvarchar(25) = null,
@patient_emergency_name nvarchar(100) = null, @patient_emergency_contact nvarchar(100) = null,
@readorfilter_patients_message nvarchar(max) output
with encryption
as
begin
		begin try
			-- stores the permission id
			declare @permmissionId int
			select @permmissionId = permission_id from users.Permissions
			where permission_name = 'readorfilterPatients'

			-- check whether the user has that permission
			if exists(select * from users.Role_Permissions
					  where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 0)
				begin
					print('You can read or filter patients')
					select 
						p.patient_id as 'ID',
						u.user_full_Name as 'FULL NAME',
						u.user_email as 'EMAIL',
						u.user_phone_num as 'PHONE NUMBER',
						u.user_gender as 'GENDER',
						u.user_DOB as 'DATE OF BIRTH',
						u.user_marital_status as 'MARITAL STATUS',
						u.user_address as 'ADDRESS',
						u.user_status as 'STATUS',
						p.patient_medical_record_number as 'RECORD NUMBER',
						p.patient_blood_group as 'BLOOD GROUP',
						p.patient_bmi as 'BMI',
						p.patient_emergency_name as 'NEXT OF KIN',
						p.patient_emergency_contact as 'NEXT OF KIN PHONE NUMBER'
					from users.Users as u
					left join users.Patients as p
					on u.user_id = p.user_id
					where
					( @firstname is null or user_full_Name like '%' + @firstname + '%') and
					( @lastname is null or user_full_Name like '%' + @lastname + '%') and
					( @user_email is null or user_email like '%' + @user_email + '%') and
					( @user_phone_num is null or user_phone_num like '%' + @user_phone_num + '%') and
					( @user_gender is null or user_gender = @user_gender) and
					( @user_DOB is null or user_DOB =  @user_DOB ) and
					( @user_marital_status is null or user_marital_status like '%' + @user_marital_status + '%') and
					( @user_address is null or user_address like '%' + @user_address + '%') and
					( @patient_medical_record_number is null or p.patient_medical_record_number like '%' + @patient_medical_record_number + '%') and
					( @patient_blood_group is null or p.patient_blood_group like '%' + @patient_blood_group + '%') and
					( @patient_bmi is null or p.patient_bmi like '%' + @patient_bmi + '%') and
					( @patient_emergency_name is null or p.patient_emergency_name like '%' + @patient_emergency_name + '%') and
					( @patient_emergency_contact is null or p.patient_emergency_contact like '%' + @patient_emergency_contact + '%')
					and p.is_deleted != 1
				end
			else
				begin
					set @readorfilter_patients_message = 'cannot read or filter patients';
					print 'You can not read or filter patients';
				end
		end try
		begin catch
			set @readorfilter_patients_message = ERROR_NUMBER();
			print '=====================================================';
			print 'ERROR OCCURED DURING READING OR FILTERING A PATIENT';
			print 'Error Message '+ERROR_MESSAGE();
			print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
			print 'Error State '+cast(ERROR_STATE() as nvarchar);
			print '=====================================================';
		end catch
end

-- trying it out
declare @result nvarchar(max);

exec users.readorfilterPatients 
@staffroleId = 101, -- @userId = 6,
-- @firstname = 'Benja', 
-- @lastname = 'Bisaso', @user_email = 'warid@gmail.com',
-- @user_phone_num = '+25675457233', @user_password_hash = 'xxxx!@33',
-- @user_gender = 'M', @user_DOB = '2000-01-16',
-- @user_marital_status = 'Single',
-- @user_address = 'Bukasa',
@readorfilter_patients_message = @result output;

print 'Result: ' + @result;





select 
	u.user_full_Name as 'FULL NAME',
	u.user_email as 'EMAIL',
	u.user_phone_num as 'PHONE NUMBER',
	u.user_gender as 'GENDER',
	u.user_DOB as 'DATE OF BIRTH',
	u.user_marital_status as 'MARITAL STATUS',
	u.user_address as 'ADDRESS',
	u.user_status as 'STATUS',
	p.patient_medical_record_number as 'RECORD NUMBER',
	p.patient_blood_group as 'BLOOD GROUP',
	p.patient_bmi as 'BMI',
	p.patient_emergency_name as 'NEXT OF KIN',
	p.patient_emergency_contact as 'NEXT OF KIN PHONE NUMBER'
from users.Users as u
	left join users.Patients as p
	on u.user_id = p.user_id	
where patient_id is not null

select * from users.Patients
