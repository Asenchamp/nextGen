use HospitalERp;

-- dummy data

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('createClipboard','You are able to add a clip board record')

-- permissions for particular roles
insert into users.Role_Permissions values
(106,162)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure accommodation.createClipboard
@staffroleId int,
@admissionId int,
@staffId int,
@Findings nvarchar(100),
@create_Clipboard_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'createClipboard'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
					where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				if exists(select * from accommodation.Admissions where admission_id = @admissionId and is_deleted != 1 and admission_ended_at is null) and
				   exists(select * from users.Staff where staff_id = @staffId and is_deleted != 1)
				   begin
						print('You can add a Clip board record')
						insert into accommodation.ClipBoard
						(admission_id, staff_id, findings)
						values
						(@admissionId, @staffId, @Findings)
						set @create_Clipboard_message = 'Clip board record added';
						print '=====================================================';
						print 'Clip board record added successfully';					
				   end
				else
					begin
						set @create_Clipboard_message = 'Admission or Staff dont exist or Admission ended';
						print 'Admission or Staff dont exist or Admission ended';
					end
			end
		else
			begin
				set @create_Clipboard_message = 'cannot add Clip board record';
				print 'You can not cannot add Clip board record';
			end
	end try
	begin catch
		set @create_Clipboard_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING ADDING A CLIP BOARD RECORD';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

go

-- trying it out
declare @result nvarchar(max);
exec accommodation.createClipboard
@staffroleId = 106,  
@admissionId = 4,
@staffId = 1,
@Findings = 'blood pressure steady',
@create_Clipboard_message = @result output;
print 'Result: ' + @result;

select * from accommodation.ClipBoard

select * from accommodation.Admissions



