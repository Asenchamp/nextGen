use HospitalERp;

-- dumy data
-- system roles
insert into users.Roles values
('triage', 'triage people');

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('createTriageRec','You are able to add a triage record')

-- permissions for particular roles
insert into users.Role_Permissions values
(105,127)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure clinics.createTriageRec
@staffroleId int, @patientId int, 
@staffId int, @triageFindings nvarchar(30),
@create_triageRec_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'createTriageRec'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
				  where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				if exists(select * from users.Patients where patient_id = @patientId and is_deleted != 1) and
				   exists(select * from users.Staff where staff_id = @staffId and is_deleted != 1)
				   begin
				   insert into clinics.Triage
				   (staff_id, patient_id, triage_findings)
				   values
				   (@staffId, @patientId, @triageFindings)
				   set @create_triageRec_message = 'trage record added';
				   print '=====================================================';
				   print 'Appointment: added successfully';				
				end
				else
					begin
						set @create_triageRec_message = 'Either patient or Doctor dont exist';
						print '=====================================================';
						print 'Either patient or Doctor dont exist';
					end
			end
		else
			begin
				set @create_triageRec_message = 'cannot add a triage record';
				print 'You can not add a triage record';
			end
	end try
	begin catch
		set @create_triageRec_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING ADDING A TRIAGE RECORD';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end


-- trying it out
declare @result nvarchar(max);
exec clinics.createTriageRec
@staffroleId = 105,  
@patientId = 2, 
@staffId = 1, 
@triageFindings = 'cant reach me ma mum cant neither',
@create_triageRec_message = @result output;

print 'Result: ' + @result;

select * from clinics.Triage