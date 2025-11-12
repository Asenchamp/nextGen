use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('readorfilterBeds','You are able to read or filter  specialisation')

-- permissions for particular roles
insert into users.Role_Permissions values
(106,157)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

-- readorfilter beds stored procedure
create or alter procedure accommodation.readorfilterBeds
@staffroleId int, 
@bedNumber nvarchar(25) = null,
@bedStatus varchar(15) = null,
@wardType nvarchar(25) = null,
@readorfilter_Bed_message nvarchar(max) output
with encryption
as
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'readorfilterBeds'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
					where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can read or filter beds')
				select 
					w.ward_number as 'WARD NUMBER',
					w.ward_type as 'WARD TYPE',
					b.bed_number as 'BED NUMBER',
					b.bed_status as 'BED STATUS'
				from accommodation.Beds as b
				left join accommodation.Wards as w
				on b.ward_id = w.ward_id
				where
				( @bedNumber is null or b.bed_number like '%' + @bedNumber + '%') and
				( @bedStatus is null or b.bed_status like '%' + @bedStatus + '%') and										
				( @wardType is null or w.ward_type like '%' + @wardType + '%') and 
				b.is_deleted != 1;
			end
		else
			begin
				set @readorfilter_Bed_message = 'cannot read or filter beds';
				print 'You can not read or filter beds';
			end
	end try
	begin catch
		set @readorfilter_Bed_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING READING OR FILTERING BEDS';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

-- trying it out
declare @result nvarchar(max);

exec accommodation.readorfilterBeds
@staffroleId = 106,  
@bedNumber = null, 
@bedStatus = null, 
@wardType = null, 
@readorfilter_Bed_message = @result output;

print 'Result: ' + @result;



select 
	w.ward_number as 'WARD NUMBER',
	w.ward_type as 'WARD TYPE',
	b.bed_number as 'BED NUMBER',
	b.bed_status as 'BED STATUS'
from accommodation.Beds as b
left join accommodation.Wards as w
on b.ward_id = w.ward_id