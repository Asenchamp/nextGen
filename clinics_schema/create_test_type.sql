use HospitalERp;

-- dumy data
-- system roles
insert into users.Roles values
('triage', 'triage people');

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('createTesttype','You are able to add a test type')

-- permissions for particular roles
insert into users.Role_Permissions values
(105,136)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure clinics.createTesttype
@staffroleId int,  @testtypeName nvarchar(30),
@create_testtypeName_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'createTesttype'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
				  where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				   insert into clinics.Testtype
				   ( test_type_name )
				   values
				   ( @testtypeName )
				   set @create_testtypeName_message = 'test type added';
				   print '=====================================================';
				   print 'Test type: added successfully';				
				end
		else
			begin
				set @create_testtypeName_message = 'cannot add a test type';
				print 'You can not add a test type';
			end
	end try
	begin catch
		set @create_testtypeName_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING ADDING A TEST TYPE';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end


-- trying it out
declare @result nvarchar(max);
exec clinics.createTesttype
@staffroleId = 105,  
@testtypeName = 'HIV/AIDS',
@create_testtypeName_message = @result output;

print 'Result: ' + @result;

select * from clinics.Testtype

