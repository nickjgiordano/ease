/*
	Module	CSC-20002 | Database Systems
	Student	18016431

	EASE Limited Database | create views used by PHP front end
	Version 1.0 (2019-04-25)
*/

CREATE OR REPLACE VIEW v_Supplier AS
SELECT Supplier.ID, Name, Street, Town, Postcode, Phone, Email, (SELECT Name FROM Contact WHERE ID = Branch_ID) AS Supplies, (SELECT ID FROM Contact WHERE ID = Branch_ID) AS link_Branch__ID
FROM Supplier INNER JOIN Contact ON Supplier.ID = Contact.ID LEFT JOIN Supply ON Supplier.ID = Supplier_ID
ORDER BY ID;

CREATE OR REPLACE VIEW v_Branch AS
SELECT Branch.ID, Name, Street, Town, Postcode, Phone, Email, Branch.ID AS link_Room__hide_
FROM Branch INNER JOIN Contact ON Branch.ID = Contact.ID
ORDER BY ID;

CREATE OR REPLACE VIEW v_Employee AS
SELECT Employee.ID, Name, DOB, Street, Town, Postcode, Phone, Email, (SELECT Name FROM Contact WHERE ID = Branch_ID) AS Works_At, Job_Title, (SELECT ID FROM Contact WHERE ID = Branch_ID) AS link_Branch__ID
FROM Employee INNER JOIN Person ON Employee.ID = Person.ID INNER JOIN Contact ON Employee.ID = Contact.ID
ORDER BY ID;

CREATE OR REPLACE VIEW v_Customer AS
SELECT Customer.ID, Name, DOB, Street, Town, Postcode, Phone, Email,(CASE WHEN Customer.ID = Business_Customer.ID THEN 'Y' ELSE 'N' END) AS bool_Business_Customer,
Marketing AS bool_Marketing, Customer.ID AS link_Room_Booking__hide_
FROM Customer INNER JOIN Person ON Customer.ID = Person.ID INNER JOIN Contact ON Customer.ID = Contact.ID
LEFT JOIN Business_Customer ON Customer.ID = Business_Customer.ID
ORDER BY ID;

CREATE OR REPLACE VIEW v_Room AS
SELECT Standard_Room.ID, Name AS Branch, Room_Size, Hourly_Rate AS curr_Hourly_Rate, 'N' AS bool_Executive_Room, Branch_ID AS link_Branch__ID, Branch_ID AS hide_
FROM Standard_Room INNER JOIN Room ON Standard_Room.ID = Room.ID INNER JOIN Contact ON Branch_ID = Contact.ID
UNION
SELECT Executive_Room.ID, Name, Room_Size, Hourly_Rate, 'Y', Executive_Room.ID, Branch_ID
FROM Executive_Room INNER JOIN Room ON Executive_Room.ID = Room.ID INNER JOIN Contact ON Branch_ID = Contact.ID
ORDER BY ID;

CREATE OR REPLACE VIEW u_Room_Booking AS
SELECT Standard_Room_Booking.ID, Start_Time, Duration, 'N' AS Executive_Room, Decorations, 'N' AS Buffet, Booking_ID, Room_ID
FROM Room_Booking INNER JOIN Standard_Room_Booking ON Room_Booking.ID = Standard_Room_Booking.ID
UNION
SELECT Executive_Room_Booking.ID, Start_Time, Duration, 'Y', 'N', Buffet, Booking_ID, Room_ID
FROM Room_Booking INNER JOIN Executive_Room_Booking ON Room_Booking.ID = Executive_Room_Booking.ID;

CREATE OR REPLACE VIEW u_Booking AS
SELECT u_Room_Booking.ID, Start_Time, Duration, Executive_Room, Decorations, Buffet, 'N' AS Invoice, Booking_ID, Room_ID, Customer_ID
FROM u_Room_Booking INNER JOIN Standard_Booking ON Booking_ID = Standard_Booking.ID
UNION
SELECT u_Room_Booking.ID, Start_Time, Duration, Executive_Room, Decorations, Buffet, Invoice, Booking_ID, Room_ID, Customer_ID
FROM u_Room_Booking INNER JOIN Business_Booking ON Booking_ID = Business_Booking.ID;

CREATE OR REPLACE VIEW v_Room_Booking AS
SELECT u_Booking.ID, Name AS Customer, CAST(Start_Time AS DATE) AS Event_Date,
CAST(Start_Time AS TIME) AS Start_Time, CAST(CAST(Start_Time + 1/24*Duration AS TIMESTAMP) AS TIME) AS End_Time,
(SELECT Name FROM Contact WHERE ID = Branch_ID) AS Branch, Room_Size, Executive_Room AS bool_Executive_Room, Decorations AS bool_Decorations, Buffet AS bool_Buffet,
Booking_ID AS link_Booking__ID, Customer_ID AS hide_
FROM u_Booking INNER JOIN Room ON Room_ID = Room.ID INNER JOIN Contact ON Customer_ID = Contact.ID
ORDER BY ID;

CREATE OR REPLACE VIEW v_Booking AS
SELECT Booking.ID, Name AS Customer, COUNT(Booking.ID) AS Number_of_Rooms, Cost AS curr_Cost, Invoice AS bool_Invoice, Customer_ID AS link_Customer__ID
FROM u_Booking INNER JOIN Booking ON Booking_ID = Booking.ID INNER JOIN Contact ON Customer_ID = Contact.ID
GROUP BY Booking.ID, Name, Cost, Invoice, Customer_ID ORDER BY ID;