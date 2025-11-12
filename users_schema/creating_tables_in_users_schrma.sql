use HospitalERp;

create table users.Roles(
	role_id int primary key identity(100,1),
	role_name nvarchar(35) unique not null,
	role_description nvarchar(100) not null,
	created_at datetime default(getdate()),
	updated_at datetime,
	is_deleted bit default(0)
);

create table users.Permissions(
	permission_id int primary key identity(100,1),
	permission_name nvarchar(35) unique not null,
	permission_description nvarchar(100) not null,
	created_at datetime default(getdate()),
	updated_at datetime,
	is_deleted bit default(0)
);

create table users.Role_Permissions(
	RP_id int primary key identity(100,1),
	role_id int,
	permission_id int,
	foreign key (role_id) references users.Roles(role_id),
	foreign key (permission_id) references users.Permissions(permission_id),
	unique(role_id,permission_id),
	created_at datetime default(getdate()),
	updated_at datetime,
	is_deleted bit default(0)
);

create table users.Department(
	department_id int primary key identity(100,1),
	department_name nvarchar(35) unique not null,
	department_description nvarchar(100) not null,
	created_at datetime default(getdate()),
	updated_at datetime,
	is_deleted bit default(0)
);

create table users.Specialisation(
	specialisation_id int primary key identity(100,1),
	department_id int,
	specialisation_name nvarchar(35) unique not null,
	description nvarchar(100) not null,
	created_at datetime default(getdate()),
	updated_at datetime,
	is_deleted bit default(0),
	foreign key (department_id) references users.Department(department_id)
);

create table users.Users(
	user_id int primary key identity(1,1),
	user_full_Name nvarchar(50) not null,
    user_email nvarchar(100) unique,
    user_phone_num nvarchar(20),
    user_password_hash nvarchar(255),
	user_gender nvarchar(5) check(user_gender in ('M','F')),
	user_DOB date,
	user_marital_status nvarchar(25),
	user_address nvarchar(50),
    user_status nvarchar(20) check(user_status in ('active','inactive')),
    created_at datetime default(getdate()),
	updated_at datetime,
	is_deleted bit default(0)
);

create table users.Patients(
    patient_id int primary key identity(1,1),
	user_id int,
	patient_medical_record_number nvarchar(25) not null unique,
    patient_blood_group nvarchar(5),
	patient_bmi nvarchar(25),
	patient_notes nvarchar(50),
	patient_emergency_name nvarchar(100),
    patient_emergency_contact nvarchar(100),
    created_at datetime default(getdate()),
	updated_at datetime,
	is_deleted bit default(0),
	foreign key (user_id) references users.Users(user_id),
);

create table users.Staff(
    staff_id int primary key identity(1,1),
    user_id int,
	staff_specialization int,
	staff_biodata varchar(20),
	staff_license_number varchar(20)not null,
    role_id int,
    created_at datetime default(getdate()),
	updated_at datetime,
	is_deleted bit default(0),
    foreign key (user_id) references users.Users(user_id),
    foreign key (staff_specialization) references users.Specialisation(specialisation_Id),
	foreign key (role_id) references users.Roles(role_id)
);

create table users.Appointments (
    appointment_id int primary key identity(1,1),
    patient_id int,
	request_date datetime,
    appointment_date datetime,
    appointment_status varchar(40) check(appointment_status in ('Approved','Pending','Declined','Finished')),
    notes text,
	department_id int,
	staff_id int,
	updated_at datetime,
	is_deleted bit default(0),
    foreign key (patient_id) references users.Patients(patient_id),
	foreign key (department_id) references users.Department(department_id),
	foreign key (staff_id) references users.Staff(staff_id)
);



