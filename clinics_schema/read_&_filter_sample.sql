use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('readorfilterSample','You are able to read or filter  sample records')

-- permissions for particular roles
insert into users.Role_Permissions values
(105,141)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure clinics.readorfilterSample
@staffroleId int, @patientId int = null, 
@sampleLabel nvarchar(30) = null,
@readorfilter_sampleRec_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'readorfilterSample'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
				  where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can read or filter sample records')
				select 
					u1.user_full_Name as 'PATIENT NAME',
					u1.user_gender as 'PATIENT GENDER',
					s.sample_label as 'SAMPLE LABEL'
				from clinics.Samples as s
				left join users.Patients as p
				on s.patient_id = p.patient_id
				left join users.Users as u1
				on p.user_id = u1.user_id
				where 
				( @patientId is null or s.patient_id = @patientId ) and
				( @sampleLabel is null or s.sample_label = @sampleLabel ) and
				s.is_deleted != 1;
			end
		else
			begin
				set @readorfilter_sampleRec_message = 'cannot read or filter sample records';
				print 'You can not read or filter sample records';
			end
	end try
	begin catch
		set @readorfilter_sampleRec_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING GETTING A SAMPLE RECORD';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

-- trying it out
declare @result nvarchar(max);

exec clinics.readorfilterSample
@staffroleId = 105,
@patientId = 2, 
@sampleLabel = 1, 
@readorfilter_sampleRec_message = @result output;

print 'Result: ' + @result;


select 
	u1.user_full_Name as 'PATIENT NAME',
	u1.user_gender as 'PATIENT GENDER',
	s.sample_label as 'SAMPLE LABEL'
from clinics.Samples as s
left join users.Patients as p
on s.patient_id = p.patient_id
left join users.Users as u1
on p.user_id = u1.user_id

select * from users.Patients

select * from users.Staff
