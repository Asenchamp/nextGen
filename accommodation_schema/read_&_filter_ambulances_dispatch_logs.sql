use HospitalERp;

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('readorfilterAmbulancesDispatchLogs','You are able to read or filter Ambulances Dispatch Logs')

-- permissions for particular roles
insert into users.Role_Permissions values
(106,171)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

-- readorfilter users stored procedure
create or alter procedure accommodation.readorfilterAmbulancesDispatchLogs
@staffroleId int, 
@staffId int = null,
@ambulanceRegno nvarchar(100) = null,
@Destination nvarchar(300) = null,
@readorfilter_AmbulancesDispatchLogs_message nvarchar(max) output
with encryption
as
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'readorfilterAmbulancesDispatchLogs'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
					where role_id = @staffroleId and permission_id = @permmissionId)
			begin
				print('You can read or filter Ambulances Dispatch Logs')
				select 
					a.ambulance_registration_number as 'AMBULANCE REG NUMBER',
					a.destination as 'DESTINATION',
					u.user_full_Name as 'DRIVER',
					a.dispatched_at as 'DISPATCH TIME'
				from accommodation.AmbulancesDispatchLogs as a
				left join users.Staff as s
				on a.staff_id = s.staff_id
				left join users.Users as u
				on s.user_id = u.user_id
				where
				( @staffId is null or a.staff_id = @staffId ) and
				( @ambulanceRegno is null or a.ambulance_registration_number like '%'+ @ambulanceRegno +'%' ) and
				( @Destination is null or a.destination like '%' + @Destination + '%') and
				a.returned_at = null and a.is_deleted = 0;
			end
		else
			begin
				set @readorfilter_AmbulancesDispatchLogs_message = 'cannot read or filter Ambulances Dispatch Logs';
				print 'You can not read or filter Ambulances Dispatch Logs';
			end
	end try
	begin catch
		set @readorfilter_AmbulancesDispatchLogs_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING READING OR FILTERING AMBULANCES DISPATCH LOGS';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

go

-- trying it out
declare @result nvarchar(max);
exec accommodation.readorfilterAmbulancesDispatchLogs 
@staffroleId = 106, 
@staffId = null,
@ambulanceRegno = null,
@Destination = null,
@readorfilter_AmbulancesDispatchLogs_message = @result output;

print 'Result: ' + @result;



select 
	a.ambulance_registration_number as 'AMBULANCE REG NUMBER',
	a.destination as 'DESTINATION',
	u.user_full_Name as 'DRIVER',
	a.dispatched_at as 'DISPATCH TIME'
from accommodation.AmbulancesDispatchLogs as a
left join users.Staff as s
on a.staff_id = s.staff_id
left join users.Users as u
on s.user_id = u.user_id


select * from accommodation.AmbulancesDispatchLogs


