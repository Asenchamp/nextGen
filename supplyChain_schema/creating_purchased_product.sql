use HospitalERp;

-- dummy data

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('createPurhasedProduct','You are able to add a Purchased Product')

-- permissions for particular roles
insert into users.Role_Permissions values
(107,178)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure supplyChain.createPurhasedProduct
@staffroleId int,
@productId nvarchar(30),
@productQty int,
@productBp float ,
@productPurchasedate datetime,
@productManufacturedate date,
@productExpirydate date,
@productSupplierinfo text,
@create_PurhasedProduct_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'createPurhasedProduct'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
					where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				if exists(select * from supplyChain.Products where product_id = @productId and is_deleted != 1)
				   begin
						print('You can add a Purchased Product')
						insert into supplyChain.Purchased_products
						(product_id, product_Qty, product_buying_price, product_purchase_date, product_manufacture_date, product_expiry_date, product_supplier_info)
						values
						(@productId, @productQty, @productBp, @productPurchasedate, @productManufacturedate, @productExpirydate, @productSupplierinfo)
						set @create_PurhasedProduct_message = 'Purchased Product added';
						print '=====================================================';
						print 'Purchased Product added successfully';					
				   end
				else
					begin
						set @create_PurhasedProduct_message = 'Purchased Product dont exist';
						print 'Purchased Product dont exist';
					end
			end
		else
			begin
				set @create_PurhasedProduct_message = 'cannot add Purchased Product';
				print 'You can not add Purchased Product';
			end
	end try
	begin catch
		set @create_PurhasedProduct_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING ADDING A PURCHASED PRODUCT';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

go

-- trying it out
declare @result nvarchar(max);
declare @date datetime = getdate();
exec supplyChain.createPurhasedProduct
@staffroleId = 107,
@productId = '#P30',
@productQty = 100,
@productBp = 67000 ,
@productPurchasedate = @date,
@productManufacturedate = @date,
@productExpirydate = @date,
@productSupplierinfo = 'Glorre International limited',
@create_PurhasedProduct_message = @result output;

print 'Result: ' + @result;

select * from supplyChain.Purchased_products











