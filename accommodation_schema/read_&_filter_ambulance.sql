use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('readorfilterAmbulance','You are able to read or filter Ambulances')

-- permissions for particular roles
insert into users.Role_Permissions values
(106,168)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure accommodation.readorfilterAmbulance
@staffroleId int, 
@ambulanceRegno nvarchar(100) = null,
@ambulanceStatus nvarchar(25) = null,
@readorfilter_Ambulance_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'readorfilterAmbulance'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
				  where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can read or filter ambulances')
				select 
					a.ambulance_registration_number as 'REGISTRATION NUMBER',
					a.ambulance_contact_phone as 'CONTACT PHONE',
					a.ambulance_status as 'STATUS'
				from accommodation.Ambulances as a
				where 
				( @ambulanceRegno is null or a.ambulance_registration_number like '%'+ @ambulanceRegno + '%') and
				( @ambulanceStatus is null or a.ambulance_status like '%' + @ambulanceStatus + '%') and
				 a.is_deleted = 0;
			end
		else
			begin
				set @readorfilter_Ambulance_message = 'cannot read or filter ambulances';
				print 'You can not read or filter ambulances';
			end
	end try
	begin catch
		set @readorfilter_Ambulance_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING GETTING AN AMBULANCE';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

-- trying it out
declare @result nvarchar(max);
exec accommodation.readorfilterAmbulance
@staffroleId = 106,
@ambulanceRegno = null,
@ambulanceStatus = null,
@readorfilter_Ambulance_message = @result output;

print 'Result: ' + @result;




select * from accommodation.Ambulances 



