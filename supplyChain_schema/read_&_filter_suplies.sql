use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('readorfilterSupplies','You are able to read or filter Supplies')

-- permissions for particular roles
insert into users.Role_Permissions values
(107,184)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

-- readorfilter beds stored procedure
create or alter procedure supplyChain.readorfilterSupplies
@staffroleId int,
@categoriesId int = null,
@productId nvarchar(30) = null,
@supplyQty int = null,
@staffId int = null,
@supplyIssuedate date = null,
@readorfilter_Supplies_message nvarchar(max) output
with encryption
as
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'readorfilterSupplies'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
					where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can read or filter supplies')
				select	
					p.product_name as 'PRODUCT NAME',
					c.category_name as 'CATEGORY',
					s.supply_Qty as 'QUANTITY',
					s.supply_issue_date as 'ISSUE DATE',
					u.user_full_Name as 'PICKED BY'
				from supplyChain.Supplies as s
				left join supplyChain.Products as p
				on s.product_id = p.product_id
				left join supplyChain.Categories as c
				on p.categories_id = c.categories_id
				left join users.Staff as st
				on s.staff_id = st.staff_id
				left join users.Users as u
				on st.user_id = u.user_id
				where
				( @categoriesId is null or p.categories_id = @categoriesId) and
				( @productId is null or s.product_id = @productId ) and
				( @supplyIssuedate is null or s.supply_issue_date = @supplyIssuedate ) and
				( @supplyQty is null or s.supply_Qty = @supplyQty ) and
				( @staffId is null or s.staff_id = @staffId ) and
				s.is_deleted != 1;
			end
		else
			begin
				set @readorfilter_Supplies_message = 'cannot read or filter supplies';
				print 'You can not read or filter supplies';
			end
	end try
	begin catch
		set @readorfilter_Supplies_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING READING OR FILTERING SUPPLIES';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

go

-- trying it out
declare @result nvarchar(max);
exec supplyChain.readorfilterSupplies
@staffroleId = 107,  
@categoriesId = null,
@productId = null,
@supplyQty = null,
@staffId = null,
@supplyIssuedate = null,
@readorfilter_Supplies_message = @result output;

print 'Result: ' + @result;

select * from supplyChain.Supplies

select	
	p.product_name as 'PRODUCT NAME',
	c.category_name as 'CATEGORY',
	s.supply_Qty as 'QUANTITY',
	s.supply_issue_date as 'ISSUE DATE',
	u.user_full_Name as 'PICKED BY'
from supplyChain.Supplies as s
left join supplyChain.Products as p
on s.product_id = p.product_id
left join supplyChain.Categories as c
on p.categories_id = c.categories_id
left join users.Staff as st
on s.staff_id = st.staff_id
left join users.Users as u
on st.user_id = u.user_id