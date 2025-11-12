use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('updateProduct','You are able to update a product')

-- permissions for particular roles
insert into users.Role_Permissions values
(107,176)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

-- update users stored procedure
create or alter procedure supplyChain.updateProduct
@staffroleId int, 
@productId nvarchar(30),
@categoriesId int = null,
@productName nvarchar(30) = null,
@productQty int = null,
@productSP float = null,
@Deleted bit = null,
@update_Product_message nvarchar(max) output
with encryption
as
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'updateProduct'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
					where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can update a product')
				if exists(select * from supplyChain.Products where product_id = @productId and is_deleted != 1)
					begin
						update supplyChain.Products
						set
							categories_id = isnull(@categoriesId, categories_id),
							product_name = isnull(@productName, product_name),
							product_Qty = isnull(@productQty, product_Qty),
							product_saling_price = isnull(@productSP, product_saling_price),
							is_deleted = isnull(@Deleted, is_deleted),
							updated_at = getdate()
						where
							product_id = @productId and is_deleted != 1
						set @update_Product_message = 'Product updated';
						print '=====================================================';
						print 'Product: updated successfully';
					end
				else
					begin
						set @update_Product_message = 'product dont exist';
					end
			end
		else
			begin
				set @update_Product_message = 'cannot update product';
				print 'You can not update a product';
			end
	end try
	begin catch
		set @update_Product_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING UPDATING A PRODUCT';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

go

-- trying it out
declare @result nvarchar(max);
exec supplyChain.updateProduct
@staffroleId = 107,  
@productId = '#p30',
@categoriesId = null,
@productName = null,
@productQty = null,
@productSP = null,
@Deleted = null,
@update_Product_message = @result output;

print 'Result: ' + @result;

select * from supplyChain.Products