use HospitalERp;

-- dummy data
-- system roles
insert into users.Roles values
('admin','top guy');

-- system Permissions
insert into users.Permissions values
('deleteDepartment','You are able to delete a department')

-- permissions for particular roles
insert into users.Role_Permissions values
(101,119)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

create or alter procedure users.deleteDepartment
@staffroleId int, @departmentId int,
@delete_dept_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'deleteDepartment'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
					where role_id = @staffroleId and permission_id = @permmissionId)
			begin
				print('You can delete a department')
				if exists(select * from users.Department where department_id = @departmentId)
					begin
						delete from users.Department						
						where
							department_id = @departmentId

						set @delete_dept_message = 'department delete';
						print '=====================================================';
						print 'Department deleted successfully';
					end
				else
					begin
						set @delete_dept_message = 'department dont exist';
					end
			end
		else
			begin
				set @delete_dept_message = 'cannot delete department';
				print 'You can not delete a department';
			end
	end try
	begin catch
		set @delete_dept_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING ADDING A ROLE';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

-- trying it out
declare @result nvarchar(max);

exec users.deleteDepartment 
@staffroleId = 101,  @departmentId = 100,
@delete_dept_message = @result output;

print 'Result: ' + @result;

select * from users.Department






















