use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('readorfilterClipboard','You are able to read or filter clip board records')

-- permissions for particular roles
insert into users.Role_Permissions values
(106,164)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

-- readorfilter users stored procedure
create or alter procedure accommodation.readorfilterClipboard
@staffroleId int, 
@patientId int = null,
@admissionId int = null,
@staffId int = null,
@readorfilter_Clipboard_message nvarchar(max) output
with encryption
as
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'readorfilterClipboard'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
					where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can read or filter clip board record')
				select 
					u.user_full_Name as 'PATIENT NAME',
					u.user_gender as 'PATIENT GENDER',
					u1.user_full_Name as 'CLIP BOARD DOCTOR NAME',
					a.admission_notes as 'ADMISSION NOTES',
					c.findings as 'FINDINGS',
					c.created_at as 'TIME',
					b.bed_number as 'BED NUMBER'
				from accommodation.ClipBoard as c
				left join users.Staff as s
				on c.staff_id = s.staff_id
				left join users.Users as u1
				on s.user_id = u1.user_id
				left join accommodation.Admissions as a
				on c.admission_id = a.admission_id
				left join users.Patients as p
				on a.patient_id = p.patient_id
				left join users.Users as u
				on p.user_id = u.user_id
				left join accommodation.Beds as b
				on a.bed_id = b.bed_id
				where
				( @staffId is null or c.staff_id = @staffId ) and
				( @patientId is null or a.patient_id = @patientId ) and
				( @admissionId is null or c.admission_id = @admissionId ) and
				c.is_deleted != 1;
			end
		else
			begin
				set @readorfilter_Clipboard_message = 'cannot read or filter clip board records';
				print 'You can not read or filter clip board records';
			end
	end try
	begin catch
		set @readorfilter_Clipboard_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING READING OR FILTERING CLIP BOARD RECORDS';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

go

-- trying it out
declare @result nvarchar(max);
exec accommodation.readorfilterClipboard 
@staffroleId = 106, 
@patientId = null,
@admissionId = null,
@staffId = null,
@readorfilter_Clipboard_message = @result output;

print 'Result: ' + @result;



select 
	u.user_full_Name as 'PATIENT NAME',
	u.user_gender as 'PATIENT GENDER',
	u1.user_full_Name as 'CLIP BOARD DOCTOR NAME',
	a.admission_notes as 'ADMISSION NOTES',
	c.findings as 'FINDINGS',
	c.created_at as 'TIME',
	b.bed_number as 'BED NUMBER'
from accommodation.ClipBoard as c
left join users.Staff as s
on c.staff_id = s.staff_id
left join users.Users as u1
on s.user_id = u1.user_id
left join accommodation.Admissions as a
on c.admission_id = a.admission_id
left join users.Patients as p
on a.patient_id = p.patient_id
left join users.Users as u
on p.user_id = u.user_id
left join accommodation.Beds as b
on a.bed_id = b.bed_id

select * from accommodation.ClipBoard

