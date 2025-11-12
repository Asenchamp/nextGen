use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('readorfilterTesttype','You are able to read or filter test type')

-- permissions for particular roles
insert into users.Role_Permissions values
(105,138)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure clinics.readorfilterTesttype
@staffroleId int, @testtypeName nvarchar(30) = null,
@readorfilter_testtypeName_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'readorfilterTesttype'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
				  where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can read or filter test types')
				select 
					t.test_type_name as 'TEST TYPE'
				from clinics.Testtype as t				
				where
				( @testtypeName is null or t.test_type_name = @testtypeName ) and is_deleted != 1;
			end
		else
			begin
				set @readorfilter_testtypeName_message = 'cannot read or filter test types';
				print 'You can not read or filter test types';
			end
	end try
	begin catch
		set @readorfilter_testtypeName_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING GETTING A TEST TYPES';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

-- trying it out
declare @result nvarchar(max);

exec clinics.readorfilterTesttype
@staffroleId = 105,
-- @testtypeName = 2,
@readorfilter_testtypeName_message = @result output;

print 'Result: ' + @result;


