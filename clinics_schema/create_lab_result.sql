use HospitalERp;

-- dumy data
-- system roles
insert into users.Roles values
('triage', 'triage people');

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('createLabresult','You are able to add a lab result')

-- permissions for particular roles
insert into users.Role_Permissions values
(105,145)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure clinics.createLabresult
@staffroleId int, @labrequestId int, 
@staffId int, @sampleId int,
@labrequestResults varchar(100), @labresultNotes varchar(100),
@create_labResult_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'createLabresult'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
				  where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				if exists(select * from clinics.Labrequests where labrequest_id = @labrequestId and is_deleted != 1) and
				   exists(select * from users.Staff where staff_id = @staffId and is_deleted != 1) and
				   exists(select * from clinics.Samples where sample_id = @sampleId and is_deleted != 1)
				   begin
					   -- compare patient in sample and labrequest
					   declare @samplePat int
					   select @samplePat = patient_id from clinics.Samples
					   where sample_id = @sampleId and is_deleted != 0

					   declare @requestPat int
					   select @requestPat = patient_id from clinics.Labrequests
					   where labrequest_id = @labrequestId and is_deleted != 1
					   if @samplePat != @requestPat
							begin
								set @create_labResult_message = 'lab request patient not the same as sample patient';
								print 'lab request patient not the same as sample patient';
							end
						else
							begin
								insert into clinics.Labresults
								(labrequest_id, technician_id, sample_label, labrequest_results, labresult_notes)
								values
								(@labrequestId, @staffId, @sampleId, @labrequestResults, @labresultNotes)
								set @create_labResult_message = 'lab result added';
								print '=====================================================';
								print 'Lab result: added successfully';	
							end				   			
				end
				else
					begin
						set @create_labResult_message = 'Either labrequest or Doctor or Sample dont exist';
						print '=====================================================';
						print 'Either labrequest or Doctor or Sample dont exist';
					end
			end
		else
			begin
				set @create_labResult_message = 'cannot add a lab result';
				print 'You can not add a lab result';
			end
	end try
	begin catch
		set @create_labResult_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING ADDING A LAB RESULT';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end


-- trying it out
declare @result nvarchar(max);
exec clinics.createLabresult
@staffroleId = 105,  
@labrequestId = 1, 
@staffId = 1, 
@sampleId = 1,
@labrequestResults = 'negative',
@labresultNotes = null,
@create_labResult_message = @result output;

print 'Result: ' + @result;

select * from clinics.Labresults

select * from clinics.Samples

select * from clinics.Labrequests

