use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('readorfilterPrescription','You are able to read or filter  prescriptions')

-- permissions for particular roles
insert into users.Role_Permissions values
(105,151)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure clinics.readorfilterPrescription
@staffroleId int,  @diagnosisId int = null, 
@staffId int = null, @patientId int = null,
@readorfilter_prescription_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'readorfilterPrescription'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
				  where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can read or filter prescriptions')
				select 
					u1.user_full_Name as 'PATIENT NAME',
					u1.user_gender as 'PATIENT GENDER',
					u2.user_full_Name as 'DOCTOR NAME',
					c.condition_name as 'CONDITION',
					prs.drug as 'DRUG',
					prs.dose as 'DOSE',
					prs.frequency as 'FREQUENCY',
					prs.prescription_days as 'DAYS',
					prs.drugs_quantity as 'QUANTITY',
					prs.prescription_notes as 'NOTES'
				from clinics.Prescriptions as prs
				left join users.Patients as p
				on prs.patient_id = p.patient_id
				left join users.Users as u1
				on p.user_id = u1.user_id
				left join users.Staff as s
				on prs.staff_id = s.staff_id
				left join users.Users as u2
				on s.user_id = u2.user_id
				left join clinics.Diagnosis as d
				on prs.diagnosis_id = d.diagnosis_id
				left join clinics.Condition as c
				on d.condition_id = c.condition_id 
				where 
				( @patientId is null or prs.patient_id = @patientId ) and
				( @staffId is null or prs.staff_id = @staffId ) and
				( @diagnosisId is null or prs.diagnosis_id = @diagnosisId ) and 
				prs.is_deleted != 1;
			end
		else
			begin
				set @readorfilter_prescription_message = 'cannot read or filter prescriptions';
				print 'You can not read or filter prescriptions';
			end
	end try
	begin catch
		set @readorfilter_prescription_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING GETTING A PRESCRIPTION';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

-- trying it out
declare @result nvarchar(max);

exec clinics.readorfilterPrescription
@staffroleId = 105,
-- @patientId = 2, 
-- @staffId = 1,
-- @diagnosisId = 1,
@readorfilter_prescription_message = @result output;

print 'Result: ' + @result;


select 
	u1.user_full_Name as 'PATIENT NAME',
	u1.user_gender as 'PATIENT GENDER',
	u2.user_full_Name as 'DOCTOR NAME',
	c.condition_name as 'CONDITION',
	prs.drug as 'DRUG',
	prs.dose as 'DOSE',
	prs.frequency as 'FREQUENCY',
	prs.prescription_days as 'DAYS',
	prs.drugs_quantity as 'QUANTITY',
	prs.prescription_notes as 'NOTES'
from clinics.Prescriptions as prs
left join users.Patients as p
on prs.patient_id = p.patient_id
left join users.Users as u1
on p.user_id = u1.user_id
left join users.Staff as s
on prs.staff_id = s.staff_id
left join users.Users as u2
on s.user_id = u2.user_id
left join clinics.Diagnosis as d
on prs.diagnosis_id = d.diagnosis_id
left join clinics.Condition as c
on d.condition_id = c.condition_id 



select * from clinics.Prescriptions

select * from clinics.Diagnosis


