use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('updateCategories','You are able to update a product category')

-- permissions for particular roles
insert into users.Role_Permissions values
(107,173)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure supplyChain.updateCategories
@staffroleId int,
@categoriesId int,
@categoryName nvarchar(50),
@categoryDescription text,
@Deleted bit = null,
@update_categories_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'updateCategories'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
				  where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can update a Category')
				if exists(select * from supplyChain.Categories
						  where categories_id = @categoriesId and is_deleted != 1)
					begin
						update supplyChain.Categories
						set
							category_name = isnull(@categoryName, category_name),
							category_description = isnull(@categoryDescription, category_description),
							is_deleted = isnull(@Deleted, is_deleted),
							updated_at = getdate()
						where categories_id = @categoriesId and is_deleted != 1
						set @update_categories_message = 'Category updated';
						print '=====================================================';
						print 'Category updated successfully';
					end
				else
					begin
						set @update_categories_message = 'Category dont exist';
					end
			end
		else
				begin
					set @update_categories_message = 'cannot update Category';
					print 'You can not update Category';
				end
	end try
	begin catch
			set @update_categories_message = ERROR_NUMBER();
			print '=====================================================';
			print 'ERROR OCCURED DURING UPDATING A CATEGORY';
			print 'Error Message '+ERROR_MESSAGE();
			print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
			print 'Error State '+cast(ERROR_STATE() as nvarchar);
			print '=====================================================';
		end catch
end

go

-- trying it out
declare @result nvarchar(max);
exec supplyChain.updateCategories
@staffroleId = 107,
@categoriesId = 100,
@categoryName = null,
@categoryDescription = null,
@Deleted = null,
@update_categories_message = @result output;

print 'Result: ' + @result;

select * from supplyChain.Categories

