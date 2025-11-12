use HospitalERp;

-- dummy data
-- system roles
insert into users.Roles values
('admin','top guy');

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('createAppointments','You are able to add an appointment')

-- permissions for particular roles
insert into users.Role_Permissions values
(101,124)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure users.createAppointments
@staffroleId int, 
@notes text,
@departmentId int, @staffId int,
@patientId int, @appointment_status varchar(40) = 'Pending',
@create_appointment_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'createAppointments'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
					where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can add an Appointment')
				if exists(select * from users.Patients where patient_id = @patientId and is_deleted != 1) and
				   exists(select * from users.Staff where staff_id = @staffId and is_deleted != 1) and
				   exists(select * from users.Department where department_id = @departmentId and is_deleted != 1)
				   begin
					insert into users.Appointments
					(patient_id, request_date, appointment_status, notes, department_id, staff_id)
					values
					(@patientId, getdate(), @appointment_status, @notes, @departmentId, @staffId)
					set @create_appointment_message = 'appointment added';
					print '=====================================================';
					print 'Appointment: added successfully';
					end
				else
					begin
						set @create_appointment_message = 'Either patient or Doctor or Department dont exist';
						print '=====================================================';
						print 'Either patient or Doctor or Department dont exist';
					end
			end
		else
			begin
				set @create_appointment_message = 'cannot add an appointment';
				print 'You can not add an appointment';
			end
	end try
	begin catch
		set @create_appointment_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING ADDING AN APPOINTMENT';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

-- trying it out
declare @result nvarchar(max);
declare @date datetime = getdate();
exec users.createAppointments 
@staffroleId = 101,  
@notes = 'Want to see them doc real quick',
@departmentId = 101, @staffId = 1,
@patientId = 2, 
@create_appointment_message = @result output;

print 'Result: ' + @result;

select * from users.Appointments

select * from users.Patients

select * from users.Staff

select * from users.Department






















