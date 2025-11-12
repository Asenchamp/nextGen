use HospitalERp;

create table clinics.Triage(
	triage_id int primary key identity(1,1),
	staff_id int,
	patient_id int,
	triage_findings nvarchar(30) not null,
	created_at datetime default(getdate()) not null,
	update_at datetime,
	is_deleted bit default(0),
	foreign key (staff_id) references users.Staff(staff_id),
	foreign key (patient_id) references users.Patients(patient_id),
);

create table clinics.Condition(
	condition_id int primary key identity(1,1),
	condition_name nvarchar(30) not null unique,
	condition_description nvarchar(30) not null,
	condition_status nvarchar(10) check(condition_status in('permanent','temporary')),
	created_at datetime default(getdate()) not null,
	update_at datetime,
	is_deleted bit default(0),
);

create table clinics.Diagnosis(
    diagnosis_id int primary key identity(1,1),
    patient_id int,
    doctor_id int,
    condition_id int,
    diagnosis_symptoms text,
    diagnosis_note text,
	created_at datetime default(getdate()) not null,
	update_at datetime,
	is_deleted bit default(0),
    foreign key (patient_id) references users.Patients(patient_id),
	foreign key (doctor_id) references users.Staff(staff_id),
    foreign key (condition_id) references clinics.Condition(condition_id)
);

create table clinics.Testtype(
	test_type_id int primary key identity(1,1),
	test_type_name nvarchar(30) not null unique,
	created_at datetime default(getdate()) not null,
	update_at datetime,
	is_deleted bit default(0),
);

create table clinics.Samples(
	sample_id int primary key identity(1,1),
	patient_id int,
	sample_label nvarchar(30) not null unique,
	created_at datetime default(getdate()) not null,
	update_at datetime,
	is_deleted bit default(0),
	foreign key (patient_id) references users.Patients(patient_id),
);

create table clinics.Labrequests(
	labrequest_id int primary key identity(1,1),
	patient_id int,
	doctor_id int,
	test_type_id int,
	labrequest_notes varchar(100),
	created_at datetime default(getdate()) not null,
	update_at datetime,
	is_deleted bit default(0),
	foreign key (doctor_id) references users.Staff(staff_id),
	foreign key (test_type_id) references clinics.Testtype(test_type_id),
	foreign key (patient_id) references users.Patients(patient_id),
);

create table clinics.Labresults(
	labresult_id int primary key identity(1,1),
	labrequest_id int,
	technician_id int,
	sample_label nvarchar(30),
	labrequest_results varchar(100),
	labresult_notes varchar(100),
	created_at datetime default(getdate()) not null,
	update_at datetime,
	is_deleted bit default(0),
	foreign key (technician_id) references users.Staff(staff_id),
	foreign key (sample_label) references clinics.Samples(sample_label),
);

create table clinics.Prescriptions(
    prescription_id int primary key identity(1,1),
    staff_id int,
	diagnosis_id int,
    patient_id int,
	drug nvarchar(30),
    dose nvarchar(100),
    frequency nvarchar(100),
    prescription_days int,
    drugs_quantity int  check(drugs_quantity >= 0),
    prescription_notes text,
	created_at datetime default(getdate()) not null,
	update_at datetime,
	is_deleted bit default(0),
    foreign key (staff_id) references users.Staff(staff_id),
    foreign key (patient_id) references users.Patients(patient_id),
	foreign key (diagnosis_id) references clinics.Diagnosis(diagnosis_id)
);



