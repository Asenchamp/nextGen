use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('readorfilterLabrequest','You are able to read or filter  lab requests')

-- permissions for particular roles
insert into users.Role_Permissions values
(105,144)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure clinics.readorfilterLabrequest
@staffroleId int, @patientId int = null, 
@staffId int = null, @labrequestId int = null,
@readorfilter_labRequest_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'readorfilterLabrequest'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
				  where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can read or filter lab requests')
				select 
					u1.user_full_Name as 'PATIENT NAME',
					u1.user_gender as 'PATIENT GENDER',
					t.test_type_name as 'TEST NAME',
					u2.user_full_Name as 'DOCTOR NAME',
					l.labrequest_notes as 'DOCTOR TEST NOTES'
				from clinics.Labrequests as l
				left join users.Patients as p
				on l.patient_id = p.patient_id
				left join users.Users as u1
				on p.user_id = u1.user_id
				left join users.Staff as s
				on l.doctor_id = s.staff_id
				left join users.Users as u2
				on s.user_id = u2.user_id
				left join clinics.Testtype as t
				on l.test_type_id = t.test_type_id
				where 
				( @patientId is null or l.patient_id = @patientId ) and
				( @staffId is null or l.doctor_id = @staffId ) and
				( @labrequestId is null or l.labrequest_id = @labrequestId ) and
				l.is_deleted != 1;
			end
		else
			begin
				set @readorfilter_labRequest_message = 'cannot read or filter lab requests';
				print 'You can not read or filter lab requests';
			end
	end try
	begin catch
		set @readorfilter_labRequest_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING GETTING A LAB REQUEST';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

-- trying it out
declare @result nvarchar(max);

exec clinics.readorfilterLabrequest
@staffroleId = 105,
-- @patientId = 2, 
@staffId = 1,
@labrequestId = 1,
@readorfilter_labRequest_message = @result output;

print 'Result: ' + @result;


select 
	u1.user_full_Name as 'PATIENT NAME',
	u1.user_gender as 'PATIENT GENDER',
	t.test_type_name as 'TEST NAME',
	u2.user_full_Name as 'DOCTOR NAME',
	l.labrequest_notes as 'DOCTOR TEST NOTES'
from clinics.Labrequests as l
left join users.Patients as p
on l.patient_id = p.patient_id
left join users.Users as u1
on p.user_id = u1.user_id
left join users.Staff as s
on l.doctor_id = s.staff_id
left join users.Users as u2
on s.user_id = u2.user_id
left join clinics.Testtype as t
on l.test_type_id = t.test_type_id



