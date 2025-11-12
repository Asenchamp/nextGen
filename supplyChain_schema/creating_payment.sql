use HospitalERp;

-- dummy data

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('createPayments','You are able to add a payment')

-- permissions for particular roles
insert into users.Role_Permissions values
(107,185)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure supplyChain.createPayments
@staffroleId int,
@paymentMethod nvarchar(25),
@patientId int,
@staffId int,
@paidAmmount float,
@create_Payment_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'createPayments'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
					where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				if exists(select * from users.Patients where patient_id = @patientId and is_deleted != 1) and
				   exists(select * from users.Staff where staff_id = @staffId and is_deleted != 1) and 
				   @paidAmmount > 0
				   begin
						print('You can add a Payment')
						insert into supplyChain.Payments
						(payment_method, patient_id, staff_id, paid_ammount )
						values
						(@paymentMethod, @patientId, @staffId, @paidAmmount)
						set @create_Payment_message = 'Payment added';
						print '=====================================================';
						print 'Payment added successfully';					
				   end
				else
					begin
						set @create_Payment_message = 'Patient or Staff dont exist or Paid ammount is less than zero';
						print 'Patient or Staff dont exist or Paid ammount is less than zero';
					end
			end
		else
			begin
				set @create_Payment_message = 'cannot add Payment';
				print 'You can not add Payment';
			end
	end try
	begin catch
		set @create_Payment_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING ADDING A PAYMENT';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

go

-- trying it out
declare @result nvarchar(max);
exec supplyChain.createPayments
@staffroleId = 107,  
@paymentMethod = 'Cash',
@patientId = 2, 
@staffId = 1,
@paidAmmount = 100,
@create_Payment_message = @result output;

print 'Result: ' + @result;

select * from users.Patients

select * from users.Staff

select * from supplyChain.Payments











