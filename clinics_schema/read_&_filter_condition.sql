use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('readorfilterCondition','You are able to read or filter  conditions')

-- permissions for particular roles
insert into users.Role_Permissions values
(105,132)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure clinics.readorfilterCondition
@staffroleId int, @conditionName nvarchar(30) = null,
@conditionDescription nvarchar(30) = null,
@conditionStatus nvarchar(10) = null,
@Deleted bit = null,
@readorfilter_condition_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'readorfilterCondition'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
				  where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can read or filter conditions')
				select 
					condition_name as 'CONDITION NAME',
					condition_description  as 'DESCRIPTION',
					condition_status as 'STATUS'
				from clinics.Condition
				where 
				( @conditionName is null or condition_name like '%' + @conditionName + '%') and
				( @conditionDescription is null or condition_description like '%' + @conditionDescription + '%') and
				( @conditionStatus is null or condition_status like '%' + @conditionStatus + '%') and
				is_deleted != 1;
			end
		else
			begin
				set @readorfilter_condition_message = 'cannot read or filter conditions';
				print 'You can not read or filter conditions';
			end
	end try
	begin catch
		set @readorfilter_condition_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING GETTING A CONDITION';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

-- trying it out
declare @result nvarchar(max);
exec clinics.readorfilterCondition
@staffroleId = 105,
@conditionName = 'pre',
@conditionDescription = null,
@conditionStatus = null,
@readorfilter_condition_message = @result output;

print 'Result: ' + @result;




select 
	condition_name as 'CONDITION NAME',
	condition_description  as 'DESCRIPTION',
	condition_status as 'STATUS'
from clinics.Condition




