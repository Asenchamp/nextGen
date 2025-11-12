use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('readorfilterLabresult','You are able to read or filter  lab results')

-- permissions for particular roles
insert into users.Role_Permissions values
(105,148)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure clinics.readorfilterLabresult
@staffroleId int,  @labrequestId int = null, 
@staffId int = null, @patientId int = null,
@readorfilter_labResult_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'readorfilterLabresult'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
				  where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can read or filter lab requests')
				select 
					u1.user_full_Name as 'PATIENT NAME',
					u1.user_gender as 'PATIENT GENDER',
					t.test_type_name as 'TEST NAME',
					lrs.labrequest_results as 'RESULTS',
					lrs.labresult_notes as 'RESULT NOTES',
					u2.user_full_Name as 'DOCTOR NAME',
					u3.user_full_Name as 'TECHNICIAN NAME',
					lrs.sample_label as 'SAMPLE'
				from clinics.Labresults as lrs
				left join clinics.Labrequests as lrq
				on lrs.labrequest_id = lrq.labrequest_id
				left join users.Patients as p
				on lrq.patient_id = p.patient_id
				left join users.Users as u1
				on p.user_id = u1.user_id
				left join users.Staff as s
				on lrq.doctor_id = s.staff_id
				left join users.Users as u2
				on s.user_id = u2.user_id
				left join users.Staff as s1
				on lrs.technician_id = s1.staff_id
				left join users.Users as u3
				on s1.user_id = u3.user_id
				left join clinics.Testtype as t
				on lrq.test_type_id = t.test_type_id
				where 
				( @patientId is null or lrq.patient_id = @patientId ) and
				( @staffId is null or lrs.technician_id = @staffId ) and
				( @labrequestId is null or lrq.labrequest_id = @labrequestId ) and
				lrs.is_deleted != 1;
			end
		else
			begin
				set @readorfilter_labResult_message = 'cannot read or filter lab results';
				print 'You can not read or filter lab results';
			end
	end try
	begin catch
		set @readorfilter_labResult_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING GETTING A LAB RESULT';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

-- trying it out
declare @result nvarchar(max);

exec clinics.readorfilterLabresult
@staffroleId = 105,
-- @patientId = 2, 
-- @staffId = 1,
-- @labrequestId = 1,
@readorfilter_labResult_message = @result output;

print 'Result: ' + @result;


select 
	u1.user_full_Name as 'PATIENT NAME',
	u1.user_gender as 'PATIENT GENDER',
	t.test_type_name as 'TEST NAME',
	lrs.labrequest_results as 'RESULTS',
	lrs.labresult_notes as 'RESULT NOTES',
	u2.user_full_Name as 'DOCTOR NAME',
	u3.user_full_Name as 'TECHNICIAN NAME',
	smp.sample_label as 'SAMPLE'
from clinics.Labresults as lrs
left join clinics.Labrequests as lrq
on lrs.labrequest_id = lrq.labrequest_id
left join users.Patients as p
on lrq.patient_id = p.patient_id
left join users.Users as u1
on p.user_id = u1.user_id
left join users.Staff as s
on lrq.doctor_id = s.staff_id
left join users.Users as u2
on s.user_id = u2.user_id
left join users.Staff as s1
on lrs.technician_id = s1.staff_id
left join users.Users as u3
on s1.user_id = u3.user_id
left join clinics.Testtype as t
on lrq.test_type_id = t.test_type_id
left join clinics.Samples as smp
on lrs.sample_id = smp.sample_id


select * from clinics.Labresults


