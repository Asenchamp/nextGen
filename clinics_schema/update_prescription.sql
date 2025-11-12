use HospitalERp;

-- dumy data
-- system roles
insert into users.Roles values
('triage', 'triage people');

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('updatePrescription','You are able to update a prescription')

-- permissions for particular roles
insert into users.Role_Permissions values
(105,150)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure clinics.updatePrescription
@staffroleId int, @staffId int, @prescriptionId int,
@diagnosisId int, @patientId int, @Drug nvarchar(30),
@Dose nvarchar(100) = null, @Frequency nvarchar(100) = null,
@prescriptionDays int = null, @Deleted bit = null,
@drugsQuantity int = null, @prescriptionNotes text = null,
@update_prescription_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'updatePrescription'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
				  where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can update a Prescription')
				if exists(select * from clinics.Prescriptions 
						  where staff_id = @staffId and patient_id = @patientId and prescription_id = @prescriptionId and is_deleted != 0)
					begin
					   -- compare patient in diadnosis with patient being prescribed
					   declare @diagnosisPat int
					   select @diagnosisPat = patient_id from clinics.Diagnosis
					   where diagnosis_id = @diagnosisId and is_deleted != 1

					   if @diagnosisPat != @patientId
							begin
								set @update_prescription_message = 'diagnosis patient not the same as patient being prescribed';
								print 'diagnosis patient not the same as patient being prescribed';
							end
						else
							begin
								update clinics.Prescriptions
								set
									diagnosis_id = isnull(@diagnosisId, diagnosis_id),
									drug = isnull(@Drug, drug),
									dose = isnull(@Dose, dose),
									frequency = isnull(@Frequency, frequency),
									prescription_days = isnull(@prescriptionDays, prescription_days),
									drugs_quantity = isnull(@drugsQuantity, drugs_quantity),
									prescription_notes = isnull(@prescriptionNotes, prescription_notes)
								where staff_id = @staffId and patient_id = @patientId and prescription_id = @prescriptionId and is_deleted != 1
								set @update_prescription_message = 'Prescription updated';
								print '=====================================================';
								print 'Prescription updated successfully';
							end			   			
				end
				else
					begin
						set @update_prescription_message = 'Prescription dont exist';
					end
			end
		else
				begin
					set @update_prescription_message = 'cannot update Prescription';
					print 'You can not update Prescription';
				end
	end try
	begin catch
			set @update_prescription_message = ERROR_NUMBER();
			print '=====================================================';
			print 'ERROR OCCURED DURING UPDATING A PRESCRIPTION';
			print 'Error Message '+ERROR_MESSAGE();
			print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
			print 'Error State '+cast(ERROR_STATE() as nvarchar);
			print '=====================================================';
		end catch
end

-- trying it out
declare @result nvarchar(max);

exec clinics.updatePrescription
@staffroleId = 105,  
@staffId = 1, @prescriptionId = 1,
@diagnosisId = 1, @patientId = 2, @Drug = 'alcohol',
@Dose = null, @Frequency = null,
@prescriptionDays = null,
@drugsQuantity = null, @prescriptionNotes = null,
@update_prescription_message = @result output;

print 'Result: ' + @result;

select * from clinics.Prescriptions

select * from users.Patients

