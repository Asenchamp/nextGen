use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('readorfilterCategory','You are able to read or filter  categories')

-- permissions for particular roles
insert into users.Role_Permissions values
(107,174)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure supplyChain.readorfilterCategory
@staffroleId int, 
@categoryName nvarchar(50) = null,
@categoryDescription nvarchar(50) = null,
@readorfilter_Category_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'readorfilterCategory'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
				  where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can read or filter categories')
				select 
					c.category_name as 'CATEGORY NAME',
					c.category_description as 'CATEGORY DESCRIPTION'
				from supplyChain.Categories as c
				where 
				( @categoryName is null or c.category_name like '%' + @categoryName + '%') and
				( @categoryDescription is null or c.category_description like '%' + @categoryDescription + '%') and
				c.is_deleted != 1
			end
		else
			begin
				set @readorfilter_Category_message = 'cannot read or filter categories';
				print 'You can not read or filter categories';
			end
	end try
	begin catch
		set @readorfilter_Category_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING GETTING A CATEGORY';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

go

-- trying it out
declare @result nvarchar(max);
exec supplyChain.readorfilterCategory
@staffroleId = 107,
@categoryName = null,
@categoryDescription = null,
@readorfilter_Category_message = @result output;

print 'Result: ' + @result;




select 
	c.category_name as 'CATEGORY NAME',
	c.category_description as 'CATEGORY DESCRIPTION'
from supplyChain.Categories as c




