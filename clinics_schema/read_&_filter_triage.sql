use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('readorfilterTriage','You are able to read or filter  triage records')

-- permissions for particular roles
insert into users.Role_Permissions values
(105,129)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure clinics.readorfilterTriage
@staffroleId int, @patientId int = null,
@staffId int = null, @createdAt date = null,
@readorfilter_triageRec_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'readorfilterTriage'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
				  where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can read or filter triage records')
				select 
					u1.user_full_Name as 'PATIENT NAME',
					u1.user_gender as 'PATIENT GENDER',
					t.triage_findings as 'TRIAGE RECORD',
					t.created_at as 'DATE CREATED',
					u2.user_full_Name as 'DOCTOR NAME'
				from clinics.Triage as t
				left join users.Patients as p
				on t.patient_id = p.patient_id
				left join users.Users as u1
				on p.user_id = u1.user_id
				left join users.Staff as s
				on t.staff_id = s.staff_id
				left join users.Users as u2
				on s.user_id = u2.user_id
				where 
				( @patientId is null or t.patient_id = @patientId ) and
				( @staffId is null or t.staff_id = @staffId ) and
				( @createdAt is null or t.created_at = @createdAt) and
				t.is_deleted != 1;
			end
		else
			begin
				set @readorfilter_triageRec_message = 'cannot read or filter triage records';
				print 'You can not read or filter triage records';
			end
	end try
	begin catch
		set @readorfilter_triageRec_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING GETTING A TRIAGE RECORD';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

-- trying it out
declare @result nvarchar(max);

exec clinics.readorfilterTriage
@staffroleId = 105,
-- @patientId = 2, 
@staffId = 1, 
@createdAt = null,
@readorfilter_triageRec_message = @result output;

print 'Result: ' + @result;





select 
	u1.user_full_Name as 'PATIENT NAME',
	u1.user_gender as 'PATIENT GENDER',
	t.triage_findings as 'TRIAGE RECORD',
	t.created_at as 'DATE CREATED',
	u2.user_full_Name as 'DOCTOR NAME'
from clinics.Triage as t
left join users.Patients as p
on t.patient_id = p.patient_id
left join users.Users as u1
on p.user_id = u1.user_id
left join users.Staff as s
on t.staff_id = s.staff_id
left join users.Users as u2
on s.user_id = u2.user_id
where 
t.patient_id = 2 or t.staff_id = 5 or t.created_at = null





select * from users.Patients

select * from users.Staff
