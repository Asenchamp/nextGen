use HospitalERp;

-- dumy data
-- system roles
insert into users.Roles values
('triage', 'triage people');

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('updateSampleRec','You are able to update a sample record')

-- permissions for particular roles
insert into users.Role_Permissions values
(105,140)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure clinics.updateSampleRec
@staffroleId int, @patientId int, 
@sampleId int, @sampleLabel nvarchar(30) = null,
@Deleted bit = null,
@update_sampleRec_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'updateSampleRec'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
				  where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can update sample Rec')
				if exists(select * from clinics.Samples where sample_id = @sampleId and patient_id = @patientId and is_deleted != 1 )
					begin
						update clinics.Samples
						set
							sample_label = isnull(@sampleLabel, sample_label),
							is_deleted = isnull(@Deleted, is_deleted),
							update_at = getdate()
						where sample_id = @sampleId and patient_id = @patientId and is_deleted != 1
						set @update_sampleRec_message = 'Sample record updated';
						print '=====================================================';
						print 'Sample record updated successfully';
					end
				else
					begin
						set @update_sampleRec_message = 'Sample record dont exist';
					end
			end
		else
				begin
					set @update_sampleRec_message = 'cannot update Sample record';
					print 'You can not update Sample record';
				end
	end try
	begin catch
			set @update_sampleRec_message = ERROR_NUMBER();
			print '=====================================================';
			print 'ERROR OCCURED DURING UPDATING A SAMPLE RECORD';
			print 'Error Message '+ERROR_MESSAGE();
			print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
			print 'Error State '+cast(ERROR_STATE() as nvarchar);
			print '=====================================================';
		end catch
end

-- trying it out
declare @result nvarchar(max);

exec clinics.updateSampleRec
@staffroleId = 105,  
@patientId = 2, 
@sampleId = 1,
@sampleLabel = XXX1, 
@update_sampleRec_message = @result output;

print 'Result: ' + @result;

select * from clinics.Samples

