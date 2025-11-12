use HospitalERp;

-- dumy data
-- system roles
insert into users.Roles values
('triage', 'triage people');

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('updateTesttype','You are able to update a test type')

-- permissions for particular roles
insert into users.Role_Permissions values
(105,137)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure clinics.updateTesttype
@staffroleId int, @testtypeId int,  @testtypeName nvarchar(30) = null,
@Deleted bit = null,
@update_testtypeName_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'updateTesttype'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
				  where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can update diagnosis Rec')
				if exists(select * from clinics.Testtype where test_type_id = @testtypeId and is_deleted != 1)
					begin
						update clinics.Testtype
						set
							test_type_name = isnull(@testtypeName, test_type_name),
							is_deleted = isnull(@Deleted, is_deleted),
							update_at = getdate()
						where test_type_id = @testtypeId and is_deleted != 1
						set @update_testtypeName_message = 'Test type updated';
						print '=====================================================';
						print 'Test type updated successfully';
					end
				else
					begin
						set @update_testtypeName_message = 'Test type dont exist';
					end
			end
		else
				begin
					set @update_testtypeName_message = 'cannot update Test type';
					print 'You can not update Test type';
				end
	end try
	begin catch
			set @update_testtypeName_message = ERROR_NUMBER();
			print '=====================================================';
			print 'ERROR OCCURED DURING UPDATING A TEST TYPE';
			print 'Error Message '+ERROR_MESSAGE();
			print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
			print 'Error State '+cast(ERROR_STATE() as nvarchar);
			print '=====================================================';
		end catch
end

-- trying it out
declare @result nvarchar(max);

exec clinics.updateTesttype
@staffroleId = 105,
@testtypeId = 1, 
-- @testtypeName = 'big stomach',
@update_testtypeName_message = @result output;

print 'Result: ' + @result;

select * from clinics.Testtype

