use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('updatePayment','You are able to update a payment')

-- permissions for particular roles
insert into users.Role_Permissions values
(107,186)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

-- update users stored procedure
create or alter procedure supplyChain.updatePayment
@staffroleId int,
@paymentId int,
@paymentMethod nvarchar(25) = null,
@patientId int,
@staffId int,
@paidAmmount float = null,
@Deleted bit = null,
@update_Payment_message nvarchar(max) output
with encryption
as
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'updatePayment'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
					where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can update a payment')
				if exists(select * from supplyChain.Payments where payment_id = @paymentId and patient_id = @patientId and staff_id = @staffId and is_deleted != 1)
					begin
						update supplyChain.Payments
						set
							payment_method = isnull(@paymentMethod, payment_method),
							paid_ammount = isnull(@paidAmmount, paid_ammount),
							is_deleted = isnull(@Deleted, is_deleted),
							updated_at = getdate()
						where
							payment_id = @paymentId and patient_id = @patientId and staff_id = @staffId and is_deleted != 1
						set @update_Payment_message = 'Payment updated';
						print '=====================================================';
						print 'Payemnt: updated successfully';
					end
				else
					begin
						set @update_Payment_message = 'payment dont exist';
					end
			end
		else
			begin
				set @update_Payment_message = 'cannot update payment';
				print 'You can not update a payment';
			end
	end try
	begin catch
		set @update_Payment_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING UPDATING A PAYMENT';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

go

-- trying it out
declare @result nvarchar(max);
exec supplyChain.updatePayment
@staffroleId = 107,  
@paymentId = 100,
@paymentMethod = null,
@patientId = 2,
@staffId = 1,
@paidAmmount = null,
@Deleted = null,
@update_Payment_message = @result output;

print 'Result: ' + @result;

select * from supplyChain.Payments