use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('readorfilterSpecialisation','You are able to read or filter  specialisation')

-- permissions for particular roles
insert into users.Role_Permissions values
(101,121)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

-- readorfilter users stored procedure
create or alter procedure users.readorfilterSpecialisation
@staffroleId int, @departmentId int = null,
@specialisation_name nvarchar(35) = null, @description nvarchar(100) = null,
@Deleted bit = null,
@readorfilter_spec_message nvarchar(max) output
with encryption
as
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'readorfilterSpecialisation'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
					where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can read or filter specialisations')
				select 
					d.department_name as 'DEPARTMENT NAME',
					s.specialisation_name as 'SPECIALISATION NAME',
					s.description as 'SPECIALISATION DESCRIPTION'
				from users.Specialisation as s
				left join users.Department as d
				on s.department_id = d.department_id
				where
				( @departmentId is null or s.department_id = @departmentId) and
				( @specialisation_name is null or s.specialisation_name like '%' + @specialisation_name + '%') and										
				( @description is null or s.description like '%' + @description + '%') and
				s.is_deleted != 1;
			end
		else
			begin
				set @readorfilter_spec_message = 'cannot read or filter specialisations';
				print 'You can not read or filter specialisations';
			end
	end try
	begin catch
		set @readorfilter_spec_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING READING OR FILTERING SPECIALISATIONS';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

-- trying it out
declare @result nvarchar(max);

exec users.readorfilterSpecialisation 
@staffroleId = 101,  -- @departmentId = 23,
-- @specialisation_name = 'Doctors',
--@description = 'treat patients',
@readorfilter_spec_message = @result output;

print 'Result: ' + @result;


select 
	d.department_name as 'DEPARTMENT NAME',
	s.specialisation_name as 'SPECIALISATION NAME',
	s.description as 'SPECIALISATION DESCRIPTION'
from users.Specialisation as s
left join users.Department as d
on s.department_id = d.department_id