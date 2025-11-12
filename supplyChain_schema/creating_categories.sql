use HospitalERp;

-- dumy data
-- system roles
insert into users.Roles values
('supplychain', 'supply chain people');
 
-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('createCategories','You are able to add a product category')

-- permissions for particular roles
insert into users.Role_Permissions values
(107,172)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure supplyChain.createCategories
@staffroleId int,
@categoryName nvarchar(50),
@categoryDescription text,
@create_categories_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'createCategories'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
				  where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				insert into supplyChain.Categories
				(category_name, category_description, created_at)
				values
				(@categoryName, @categoryDescription, getdate())
				set @create_categories_message = 'category added';
				print '=====================================================';
				print 'Category: added successfully';					
			end
		else
			begin
				set @create_categories_message = 'cannot add a category';
				print 'You can not add a category';
			end
	end try
	begin catch
		set @create_categories_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING ADDING A CATEGORY';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

go

-- trying it out
declare @result nvarchar(max);
exec supplyChain.createCategories
@staffroleId = 107,
@categoryName = 'Painkillers',
@categoryDescription = 'reduce pain',
@create_categories_message = @result output;
print 'Result: ' + @result;

select * from supplyChain.Categories
