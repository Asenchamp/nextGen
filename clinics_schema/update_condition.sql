use HospitalERp;

-- dumy data
-- system roles
insert into users.Roles values
('triage', 'triage people');

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('updateCondition','You are able to update a condition')

-- permissions for particular roles
insert into users.Role_Permissions values
(105,131)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure clinics.updateCondition
@staffroleId int,
@conditionId int,
@conditionName nvarchar(30) = null,
@conditionDescription nvarchar(30) = null,
@conditionStatus nvarchar(10) = null,
@Deleted bit = null,
@update_condition_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'updateCondition'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
				  where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can update a condition')
				if exists(select * from clinics.Condition where condition_id = @conditionId and is_deleted != 1)
					begin
						update clinics.Condition
						set
							condition_name = isnull(@conditionName, condition_name),
							condition_description = isnull(@conditionDescription, condition_description),
							condition_status = isnull(@conditionStatus, condition_status),
							is_deleted = isnull(@Deleted, is_deleted),
							update_at = getdate()
						where condition_id = @conditionId and is_deleted != 1
						set @update_condition_message = 'Condition updated';
						print '=====================================================';
						print 'Condition updated successfully';
					end
				else
					begin
						set @update_condition_message = 'Condition dont exist';
					end
			end
		else
				begin
					set @update_condition_message = 'cannot update Condition';
					print 'You can not update Condition';
				end
	end try
	begin catch
			set @update_condition_message = ERROR_NUMBER();
			print '=====================================================';
			print 'ERROR OCCURED DURING UPDATING A CONDITION';
			print 'Error Message '+ERROR_MESSAGE();
			print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
			print 'Error State '+cast(ERROR_STATE() as nvarchar);
			print '=====================================================';
		end catch
end



-- trying it out
declare @result nvarchar(max);
exec clinics.updateCondition
@staffroleId = 105, 
@conditionId = 1,
@conditionName = 'Pregnancy',
@conditionDescription = null,
@conditionStatus = null,
@update_condition_message = @result output;

print 'Result: ' + @result;

select * from clinics.Condition

