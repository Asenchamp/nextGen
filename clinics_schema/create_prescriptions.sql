use HospitalERp;

-- dumy data
-- system roles
insert into users.Roles values
('triage', 'triage people');

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('createPrescription','You are able to add a prescription')

-- permissions for particular roles
insert into users.Role_Permissions values
(105,149)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure clinics.createPrescription
@staffroleId int, @staffId int, 
@diagnosisId int, @patientId int, @Drug nvarchar(30),
@Dose nvarchar(100), @Frequency nvarchar(100),
@prescriptionDays int,
@drugsQuantity int, @prescriptionNotes text,
@create_prescription_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'createPrescription'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
				  where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				if exists(select * from clinics.Diagnosis where diagnosis_id = @diagnosisId and is_deleted != 1) and
				   exists(select * from users.Staff where staff_id = @staffId and is_deleted != 1) and
				   exists(select * from users.Patients where patient_id = @patientId and is_deleted != 1)
				   begin
					   -- compare patient in diadnosis with patient being prescribed
					   declare @diagnosisPat int
					   select @diagnosisPat = patient_id from clinics.Diagnosis
					   where diagnosis_id = @diagnosisId and is_deleted != 1

					   if @diagnosisPat != @patientId
							begin
								set @create_prescription_message = 'diagnosis patient not the same as patient being prescribed';
								print 'diagnosis patient not the same as patient being prescribed';
							end
						else
							begin
								insert into clinics.Prescriptions
								(staff_id, diagnosis_id, patient_id, drug, dose, frequency, prescription_days, drugs_quantity, prescription_notes)
								values
								(@staffId, @diagnosisId, @patientId, @Drug, @Dose, @Frequency, @prescriptionDays, @drugsQuantity, @prescriptionNotes)
								set @create_prescription_message = 'prescription added';
								print '=====================================================';
								print 'Prescription: added successfully';
							end				   			
				end
				else
					begin
						set @create_prescription_message = 'Either Diagnosis or Doctor or Patient dont exist';
						print '=====================================================';
						print 'Either Diagnosis or Doctor or Patient dont exist';
					end
			end
		else
			begin
				set @create_prescription_message = 'cannot add a Prescription';
				print 'You can not add a Prescription';
			end
	end try
	begin catch
		set @create_prescription_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING ADDING A PRESCRIPTION';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end


-- trying it out
declare @result nvarchar(max);
exec clinics.createPrescription
@staffroleId = 105,  
@staffId = 1, 
@diagnosisId = 2, @patientId = 8, @Drug = null,
@Dose = null, @Frequency = null,
@prescriptionDays = null,
@drugsQuantity = null, @prescriptionNotes = null,
@create_prescription_message = @result output;

print 'Result: ' + @result;

select * from clinics.Prescriptions

select * from clinics.Diagnosis

select * from clinics.Labrequests

select * from users.Patients

