use HospitalERp;

-- dummy data

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('createProduct','You are able to add a Product')

-- permissions for particular roles
insert into users.Role_Permissions values
(107,175)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure supplyChain.createProduct
@staffroleId int,
@productId nvarchar(30),
@categoriesId int,
@productName nvarchar(30),
@productQty int,
@create_Product_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'createProduct'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
					where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				if exists(select * from supplyChain.Categories where categories_id = @categoriesId and is_deleted != 1)
				   begin
						print('You can add a Product')
						insert into supplyChain.Products
						(product_id, categories_id, product_name, product_Qty, product_saling_price)
						values
						(@productId, @categoriesId, @productName, @productQty, 0.0)
						set @create_Product_message = 'Product added';
						print '=====================================================';
						print 'Product added successfully';					
				   end
				else
					begin
						set @create_Product_message = 'Product dont exist';
						print 'Product dont exist';
					end
			end
		else
			begin
				set @create_Product_message = 'cannot add Product';
				print 'You can not add Product';
			end
	end try
	begin catch
		set @create_Product_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING ADDING A PRODUCT';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

go

-- trying it out
declare @result nvarchar(max);
exec supplyChain.createProduct
@staffroleId = 107,  
@productId = '#P30',
@categoriesId = 100, 
@productName = 'Panadol',
@productQty = 90,
@create_Product_message = @result output;

print 'Result: ' + @result;

select * from supplyChain.Products











