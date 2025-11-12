use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('readorfilterDiagnosis','You are able to read or filter  diagnosis records')

-- permissions for particular roles
insert into users.Role_Permissions values
(105,135)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure clinics.readorfilterDiagnosis
@staffroleId int, @patientId int = null, 
@staffId int = null, @conditionId int = null,
@readorfilter_diagnosisRec_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'readorfilterDiagnosis'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
				  where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can read or filter diagnosis records')
				select 
					u1.user_full_Name as 'PATIENT NAME',
					u1.user_gender as 'PATIENT GENDER',
					c.condition_name as 'CONDITION NAME',
					d.diagnosis_symptoms as 'SYMPTOMS',
					d.diagnosis_note as 'NOTE',
					c.condition_status as 'CONDITION STATUS',
					u2.user_full_Name as 'DOCTOR NAME'
				from clinics.Diagnosis as d
				left join users.Patients as p
				on d.patient_id = p.patient_id
				left join users.Users as u1
				on p.user_id = u1.user_id
				left join users.Staff as s
				on d.doctor_id = s.staff_id
				left join users.Users as u2
				on s.user_id = u2.user_id
				left join clinics.Condition as c
				on d.condition_id = c.condition_id
				where 
				( @patientId is null or d.patient_id = @patientId ) and
				( @staffId is null or d.doctor_id = @staffId ) and
				( @conditionId is null or d.condition_id = @conditionId ) and
				d.is_deleted != 1;
			end
		else
			begin
				set @readorfilter_diagnosisRec_message = 'cannot read or filter diagnosis records';
				print 'You can not read or filter diagnosis records';
			end
	end try
	begin catch
		set @readorfilter_diagnosisRec_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING GETTING A DIAGNOSIS RECORD';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

-- trying it out
declare @result nvarchar(max);

exec clinics.readorfilterDiagnosis
@staffroleId = 105,
@patientId = 2, 
-- @staffId = 1, 
-- @conditionId = null,
@readorfilter_diagnosisRec_message = @result output;

print 'Result: ' + @result;


select 
	u1.user_full_Name as 'PATIENT NAME',
	u1.user_gender as 'PATIENT GENDER',
	c.condition_name as 'CONDITION NAME',
	d.diagnosis_symptoms as 'SYMPTOMS',
	d.diagnosis_note as 'NOTE',
	c.condition_status as 'CONDITION STATUS',
	u2.user_full_Name as 'DOCTOR NAME'
from clinics.Diagnosis as d
left join users.Patients as p
on d.patient_id = p.patient_id
left join users.Users as u1
on p.user_id = u1.user_id
left join users.Staff as s
on d.doctor_id = s.staff_id
left join users.Users as u2
on s.user_id = u2.user_id
left join clinics.Condition as c
on d.condition_id = c.condition_id

select * from users.Patients

select * from users.Staff
