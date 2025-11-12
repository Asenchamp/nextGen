use HospitalERp;

create table supplyChain.Categories(
	categories_id int primary key identity(100,1),
	category_name nvarchar(50) not null unique,
	category_description text not null,
	created_at datetime default(getdate()),
	updated_at datetime,
	is_deleted bit default(0) not null
);


create table supplyChain.Products(
	product_id nvarchar(30) unique not null,
	categories_id int not null,
	product_name nvarchar(30) unique not null,
	product_Qty int not null check(product_Qty >= 0),
	product_saling_price float not null check(product_saling_price > 0),
	updated_at datetime,
	is_deleted bit default(0) not null,
	foreign key(categories_id) references supplyChain.Categories(categories_id)
);


create table supplyChain.Purchased_products(
	purchase_id int primary key identity(100,1),
	product_id nvarchar(30) not null,
	product_Qty int not null check(product_Qty > 0),
	product_buying_price float not null check(product_buying_price > 0),
	product_purchase_date datetime not null,
	product_manufacture_date date not null,
	product_expiry_date date,
	product_supplier_info text not null,
	updated_at datetime,
	is_deleted bit default(0) not null,
	foreign key(product_id) references supplyChain.Products(product_id)
);

create table supplyChain.Supplies(
	supply_id int primary key identity(100,1),
	product_id nvarchar(30) not null,
	supply_Qty int not null check(supply_Qty > 0),
	staff_id int not null,
	reason text,
	supply_issue_date datetime default(getdate()) not null,
	updated_at datetime,
	is_deleted bit default(0) not null,
	foreign key (product_id) references supplyChain.Products(product_id),
	foreign key (staff_id) references users.Staff(staff_id)
);

create table supplyChain.Bills(
	bill_id int primary key identity(100,1),
	patient_id int not null,
	service_name nvarchar(25) not null,
	service_id int not null,
	service_price int not null,
	bill_date datetime default(getdate()) not null,
	updated_at datetime,
	is_deleted bit default(0) not null,
	foreign key (patient_id) references users.Patients(patient_id),
);

create table supplyChain.Payments(
	payment_id int primary key identity(100,1),
	payment_method nvarchar(25) check(payment_method in ('Cash', 'Insurance','Card','Mobile Money')) not null,
	patient_id int not null,
	staff_id int not null,
	paid_ammount float not null check(paid_ammount > 0),
	created_at datetime default(getdate()) not null,
	updated_at datetime,
	is_deleted bit default(0) not null,
);



