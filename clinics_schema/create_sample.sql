use HospitalERp;

-- dumy data
-- system roles
insert into users.Roles values
('triage', 'triage people');

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('createSample','You are able to add a sample record')

-- permissions for particular roles
insert into users.Role_Permissions values
(105,139)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure clinics.createSample
@staffroleId int, @patientId int, 
@sampleLabel nvarchar(30),
@create_sampleRec_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'createSample'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
				  where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				if exists(select * from users.Patients where patient_id = @patientId and is_deleted != 1) 
				   begin
				   insert into clinics.Samples
				   (patient_id, sample_label)
				   values
				   (@patientId, @sampleLabel)
				   set @create_sampleRec_message = 'Sample record added';
				   print '=====================================================';
				   print 'Sample: added successfully';				
				end
				else
					begin
						set @create_sampleRec_message = 'Patient dont exist';
						print '=====================================================';
						print 'Patient dont exist';
					end
			end
		else
			begin
				set @create_sampleRec_message = 'cannot add a sample record';
				print 'You can not add a sample record';
			end
	end try
	begin catch
		set @create_sampleRec_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING ADDING A SAMPLE RECORD';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end


-- trying it out
declare @result nvarchar(max);
exec clinics.createSample
@staffroleId = 105,  
@patientId = 8, 
@sampleLabel = 1, 
@create_sampleRec_message = @result output;

print 'Result: ' + @result;

select * from clinics.Samples

select * from users.Users

select * from users.Staff

select * from users.Patients

