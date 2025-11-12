use HospitalERp;

-- dumy data
-- system roles
insert into users.Roles values
('triage', 'triage people');

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('createLabrequest','You are able to request a lab test')

-- permissions for particular roles
insert into users.Role_Permissions values
(105,142)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure clinics.createLabrequest
@staffroleId int, @patientId int, 
@staffId int, @testtypeId int,
@labrequestNotes varchar(100),
@create_labRequest_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'createLabrequest'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
				  where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				if exists(select * from users.Patients where patient_id = @patientId and is_deleted != 1) and
				   exists(select * from users.Staff where staff_id = @staffId and is_deleted != 1) and
				   exists(select * from clinics.Testtype where test_type_id = @testtypeId and is_deleted != 1)
				   begin
				   insert into clinics.Labrequests
				   (patient_id, doctor_id, test_type_id, labrequest_notes)
				   values
				   (@patientId, @staffId, @testtypeId, @labrequestNotes)
				   set @create_labRequest_message = 'lab request added';
				   print '=====================================================';
				   print 'Lab request: added successfully';				
				end
				else
					begin
						set @create_labRequest_message = 'Either patient or Doctor or Test type dont exist';
						print '=====================================================';
						print 'Either patient or Doctor or Test type dont exist';
					end
			end
		else
			begin
				set @create_labRequest_message = 'cannot add a lab request';
				print 'You can not add a lab request';
			end
	end try
	begin catch
		set @create_labRequest_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING ADDING A LAB REQUEST';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end


-- trying it out
declare @result nvarchar(max);
exec clinics.createLabrequest
@staffroleId = 105,  
@patientId = 2, 
@staffId = 1, 
@testtypeId = 1,
@labrequestNotes = 'use the blood',
@create_labRequest_message = @result output;

print 'Result: ' + @result;

select * from clinics.Testtype

select * from clinics.Labrequests

