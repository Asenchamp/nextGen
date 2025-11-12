use HospitalERp;

-- dummy data
-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('createAmbulancesDispatchLogs','You are able to add Ambulances Dispatch Logs')

-- permissions for particular roles
insert into users.Role_Permissions values
(106,169)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure accommodation.createAmbulancesDispatchLogs
@staffroleId int, 
@ambulanceRegno nvarchar(100),
@staffId int,
@Destination nvarchar(300),
@Notes text = null,
@create_AmbulancesDispatchLogs_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'createAmbulancesDispatchLogs'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
					where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				print('You can add Ambulances Dispatch Logs')
				if exists(select * from accommodation.Ambulances where ambulance_registration_number = @ambulanceRegno and is_deleted != 1 ) and
				   exists(select * from users.Staff where staff_id = @staffId and is_deleted != 1)
				   begin
					insert into accommodation.AmbulancesDispatchLogs
					(ambulance_registration_number, staff_id, destination, notes)
					values
					(@ambulanceRegno, @staffId, @Destination, @Notes)
					set @create_AmbulancesDispatchLogs_message = 'Ambulance Dispatch Log added';
					print '=====================================================';
					print 'Ambulance Dispatch Log: added successfully';
					end
				else
					begin
						set @create_AmbulancesDispatchLogs_message = 'Either Ambulance or Doctor dont exist';
						print '=====================================================';
						print 'Either Ambulance or Doctor dont exist';
					end
			end
		else
			begin
				set @create_AmbulancesDispatchLogs_message = 'cannot add an Ambulance Dispatch Log';
				print 'You can not add Ambulance Dispatch Log';
			end
	end try
	begin catch
		set @create_AmbulancesDispatchLogs_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING ADDING AMBULANCE DISPATCH LOG';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

go

-- trying it out
declare @result nvarchar(max);
exec accommodation.createAmbulancesDispatchLogs
@staffroleId = 106,
@ambulanceRegno = '##0994',  
@staffId = 1,
@Destination = 'Mulago',
@Notes = null,
@create_AmbulancesDispatchLogs_message = @result output;

print 'Result: ' + @result;

select * from accommodation.AmbulancesDispatchLogs

select * from accommodation.Ambulances

select * from users.Staff















