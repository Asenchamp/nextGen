use HospitalERp;

-- dummy data
-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('createAdmission','You are able to add an admission')

-- permissions for particular roles
insert into users.Role_Permissions values
(106,158)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure accommodation.createAdmission
@staffroleId int, 
@staffId int,
@patientId int,
@bedId int,
@admissionNotes nvarchar(100),
@create_Admission_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'createAdmission'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
					where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can add an Admission')
				if exists(select * from users.Patients where patient_id = @patientId and is_deleted != 1) and
				   exists(select * from users.Staff where staff_id = @staffId and is_deleted != 1) and
				   exists(select * from accommodation.Beds where bed_id = @bedId and is_deleted != 1)
				   begin
					insert into accommodation.Admissions
					(staff_id, patient_id, bed_id, admission_notes)
					values
					(@staffId, @patientId, @bedId, @admissionNotes)
					set @create_Admission_message = 'admission added';
					print '=====================================================';
					print 'Admission: added successfully';
					end
				else
					begin
						set @create_Admission_message = 'Either patient or Doctor or Bed dont exist';
						print '=====================================================';
						print 'Either patient or Doctor or Bed dont exist';
					end
			end
		else
			begin
				set @create_Admission_message = 'cannot add an admission';
				print 'You can not add an admission';
			end
	end try
	begin catch
		set @create_Admission_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING ADDING AN ADMISSION';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

go

-- trying it out
declare @result nvarchar(max);
exec accommodation.createAdmission
@staffroleId = 106,  
@staffId = 1,
@patientId = 8,
@bedId = 2,
@admissionNotes = null,
@create_Admission_message = @result output;

print 'Result: ' + @result;

select * from accommodation.Admissions

select * from users.Patients

select * from users.Staff

select * from accommodation.Beds














