use HospitalERp;

-- dumy data
-- system roles
insert into users.Roles values
('triage', 'triage people');

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('updateTriageRec','You are able to update a triage record')

-- permissions for particular roles
insert into users.Role_Permissions values
(105,128)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure clinics.updateTriageRec
@staffroleId int, @patientId int, @triageId int,
@staffId int, @triageFindings nvarchar(30) = null,
@Deleted bit = null,
@update_triageRec_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'updateTriageRec'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
				  where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can update triage Rec')
				if exists(select * from clinics.Triage 
						  where staff_id = @staffId and patient_id = @patientId and triage_id = @triageId and is_deleted != 1)
					begin
						update clinics.Triage
						set
							triage_findings = isnull(@triageFindings, triage_findings),
							is_deleted = isnull(@Deleted, is_deleted),
							update_at = getdate()
						where staff_id = @staffId and patient_id = @patientId and triage_id = @triageId and is_deleted != 1
						set @update_triageRec_message = 'Triage record updated';
						print '=====================================================';
						print 'Triage record updated successfully';
					end
				else
					begin
						set @update_triageRec_message = 'Triage record dont exist';
					end
			end
		else
				begin
					set @update_triageRec_message = 'cannot update Triage record';
					print 'You can not update Triage record';
				end
	end try
	begin catch
			set @update_triageRec_message = ERROR_NUMBER();
			print '=====================================================';
			print 'ERROR OCCURED DURING UPDATING A TRIAGE RECORD';
			print 'Error Message '+ERROR_MESSAGE();
			print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
			print 'Error State '+cast(ERROR_STATE() as nvarchar);
			print '=====================================================';
		end catch

end

-- trying it out
declare @result nvarchar(max);

exec clinics.updateTriageRec
@staffroleId = 105, @patientId = 2, @triageId = 1,
@staffId = 1, 
@triageFindings = 'sweat till i start loosing weight',
@update_triageRec_message = @result output;

print 'Result: ' + @result;

select * from clinics.Triage

