use HospitalERp;

-- dumy data
-- system roles
insert into users.Roles values
('triage', 'triage people');

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('createDiagnosisRec','You are able to add a diagnosis record')

-- permissions for particular roles
insert into users.Role_Permissions values
(105,133)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure clinics.createDiagnosisRec
@staffroleId int, @patientId int, 
@staffId int, @conditionId int,
@diagnosisSymptoms text, @diagnosisNote text,
@create_diagnosisRec_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'createDiagnosisRec'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
				  where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				if exists(select * from users.Patients where patient_id = @patientId and is_deleted != 1) and
				   exists(select * from users.Staff where staff_id = @staffId and is_deleted != 1) and
				   exists(select * from clinics.Condition where condition_id = @conditionId and is_deleted != 1)
				   begin
				   insert into clinics.Diagnosis
				   (patient_id, doctor_id, condition_id, diagnosis_symptoms, diagnosis_note)
				   values
				   (@patientId, @staffId, @conditionId, @diagnosisSymptoms, @diagnosisNote)
				   set @create_diagnosisRec_message = 'diagnosis record added';
				   print '=====================================================';
				   print 'Diagnosis: added successfully';				
				end
				else
					begin
						set @create_diagnosisRec_message = 'Either patient or Doctor or Condition dont exist';
						print '=====================================================';
						print 'Either patient or Doctor or Condition dont exist';
					end
			end
		else
			begin
				set @create_diagnosisRec_message = 'cannot add a diagnosis record';
				print 'You can not add a diagnosis record';
			end
	end try
	begin catch
		set @create_diagnosisRec_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING ADDING A DIAGNOSIS RECORD';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end


-- trying it out
declare @result nvarchar(max);
exec clinics.createDiagnosisRec
@staffroleId = 105,  
@patientId = 8, 
@staffId = 1, 
@conditionId = 1,
@diagnosisSymptoms = 'huge stomach',
@diagnosisNote = 'had unprotected sex',
@create_diagnosisRec_message = @result output;

print 'Result: ' + @result;

select * from clinics.Diagnosis

select * from clinics.Condition