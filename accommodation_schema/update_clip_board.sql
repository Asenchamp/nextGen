use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('updateClipboard','You are able to update a clip board record')

-- permissions for particular roles
insert into users.Role_Permissions values
(106,163)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

-- procedure to register patient
create or alter procedure accommodation.updateClipboard
@_staffroleId int,
@clipboardId int,
@admissionId int,
@staffId int,
@Findings nvarchar(100) = null,
@Deleted bit = null,
@update_Clipboard_message nvarchar(max) output
with encryption
as
begin
    begin try
        -- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'updateClipboard'

        -- check whether the user has that permission to update a staff
		if exists(select * from users.Role_Permissions
    			  where role_id = @_staffroleId and permission_id = @permmissionId and is_deleted != 1)
            begin
                print 'You can update a clip board record';
                if exists(select * from accommodation.ClipBoard where clipboard_id = @clipboardId and admission_id = @admissionId and staff_id = @staffId and is_deleted != 1) and
                   exists(select * from accommodation.Admissions where admission_id = @admissionId and is_deleted != 1 and admission_ended_at is null)
                    begin                  
                        update accommodation.ClipBoard
                        set 
                        findings = isnull(@Findings, findings),
                        is_deleted = isnull(@Deleted, is_deleted),
                        updated_at = getdate()
                        where 
                        clipboard_id = @clipboardId and admission_id = @admissionId and staff_id = @staffId and is_deleted !=1

                        set @update_Clipboard_message = 'clip board record updated'
                        print '=====================================================';
				        print 'Clip board:  updated successfully';
                    end
                else
                    begin
                        set @update_Clipboard_message = 'Clip board record dont exist or Admission ended'
                    end                                 
            end
        else
            begin
                set @update_Clipboard_message = 'cannot update clip board record'
                print 'You cannot update clip board record';
            end
    end try
    begin catch
        set @update_Clipboard_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING UPDATING A CLIP BOARD RECORD';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
    end catch
end;

go

declare @result nvarchar(max);
exec accommodation.updateClipboard
@_staffroleId = 106, 
@clipboardId = 3,
@admissionId = 4,
@staffId = 1,
@Findings = 'blood pressure stead',
@update_Clipboard_message = @result output

print 'Result ' + @result;

select * from accommodation.ClipBoard