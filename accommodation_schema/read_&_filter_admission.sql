use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('readorfilterAdmission','You are able to read or filter admissions')

-- permissions for particular roles
insert into users.Role_Permissions values
(106,161)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

-- readorfilter users stored procedure
create or alter procedure accommodation.readorfilterAdmission
@staffroleId int, 
@staffId int = null,
@patientId int = null,
@bedId int = null,
@admissionNotes nvarchar(100) = null,
@readorfilter_Admission_message nvarchar(max) output
with encryption
as
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'readorfilterAdmission'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
					where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can read or filter admission')
				select 
					u.user_full_Name as 'PATIENT NAME',
					u.user_gender as 'PATIENT GENDER',
					u1.user_full_Name as 'DOCTOR NAME',
					a.admission_notes as 'ADMISSION NOTES',
					a.admission_created_at as 'ADMISSION DATE',
					b.bed_number as 'BED NUMBER'
				from accommodation.Admissions as a
				left join users.Patients as p
				on a.patient_id = p.patient_id
				left join users.Users as u
				on p.user_id = u.user_id
				left join users.Staff as s
				on a.staff_id = s.staff_id
				left join users.Users as u1
				on s.user_id = u1.user_id
				left join accommodation.Beds as b
				on a.bed_id = b.bed_id
				where
				( @staffId is null or a.staff_id = @staffId ) and
				( @patientId is null or a.patient_id = @patientId ) and
				( @admissionNotes is null or a.admission_notes like '%' + @admissionNotes + '%') and
				( @bedId is null or a.bed_id = @bedId ) and
				a.is_deleted != 1;
			end
		else
			begin
				set @readorfilter_Admission_message = 'cannot read or filter admissions';
				print 'You can not read or filter admissions';
			end
	end try
	begin catch
		set @readorfilter_Admission_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING READING OR FILTERING ADMISSIONS';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

go

-- trying it out
declare @result nvarchar(max);
exec accommodation.readorfilterAdmission 
@staffroleId = 106, 
@staffId = null,
@patientId = null,
@bedId = null,
@admissionNotes = null,
@readorfilter_Admission_message = @result output;

print 'Result: ' + @result;



select 
	u.user_full_Name as 'PATIENT NAME',
	u.user_gender as 'PATIENT GENDER',
	u1.user_full_Name as 'DOCTOR NAME',
	a.admission_notes as 'ADMISSION NOTES',
	a.admission_created_at as 'ADMISSION DATE',
	b.bed_number as 'BED NUMBER'
from accommodation.Admissions as a
left join users.Patients as p
on a.patient_id = p.patient_id
left join users.Users as u
on p.user_id = u.user_id
left join users.Staff as s
on a.staff_id = s.staff_id
left join users.Users as u1
on s.user_id = u1.user_id
left join accommodation.Beds as b
on a.bed_id = b.bed_id


select * from accommodation.Admissions