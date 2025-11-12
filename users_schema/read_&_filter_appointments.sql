use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('readorfilterAppointments','You are able to read or filter  apointments')

-- permissions for particular roles
insert into users.Role_Permissions values
(101,125)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

-- readorfilter users stored procedure
create or alter procedure users.readorfilterAppointments
@staffroleId int, 
@appointment_date datetime = null,
@departmentId int = null, @staffId int = null,
@patientId int = null, @appointment_status varchar(40) = null,
@readorfilter_appointments_message nvarchar(max) output
with encryption
as
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'readorfilterAppointments'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
					where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can read or filter appointments')
				select 
					u.user_full_Name as 'PATIENT NAME',
					u.user_gender as 'USER GENDER',
					d.department_name as 'DEPARTMENT NAME',
					u1.user_full_Name as 'DOCTOR NAME',
					a.appointment_status as 'APPOINTMENT STATUS',
					a.notes as 'APPOINTMENT NOTES'
				from users.Appointments as a
				left join users.Department as d
				on a.department_id = d.department_id
				left join users.Patients as p
				on a.patient_id = p.patient_id
				left join users.Users as u
				on p.user_id = u.user_id
				left join users.Department as dp
				on a.department_id = dp.department_id
				left join users.Staff as s
				on a.staff_id = s.staff_id
				left join users.Users as u1
				on s.user_id = u1.user_id
				where
				( @appointment_date is null or a.appointment_date = @appointment_date ) and
				( @staffId is null or a.staff_id = @staffId ) and
				( @appointment_status is null or a.appointment_status like '%' + @appointment_status + '%') and
				( @departmentId is null or a.department_id = @departmentId ) and
				a.is_deleted != 1;
			end
		else
			begin
				set @readorfilter_appointments_message = 'cannot read or filter appointments';
				print 'You can not read or filter appointments';
			end
	end try
	begin catch
		set @readorfilter_appointments_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING READING OR FILTERING APPOINTMENTS';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

-- trying it out
declare @result nvarchar(max);

exec users.readorfilterAppointments 
@staffroleId = 101, 
-- @appointment_date datetime = null,
-- @departmentId int = null, @staffId int = null,
-- @patientId int = null, @appointment_status varchar(40) = null,
@readorfilter_appointments_message = @result output;

print 'Result: ' + @result;



select 
	u.user_full_Name as 'PATIENT NAME',
	u.user_gender as 'USER GENDER',
	d.department_name as 'DEPARTMENT NAME',
	u1.user_full_Name as 'DOCTOR NAME',
	a.appointment_status as 'APPOINTMENT STATUS',
	a.notes as 'APPOINTMENT NOTES'
from users.Appointments as a
left join users.Department as d
on a.department_id = d.department_id
left join users.Patients as p
on a.patient_id = p.patient_id
left join users.Users as u
on p.user_id = u.user_id
left join users.Department as dp
on a.department_id = dp.department_id
left join users.Staff as s
on a.staff_id = s.staff_id
left join users.Users as u1
on s.user_id = u1.user_id
