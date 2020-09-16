/*
	Module	CSC-20002 | Database Systems
	Student	18016431

	EASE Limited Database | drop and create tables
	Version 1.0 (2019-04-25)
*/
DROP TABLE Standard_Room_Booking;
DROP TABLE Executive_Room_Booking;
DROP TABLE Room_Booking;

DROP TABLE Standard_Booking;
DROP TABLE Business_Booking;
DROP TABLE Booking;

DROP TABLE Standard_Room;
DROP TABLE Executive_Room;
DROP TABLE Room;

DROP TABLE Standard_Customer;
DROP TABLE Business_Customer;
DROP TABLE Customer;
DROP TABLE Employee;
DROP TABLE Person;

DROP TABLE Supply;
DROP TABLE Branch;
DROP TABLE Supplier;
DROP TABLE Contact;

CREATE TABLE Contact(
	ID INTEGER NOT NULL,
	Name VARCHAR2(70),
	Street VARCHAR2(35),
	Town VARCHAR2(35),
	Postcode VARCHAR2(35),
	Phone VARCHAR2(35),
	Email VARCHAR2(70),
	PRIMARY KEY (ID)
);
CREATE TABLE Supplier(
	ID INTEGER NOT NULL,
	PRIMARY KEY (ID),
	FOREIGN KEY (ID) REFERENCES Contact(ID) ON DELETE CASCADE -- makes Supplier subclass of Contact {Optional, OR}
);
CREATE TABLE Branch(
	ID INTEGER NOT NULL,
	PRIMARY KEY (ID),
	FOREIGN KEY (ID) REFERENCES Contact(ID) ON DELETE CASCADE -- makes Branch subclass of Contact {Optional, OR}
);
CREATE TABLE Supply(
	Supplier_ID INTEGER NOT NULL,
	Branch_ID INTEGER NOT NULL,
	PRIMARY KEY (Supplier_ID, Branch_ID),
	FOREIGN KEY (Supplier_ID) REFERENCES Supplier(ID), -- resolves many-to-many relationship between Supplier and Branch tables
	FOREIGN KEY (Branch_ID) REFERENCES Branch(ID) -- resolves many-to-many relationship between Supplier and Branch tables
);
CREATE TABLE Person(
	ID INTEGER NOT NULL,
	DOB DATE,
	PRIMARY KEY (ID),
	FOREIGN KEY (ID) REFERENCES Contact(ID) ON DELETE CASCADE -- makes Person subclass of Contact {Optional, OR}
);
CREATE TABLE Employee(
	ID INTEGER NOT NULL,
	Branch_ID INTEGER,
	Job_Title VARCHAR2(35),
	PRIMARY KEY (ID),
	FOREIGN KEY (ID) REFERENCES Person(ID) ON DELETE CASCADE, -- makes Employee subclass of Person {Optional, AND}
	FOREIGN KEY (Branch_ID) REFERENCES Branch(ID) -- zero to many employees employed by each branch
);
CREATE TABLE Customer(
	ID INTEGER NOT NULL,
	Marketing CHAR,
	PRIMARY KEY (ID),
	FOREIGN KEY (ID) REFERENCES Person(ID) ON DELETE CASCADE -- makes Customer subclass of Person {Optional, AND}
);
CREATE TABLE Standard_Customer(
	ID INTEGER NOT NULL,
	PRIMARY KEY (ID),
	FOREIGN KEY (ID) REFERENCES Customer(ID) ON DELETE CASCADE -- makes Standard_Customer subclass of Customer {Optional, OR}
);
CREATE TABLE Business_Customer(
	ID INTEGER NOT NULL,
	PRIMARY KEY (ID),
	FOREIGN KEY (ID) REFERENCES Customer(ID) ON DELETE CASCADE -- makes Business_Customer subclass of Customer {Optional, OR}
);
CREATE TABLE Room(
	ID INTEGER NOT NULL,
	Branch_ID INTEGER,
	Room_Size INTEGER, -- room capacity (number of people)
	Hourly_Rate DECIMAL(8,2), -- price (GBP)
	PRIMARY KEY (ID),
	FOREIGN KEY (Branch_ID) REFERENCES Branch(ID) -- 5 to 30 rooms located in each branch
);
CREATE TABLE Standard_Room(
	ID INTEGER NOT NULL,
	PRIMARY KEY (ID),
	FOREIGN KEY (ID) REFERENCES Room(ID) ON DELETE CASCADE -- makes Standard_Room subclass of Room {Mandatory, OR}
);
CREATE TABLE Executive_Room(
	ID INTEGER NOT NULL,
	PRIMARY KEY (ID),
	FOREIGN KEY (ID) REFERENCES Room(ID) ON DELETE CASCADE -- makes Executive_Room subclass of Room {Mandatory, OR}
);
CREATE TABLE Booking(
	ID INTEGER NOT NULL,
	Cost DECIMAL(8,2), -- new data for this field would be calculated by php front end; previously-calculated data entered below
	PRIMARY KEY (ID)
);
CREATE TABLE Standard_Booking(
	ID INTEGER NOT NULL,
	Customer_ID INTEGER,
	PRIMARY KEY (ID),
	FOREIGN KEY (ID) REFERENCES Booking(ID) ON DELETE CASCADE, -- makes Standard_Booking subclass of Booking {Mandatory, OR}
	FOREIGN KEY (Customer_ID) REFERENCES Customer(ID) -- 0 to many standard bookings made by each customer
);
CREATE TABLE Business_Booking(
	ID INTEGER NOT NULL,
	Customer_ID INTEGER,
	Invoice CHAR,
	PRIMARY KEY (ID),
	FOREIGN KEY (ID) REFERENCES Booking(ID) ON DELETE CASCADE, -- makes Business_Booking subclass of Booking {Mandatory, OR}
	FOREIGN KEY (Customer_ID) REFERENCES Business_Customer(ID) -- 0 to many business bookings made by each customer
);
CREATE TABLE Room_Booking(
	ID INTEGER NOT NULL,
	Start_Time TIMESTAMP, -- start time (date and nearest hour)
	Duration INTEGER, -- duration of booking (hours)
	PRIMARY KEY (ID)
);
CREATE TABLE Standard_Room_Booking(
	ID INTEGER NOT NULL,
	Room_ID INTEGER,
	Booking_ID INTEGER,
	Decorations CHAR, -- has customer requested decorations for booking?
	PRIMARY KEY (ID),
	FOREIGN KEY (ID) REFERENCES Room_Booking(ID) ON DELETE CASCADE, -- makes Standard_Room_Booking subclass of Room_Booking {Mandatory, OR}
	FOREIGN KEY (Room_ID) REFERENCES Standard_Room(ID), -- zero to many bookings made on each standard room
	FOREIGN KEY (Booking_ID) REFERENCES Booking(ID) -- zero to many standard room bookings made in each booking
);
CREATE TABLE Executive_Room_Booking(
	ID INTEGER NOT NULL,
	Room_ID INTEGER,
	Booking_ID INTEGER,
	Buffet CHAR, -- has customer requested buffet for booking?
	PRIMARY KEY (ID),
	FOREIGN KEY (ID) REFERENCES Room_Booking(ID) ON DELETE CASCADE, -- makes Standard_Room_Booking subclass of Room_Booking {Mandatory, OR}
	FOREIGN KEY (Room_ID) REFERENCES Executive_Room(ID), -- zero to many bookings made on each executive room
	FOREIGN KEY (Booking_ID) REFERENCES Business_Booking(ID) -- zero to many executive room bookings made in each business booking
);