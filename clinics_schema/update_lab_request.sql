use HospitalERp;

-- dumy data
-- system roles
insert into users.Roles values
('triage', 'triage people');

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('updateLabrequest','You are able to update a lab request')

-- permissions for particular roles
insert into users.Role_Permissions values
(105,143)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure clinics.updateLabrequest
@staffroleId int, @patientId int, 
@staffId int, @testtypeId int = null, @labrequestId int,
@labrequestNotes varchar(100) = null, @Deleted bit = null,
@update_labRequest_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'updateLabrequest'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
				  where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can update a lab request')
				if exists(select * from clinics.Labrequests 
						  where doctor_id = @staffId and patient_id = @patientId and labrequest_id = @labrequestId and is_deleted != 1)
					begin
						update clinics.Labrequests
						set
							test_type_id = isnull(@testtypeId, test_type_id),
							labrequest_notes = isnull(@labrequestNotes, labrequest_notes)
						where doctor_id = @staffId and patient_id = @patientId and labrequest_id = @labrequestId and is_deleted != 1
						set @update_labRequest_message = 'Lab request updated';
						print '=====================================================';
						print 'Lab request updated successfully';
					end
				else
					begin
						set @update_labRequest_message = 'Lab request dont exist';
					end
			end
		else
				begin
					set @update_labRequest_message = 'cannot update Lab request';
					print 'You can not update Lab request';
				end
	end try
	begin catch
			set @update_labRequest_message = ERROR_NUMBER();
			print '=====================================================';
			print 'ERROR OCCURED DURING UPDATING A LAB REQUEST';
			print 'Error Message '+ERROR_MESSAGE();
			print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
			print 'Error State '+cast(ERROR_STATE() as nvarchar);
			print '=====================================================';
		end catch
end

-- trying it out
declare @result nvarchar(max);

exec clinics.updateLabrequest
@staffroleId = 105,
@patientId = 2, 
@staffId = 1, 
-- @testtypeId = 3,
@labrequestId = 1,
-- @labrequestNotes = 'big stomach',
@update_labRequest_message = @result output;

print 'Result: ' + @result;

select * from clinics.Labrequests

