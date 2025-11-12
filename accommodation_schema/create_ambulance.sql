use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('createAmbulance','You are able to add an Ambulance')

-- permissions for particular roles
insert into users.Role_Permissions values
(106,165)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure accommodation.createAmbulance
@staffroleId int,
@ambulanceRegno nvarchar(100),
@ambulanceContactphone nvarchar(30),
@create_Ambulance_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'createAmbulance'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
				  where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				insert into accommodation.Ambulances
				(ambulance_registration_number, ambulance_contact_phone)
				values
				(@ambulanceRegno, @ambulanceContactphone)
				set @create_Ambulance_message = 'Ambulance added';
				print '=====================================================';
				print 'Ambulance: added successfully';					
			end
		else
			begin
				set @create_Ambulance_message = 'cannot add an ambulance';
				print 'You can not add an ambulance';
			end
	end try
	begin catch
		set @create_Ambulance_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING ADDING AN AMBULANCE';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end



-- trying it out
declare @result nvarchar(max);
exec accommodation.createAmbulance
@staffroleId = 106,  
@ambulanceRegno = '##0994',
@ambulanceContactphone = null,
@create_Ambulance_message = @result output;
print 'Result: ' + @result;

select * from accommodation.Ambulances
