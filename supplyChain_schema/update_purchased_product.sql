use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('updatePurhasedProduct','You are able to update a purchased product')

-- permissions for particular roles
insert into users.Role_Permissions values
(107,179)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

-- update users stored procedure
create or alter procedure supplyChain.updatePurhasedProduct
@staffroleId int, 
@purchaseId int,
@productId nvarchar(30) = null,
@productQty int = null,
@productBp float  = null,
@productPurchasedate datetime = null,
@productManufacturedate date = null,
@productExpirydate date = null,
@productSupplierinfo text = null,
@Deleted bit = null,
@update_PurhasedProduct_message nvarchar(max) output
with encryption
as
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'updatePurhasedProduct'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
					where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can update a purchased product')
				if exists(select * from supplyChain.Purchased_products where purchase_id = @purchaseId and is_deleted != 1)
					begin
						update supplyChain.Purchased_products
						set
							product_id = isnull(@productId, product_id),
							product_Qty = isnull(@productQty, product_Qty),
							product_buying_price = isnull(@productBp, product_buying_price),
							product_purchase_date = isnull(@productPurchasedate, product_purchase_date),
							product_manufacture_date = isnull(@productManufacturedate, product_manufacture_date),
							product_expiry_date = isnull(@productExpirydate, product_expiry_date),
							product_supplier_info = isnull(@productSupplierinfo, product_supplier_info),
							is_deleted = isnull(@Deleted, is_deleted),
							updated_at = getdate()
						where
							purchase_id = @purchaseId and is_deleted != 1
						set @update_PurhasedProduct_message = 'Purchased Product updated';
						print '=====================================================';
						print 'Purchased Product: updated successfully';
					end
				else
					begin
						set @update_PurhasedProduct_message = 'purchased product dont exist';
					end
			end
		else
			begin
				set @update_PurhasedProduct_message = 'cannot update purchased product';
				print 'You can not update a purchased product';
			end
	end try
	begin catch
		set @update_PurhasedProduct_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING UPDATING A PURCHASED PRODUCT';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

go

-- trying it out
declare @result nvarchar(max);
exec supplyChain.updatePurhasedProduct
@staffroleId = 107, 
@purchaseId = 100,
@productId  = null,
@productQty = null,
@productBp = null,
@productPurchasedate = null,
@productManufacturedate = null,
@productExpirydate = null,
@productSupplierinfo = null,
@Deleted = 1,
@update_PurhasedProduct_message = @result output;

print 'Result: ' + @result;

select * from supplyChain.Purchased_products