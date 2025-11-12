use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('readorfilterProduct','You are able to read or filter products')

-- permissions for particular roles
insert into users.Role_Permissions values
(107,177)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

-- readorfilter beds stored procedure
create or alter procedure supplyChain.readorfilterProduct
@staffroleId int, 
@categoriesId int = null,
@productName nvarchar(30) = null,
@readorfilter_Product_message nvarchar(max) output
with encryption
as
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'readorfilterProduct'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
					where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can read or filter products')
				select 
					p.product_id as 'ID',
					p.product_name as 'PRODUCT NAME',
					p.product_Qty as 'PRODUCT QUANTITY',
					P.product_saling_price as 'SALE PRICE',
					c.category_name as 'CATEGORY NAME'
				from supplyChain.Products as p
				left join supplyChain.Categories as c
				on p.categories_id = c.categories_id
				where
				( @categoriesId is null or p.categories_id = @categoriesId) and
				( @productName is null or p.product_name like '%' + @productName + '%') and
				p.is_deleted != 1;
			end
		else
			begin
				set @readorfilter_Product_message = 'cannot read or filter products';
				print 'You can not read or filter products';
			end
	end try
	begin catch
		set @readorfilter_Product_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING READING OR FILTERING PRODUCTS';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

go

-- trying it out
declare @result nvarchar(max);
exec supplyChain.readorfilterProduct
@staffroleId = 107,  
@categoriesId = null,
@productName = null,
@readorfilter_Product_message = @result output;

print 'Result: ' + @result;



select 
	p.product_id as 'ID',
	p.product_name as 'PRODUCT NAME',
	p.product_Qty as 'PRODUCT QUANTITY',
	P.product_saling_price as 'SALE PRICE',
	c.category_name as 'CATEGORY NAME'
from supplyChain.Products as p
left join supplyChain.Categories as c
on p.categories_id = c.categories_id