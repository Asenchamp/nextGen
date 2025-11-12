use HospitalERp;

-- dummy data

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('createSupplies','You are able to add supplies')

-- permissions for particular roles
insert into users.Role_Permissions values
(107,182)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure supplyChain.createSupplies
@staffroleId int,
@productId nvarchar(30),
@supplyQty int,
@staffId int,
@Reason text,
@create_Supply_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'createSupplies'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
					where role_id = @staffroleId and permission_id = @permmissionId  and is_deleted != 1)
			begin
				if exists(select * from supplyChain.Products where product_id = @productId and is_deleted != 1) and
				   exists(select * from users.Staff where staff_id = @staffId and is_deleted != 1)
				   begin
						-- stores the product quantity
						declare @pQty int
						select @pQty = product_Qty from supplyChain.Products
						where product_id = @productId and is_deleted != 1

						if @pQty < @supplyQty
							begin
								set @create_Supply_message = 'Supply Quantity is more than available';
								print 'Supply Quantity is more than available';
							end
						else
							begin
								print('You can add Supplies')
								insert into supplyChain.Supplies
								(product_id, supply_Qty, staff_id, reason)
								values
								(@productId, @supplyQty, @staffId, @Reason)
								set @create_Supply_message = 'Supply added';
								print '=====================================================';
								print 'Supply added successfully';
							end			
				   end
				else
					begin
						set @create_Supply_message = 'Product or Staff dont exist';
						print 'Product or Staff dont exist';
					end
			end
		else
			begin
				set @create_Supply_message = 'cannot add Supply';
				print 'You can not add Supply';
			end
	end try
	begin catch
		set @create_Supply_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING ADDING SUPPLY';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

go

-- trying it out
declare @result nvarchar(max);
exec supplyChain.createSupplies
@staffroleId = 107,
@productId = '#P30',
@supplyQty = 50,
@staffId = 1,
@Reason = 'we need this shit',
@create_Supply_message = @result output;

print 'Result: ' + @result;

select * from supplyChain.Supplies

select * from supplyChain.Products

select * from users.Staff











