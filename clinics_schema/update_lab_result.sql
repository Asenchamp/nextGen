use HospitalERp;

-- dumy data
-- system roles
insert into users.Roles values
('triage', 'triage people');

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('updateLabresult','You are able to update a lab result')

-- permissions for particular roles
insert into users.Role_Permissions values
(105,147)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure clinics.updateLabresult
@staffroleId int, @labrequestId int, @labresultId int,
@staffId int, @sampleId int = null,
@labrequestResults varchar(100) = null, @labresultNotes varchar(100) = null,
@Deleted bit = null,
@update_labResult_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'updateLabresult'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
				  where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can update a lab result')
				if exists(select * from clinics.Labresults 
						  where technician_id = @staffId and labresult_id = @labresultId and labrequest_id = @labrequestId and is_deleted != 1)
					begin
						update clinics.Labresults
						set
							sample_label = isnull(@sampleId, sample_label),
							labrequest_results = isnull(@labrequestResults, labrequest_results),
							labresult_notes = isnull(@labresultNotes, labresult_notes)
						where technician_id = @staffId and labresult_id = @labresultId and labrequest_id = @labrequestId and is_deleted != 1
						set @update_labResult_message = 'Lab result updated';
						print '=====================================================';
						print 'Lab result updated successfully';
					end
				else
					begin
						set @update_labResult_message = 'Lab result dont exist';
					end
			end
		else
				begin
					set @update_labResult_message = 'cannot update Lab result';
					print 'You can not update Lab result';
				end
	end try
	begin catch
			set @update_labResult_message = ERROR_NUMBER();
			print '=====================================================';
			print 'ERROR OCCURED DURING UPDATING A LAB RESULT';
			print 'Error Message '+ERROR_MESSAGE();
			print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
			print 'Error State '+cast(ERROR_STATE() as nvarchar);
			print '=====================================================';
		end catch
end

-- trying it out
declare @result nvarchar(max);

exec clinics.updateLabresult
@staffroleId = 105,
@labrequestId = 1, 
@labresultId = 1,
@staffId = 1, 
-- @sampleId = 1,
@labrequestResults = 'negative',
@labresultNotes = 'safe',
@update_labResult_message = @result output;

print 'Result: ' + @result;

select * from clinics.Labresults

