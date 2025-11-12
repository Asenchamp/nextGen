use HospitalERp;

-- dumy data
-- system roles
insert into users.Roles values
('triage', 'triage people');

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('updateDiagnosisRec','You are able to update a diagnosis record')

-- permissions for particular roles
insert into users.Role_Permissions values
(105,134)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure clinics.updateDiagnosisRec
@staffroleId int, @patientId int, 
@staffId int, @conditionId int = null, @diagnosisId int,
@diagnosisSymptoms text = null, @diagnosisNote text = null,
@Deleted bit = null,
@update_diagnosisRec_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'updateDiagnosisRec'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
				  where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can update diagnosis Rec')
				if exists(select * from clinics.Diagnosis 
						  where doctor_id = @staffId and patient_id = @patientId and diagnosis_id = @diagnosisId and is_deleted != 1)
					begin
						update clinics.Diagnosis
						set
							condition_id = isnull(@conditionId, condition_id),
							diagnosis_symptoms = isnull(@diagnosisSymptoms, diagnosis_symptoms),
							diagnosis_note = isnull(@diagnosisNote, diagnosis_note),
							is_deleted = isnull(@Deleted, is_deleted),
							update_at = getdate()
						where doctor_id = @staffId and patient_id = @patientId and diagnosis_id = @diagnosisId and is_deleted != 1
						set @update_diagnosisRec_message = 'Diagnosis record updated';
						print '=====================================================';
						print 'Diagnosis record updated successfully';
					end
				else
					begin
						set @update_diagnosisRec_message = 'Diagnosis record dont exist';
					end
			end
		else
				begin
					set @update_diagnosisRec_message = 'cannot update Diagnosis record';
					print 'You can not update Diagnosis record';
				end
	end try
	begin catch
			set @update_diagnosisRec_message = ERROR_NUMBER();
			print '=====================================================';
			print 'ERROR OCCURED DURING UPDATING A DIAGNOSIS RECORD';
			print 'Error Message '+ERROR_MESSAGE();
			print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
			print 'Error State '+cast(ERROR_STATE() as nvarchar);
			print '=====================================================';
		end catch
end

-- trying it out
declare @result nvarchar(max);

exec clinics.updateDiagnosisRec
@staffroleId = 105,
@patientId = 2, 
@staffId = 1, 
@conditionId = 5,
@diagnosisId = 1,
-- @diagnosisSymptoms = 'big stomach',
-- @diagnosisNote = 'had unprotected sex',
@update_diagnosisRec_message = @result output;

print 'Result: ' + @result;

select * from clinics.Diagnosis

