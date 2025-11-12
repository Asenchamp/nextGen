use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('readorfilterPayments','You are able to read or filter payments')

-- permissions for particular roles
insert into users.Role_Permissions values
(107,187)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

-- readorfilter beds stored procedure
create or alter procedure supplyChain.readorfilterPayments
@staffroleId int,
@paymentMethod nvarchar(25) = null,
@patientId int = null,
@staffId int = null,
@paymentDate date = null,
@readorfilter_Payment_message nvarchar(max) output
with encryption
as
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'readorfilterPayments'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
					where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can read or filter Payments')
				select 
					up.user_full_Name as 'PATIENT NAME',
					up.user_gender as 'GENDER',
					us.user_full_Name as 'RECEIVER NAME',
					p.paid_ammount as 'PAID AMMOUNT',
					p.payment_method as 'PAYMENT METHOD',
					p.created_at as 'DATE'
				from supplyChain.Payments as p
				left join users.Patients as pt
				on p.patient_id = pt.patient_id
				left join users.Users as up
				on pt.user_id = up.user_id
				left join users.Staff as s
				on p.staff_id = s.staff_id
				left join users.Users as us
				on s.user_id = us.user_id
				where
				( @paymentMethod is null or p.payment_method like '%' + @paymentMethod + '%') and
				( @patientId is null or p.patient_id = @patientId) and
				( @staffId is null or p.staff_id = @staffId) and
				( @paymentDate is null or p.created_at = @paymentDate) and
				p.is_deleted != 1;
			end
		else
			begin
				set @readorfilter_Payment_message = 'cannot read or filter payments';
				print 'You can not read or filter payments';
			end
	end try
	begin catch
		set @readorfilter_Payment_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING READING OR FILTERING PAYMENTS';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

go

-- trying it out
declare @result nvarchar(max);
exec supplyChain.readorfilterPayments
@staffroleId = 107,  
@paymentMethod = null,
@patientId = null,
@staffId = null,
@paymentDate = null,
@readorfilter_Payment_message = @result output;

print 'Result: ' + @result;

select * from supplyChain.Payments

select 
	up.user_full_Name as 'PATIENT NAME',
	up.user_gender as 'GENDER',
	us.user_full_Name as 'RECEIVER NAME',
	p.paid_ammount as 'PAID AMMOUNT',
	p.payment_method as 'PAYMENT METHOD',
	p.created_at as 'DATE'
from supplyChain.Payments as p
left join users.Patients as pt
on p.patient_id = pt.patient_id
left join users.Users as up
on pt.user_id = up.user_id
left join users.Staff as s
on p.staff_id = s.staff_id
left join users.Users as us
on s.user_id = us.user_id
