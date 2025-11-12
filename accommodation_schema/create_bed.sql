use HospitalERp;

-- dummy data

-- system Permissions
insert into users.Permissions(permission_name, permission_description) values
('createBed','You are able to add a Bed')

-- permissions for particular roles
insert into users.Role_Permissions values
(106,155)

select * from users.Permissions
select * from users.Roles
select * from users.Role_Permissions

go

create or alter procedure accommodation.createBed
@staffroleId int,
@bedNumber nvarchar(25), 
@wardId int,
@create_Bed_message nvarchar(max) output
with encryption
as 
begin
	begin try
		-- stores the permission id
		declare @permmissionId int
		select @permmissionId = permission_id from users.Permissions
		where permission_name = 'createBed'

		-- check whether the user has that permission
		if exists(select * from users.Role_Permissions
					where role_id = @staffroleId and permission_id = @permmissionId and is_deleted != 1)
			begin
				if exists(select * from accommodation.Wards where ward_id = @wardId and is_deleted != 1)
				   begin
						print('You can add a Bed')
						insert into accommodation.Beds
						(bed_number,bed_status, ward_id)
						values
						(@bedNumber, 'Available', @wardId)
						set @create_Bed_message = 'Bed added';
						print '=====================================================';
						print 'Bed added successfully';					
				   end
				else
					begin
						set @create_Bed_message = 'Ward dont exist';
						print 'Ward dont exist';
					end
			end
		else
			begin
				set @create_Bed_message = 'cannot add Bed';
				print 'You can not cannot add Bed';
			end
	end try
	begin catch
		set @create_Bed_message = ERROR_NUMBER();
		print '=====================================================';
		print 'ERROR OCCURED DURING ADDING A BED';
		print 'Error Message '+ERROR_MESSAGE();
		print 'Error Number '+cast(ERROR_NUMBER() as nvarchar);
		print 'Error State '+cast(ERROR_STATE() as nvarchar);
		print '=====================================================';
	end catch
end

-- trying it out
declare @result nvarchar(max);

exec accommodation.createBed
@staffroleId = 106,  
@bedNumber = '##007', 
@wardId = 1,
@create_Bed_message = @result output;

print 'Result: ' + @result;

select * from accommodation.Beds















