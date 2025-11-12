use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('readorfilterPurhasedProduct','You are able to read or filter purchased products')

-- permissions for particular roles
insert into users.Role_Permissions values
(107,181)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

-- readorfilter beds stored procedure
create or alter procedure supplyChain.readorfilterPurhasedProduct
@staffroleId int,
@categoriesId int = null,
@productId nvarchar(30) = null,
@productPurchasedate datetime = null,
@productSupplierinfo nvarchar(30) = null,
@readorfilter_PurhasedProduct_message nvarchar(max) output
with encryption
as
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'readorfilterPurhasedProduct'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
					where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can read or filter purchased products')
				select	
					p.product_name as 'PRODUCT NAME',
					c.category_name as 'CATEGORY',
					pp.product_Qty as 'QUANTITY',
					pp.product_buying_price as 'BUYING PRICE',
					pp.product_purchase_date as 'PURCHASE DATE',
					pp.product_manufacture_date as 'MANUFACTURE DATE',
					pp.product_expiry_date as 'EXPIRY DATE',
					pp.product_supplier_info as 'SUPPLIER INFO'
				from supplyChain.Purchased_products as pp
				left join supplyChain.Products as p
				on pp.product_id = p.product_id
				left join supplyChain.Categories as c
				on p.categories_id = c.categories_id
				where
				( @categoriesId is null or p.categories_id = @categoriesId) and
				( @productId is null or p.product_id = @productId ) and
				( @productPurchasedate is null or pp.product_purchase_date = @productPurchasedate ) and
				( @productSupplierinfo is null or pp.product_supplier_info like '%' + @productSupplierinfo + '%') and
				pp.is_deleted != 1;
			end
		else
			begin
				set @readorfilter_PurhasedProduct_message = 'cannot read or filter purchased products';
				print 'You can not read or filter purchased products';
			end
	end try
	begin catch
		set @readorfilter_PurhasedProduct_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING READING OR FILTERING PURCHASED PRODUCTS';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

go

-- trying it out
declare @result nvarchar(max);
exec supplyChain.readorfilterPurhasedProduct
@staffroleId = 107,  
@categoriesId = null,
@productId = null,
@productPurchasedate = null,
@productSupplierinfo = null,
@readorfilter_PurhasedProduct_message= @result output;

print 'Result: ' + @result;



select	
	p.product_name as 'PRODUCT NAME',
	c.category_name as 'CATEGORY',
	pp.product_Qty as 'QUANTITY',
	pp.product_buying_price as 'BUYING PRICE',
	pp.product_purchase_date as 'PURCHASE DATE',
	pp.product_manufacture_date as 'MANUFACTURE DATE',
	pp.product_expiry_date as 'EXPIRY DATE',
	pp.product_supplier_info as 'SUPPLIER INFO'
from supplyChain.Purchased_products as pp
left join supplyChain.Products as p
on pp.product_id = p.product_id
left join supplyChain.Categories as c
on p.categories_id = c.categories_id