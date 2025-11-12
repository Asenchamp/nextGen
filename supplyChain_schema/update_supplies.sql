use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('updateSupplies','You are able to update a supply record')

-- permissions for particular roles
insert into users.Role_Permissions values
(107,183)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

-- update users stored procedure
create or alter procedure supplyChain.updateSupplies
@staffroleId int, 
@supplyId int,
@productId nvarchar(30),
@supplyQty int = null,
@staffId int,
@Reason text = null,
@Deleted bit = null,
@update_Supply_message nvarchar(max) output
with encryption
as
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'updateSupplies'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
					where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can update a supply record')
				if exists(select * from supplyChain.Supplies where supply_id = @supplyId and product_id = @productId and staff_id = @staffId and is_deleted != 1) and
				   exists(select * from users.Staff where staff_id = @staffId and is_deleted != 1)
					begin
						-- stores the product quantity and supply quantity
						declare @pQty int, @spQty int
						select @pQty = product_Qty from supplyChain.Products
						where product_id = @productId and is_deleted != 1

						select @spQty = supply_Qty from supplyChain.Supplies 
						where supply_id = @supplyId and product_id = @productId and staff_id = @staffId and is_deleted != 1

						if (@pQty + @spQty) < @supplyQty
							begin
								set @update_Supply_message = 'Supply Quantity is more than available';
								print 'Supply Quantity is more than available';
							end
						else
							begin
								update supplyChain.Supplies
								set
									supply_Qty = isnull(@supplyQty, supply_Qty),
									reason = isnull(@Reason, reason),
									is_deleted = isnull(@Deleted, is_deleted),
									updated_at = getdate()
								where
									supply_id = @supplyId and product_id = @productId and staff_id = @staffId and is_deleted != 1
								set @update_Supply_message = 'Supply record updated';
								print '=====================================================';
								print 'Supply record: updated successfully';
							end							
					end
				else
					begin
						set @update_Supply_message = 'supply record or staff dont exist';
					end
			end
		else
			begin
				set @update_Supply_message = 'cannot update supply record';
				print 'You can not update a supply record';
			end
	end try
	begin catch
		set @update_Supply_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING UPDATING A SUPPLY RECORD';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

go

-- trying it out
declare @result nvarchar(max);
exec supplyChain.updateSupplies
@staffroleId = 107, 
@supplyId = 100,
@productId = '#P30',
@supplyQty = 1000,
@staffId = 1,
@Reason = null,
@Deleted = null,
@update_Supply_message = @result output;

print 'Result: ' + @result;

select * from supplyChain.Supplies