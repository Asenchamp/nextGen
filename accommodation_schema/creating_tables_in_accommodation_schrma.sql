use HospitalERp;

create table accommodation.Wards(
	ward_id int primary key identity(1,1),
	department_id int,
	ward_number nvarchar(25) not null unique,
	ward_type nvarchar(25) check(ward_type in ('private','public')),
	created_at datetime default(getdate()),
	updated_at datetime,
	is_deleted bit default(0),
	foreign key (department_id) references users.Department(department_id)
);

create table accommodation.Beds(
	bed_id int primary key identity(1,1),
	bed_number nvarchar(25) not null unique,
	bed_status varchar(15) check(bed_status in ('Available','Unaviable')),
	ward_id int,
	created_at datetime default(getdate()),
	updated_at datetime,
	is_deleted bit default(0),
	foreign key (ward_id) references accommodation.Wards(ward_id)
);

create table accommodation.Admissions(
	admission_id int primary key identity(1,1),
	staff_id int not null,
	patient_id int not null,
	bed_id int not null,
	admission_notes nvarchar(100),
	admission_created_at datetime default(getdate()),
	admission_ended_at datetime,
	updated_at datetime,
	is_deleted bit default(0),
	foreign key (staff_id) references users.Staff(staff_id),
	foreign key (patient_id) references users.Patients(patient_id),
	foreign key (bed_id) references accommodation.Beds(bed_id),
	unique(patient_id,admission_ended_at)
);

create table accommodation.ClipBoard(
	clipboard_id int primary key identity(1,1),
	admission_id int not null,
	staff_id int,
	findings nvarchar(100) not null,
	created_at datetime default(getdate()),
	updated_at datetime,
	is_deleted bit default(0),
	foreign key (staff_id) references users.Staff(staff_id),
	foreign key (admission_id) references accommodation.Admissions(admission_id),
);

create table accommodation.Ambulances (
    ambulance_id int primary key identity(1,1),
    ambulance_registration_number nvarchar(100) not null unique,
    ambulance_contact_phone nvarchar(30),
    ambulance_status nvarchar(25) default('Available') check(ambulance_status in ('Available','Dispatched')),
	created_at datetime default(getdate()),
	updated_at datetime,
	is_deleted bit default(0),
);

create table accommodation.AmbulancesDispatchLogs (
    dispatch_id int primary key identity(1,1),
    ambulance_registration_number nvarchar(100) not null,
    staff_id int not null,
    destination NVARCHAR(300) not null,
    notes text,
	dispatched_at datetime default(getdate()),
	updated_at datetime,
	returned_at datetime,
	is_deleted bit default(0),
	foreign key (staff_id) references users.Staff(staff_id),
	foreign key (ambulance_registration_number) references accommodation.Ambulances(ambulance_registration_number),
	unique(ambulance_registration_number, returned_at)
);



