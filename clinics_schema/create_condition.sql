use HospitalERp;

-- dumy data
-- system roles
insert into users.Roles values
('triage', 'triage people');

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('createCondition','You are able to add a condition')

-- permissions for particular roles
insert into users.Role_Permissions values
(105,130)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure clinics.createCondition
@staffroleId int,
@conditionName nvarchar(30),
@conditionDescription nvarchar(30),
@conditionStatus nvarchar(10),
@create_condition_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'createCondition'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
				  where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				insert into clinics.Condition
				(condition_name, condition_description, condition_status)
				values
				(@conditionName, @conditionDescription, @conditionStatus)
				set @create_condition_message = 'condition added';
				print '=====================================================';
				print 'Condition: added successfully';					
			end
		else
			begin
				set @create_condition_message = 'cannot add a condition';
				print 'You can not add a condition';
			end
	end try
	begin catch
		set @create_condition_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING ADDING A CONDITION';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end



-- trying it out
declare @result nvarchar(max);
exec clinics.createCondition
@staffroleId = 105,  
@conditionName = 'pregnancy1',
@conditionDescription = 'evidence for being fucked',
@conditionStatus = 'tempora',
@create_condition_message = @result output;
print 'Result: ' + @result;

select * from clinics.Condition
