-- Create the WBank Database
USE [master]
GO

IF DB_ID('WBank') IS NOT NULL
ALTER DATABASE WBank
SET SINGLE_USER 
WITH ROLLBACK IMMEDIATE
GO

IF DB_ID('WBank') IS NOT NULL
DROP DATABASE WBank
GO

CREATE DATABASE WBank
GO

USE WBank
GO

-- Create Locations Table
IF OBJECT_ID('Locations', 'U') IS NULL
CREATE TABLE Locations (
    LocationID INT PRIMARY KEY,
    LocationCode VARCHAR(50) NOT NULL UNIQUE,
    Address VARCHAR(255) NOT NULL,
    City VARCHAR(100) NOT NULL,
    State CHAR(2) NOT NULL
);

-- Create AccountType Table
IF OBJECT_ID('AccountType', 'U') IS NULL
CREATE TABLE AccountType (
    AccountTypeID INT PRIMARY KEY,
    AccountType VARCHAR(50) NOT NULL UNIQUE
);

-- Create Employees Table
IF OBJECT_ID('Employees', 'U') IS NULL
CREATE TABLE Employees (
    EmployeeID INT PRIMARY KEY,
    EmployeeNumber VARCHAR(50) NOT NULL UNIQUE,
    FirstName VARCHAR(100) NOT NULL,
    LastName VARCHAR(100) NOT NULL,
    Title VARCHAR(50) NOT NULL,
    CanCreateNewAccount BIT DEFAULT 0 NOT NULL,
    HourlySalary DECIMAL(10, 2) NOT NULL CHECK (HourlySalary > 0),
    Address VARCHAR(255) NOT NULL,
    City VARCHAR(100) NOT NULL,
    State CHAR(2) NOT NULL,
    ZipCode VARCHAR(20) NOT NULL,
    EmailAddress VARCHAR(100) NOT NULL UNIQUE
);

-- Create Customers Table
IF OBJECT_ID('Customers', 'U') IS NULL
CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    DateCreated DATETIME DEFAULT GETDATE(),
    AccountNumber VARCHAR(50) NOT NULL UNIQUE,
    AccountTypeID INT NOT NULL,
    Fname VARCHAR(100) NOT NULL,
    Lname VARCHAR(100) NOT NULL,
    Gender VARCHAR(10) NOT NULL CHECK (Gender IN ('Male', 'Female', 'Other')),
    Address VARCHAR(255) NOT NULL,
    City VARCHAR(100) NOT NULL,
    State CHAR(2) NOT NULL,
    PhoneNumber VARCHAR(15) NOT NULL UNIQUE,
    EmailAddress VARCHAR(100) NOT NULL UNIQUE,
    FOREIGN KEY (AccountTypeID) REFERENCES AccountType(AccountTypeID)
);

-- Create Deposits Table
IF OBJECT_ID('Deposits', 'U') IS NULL
CREATE TABLE Deposits (
    DepositID INT PRIMARY KEY,
    LocationID INT NOT NULL,
    EmployeeID INT NOT NULL,
    CustomerID INT NOT NULL,
    DepositDate DATETIME DEFAULT GETDATE(),
    DepositAmount DECIMAL(10, 2) NOT NULL CHECK (DepositAmount > 0),
    FOREIGN KEY (LocationID) REFERENCES Locations(LocationID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Create Withdrawals Table
IF OBJECT_ID('Withdrawals', 'U') IS NULL
CREATE TABLE Withdrawals (
    WithdrawalID INT PRIMARY KEY,
    LocationID INT NOT NULL,
    EmployeeID INT NOT NULL,
    CustomerID INT NOT NULL,
    WithdrawalDate DATETIME DEFAULT GETDATE(),
    WithdrawalAmount DECIMAL(10, 2) NOT NULL CHECK (WithdrawalAmount > 0),
    WithdrawalSuccessful BIT DEFAULT 1 NOT NULL,
    FOREIGN KEY (LocationID) REFERENCES Locations(LocationID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Create CheckCashing Table
IF OBJECT_ID('CheckCashing', 'U') IS NULL
CREATE TABLE CheckCashing (
    CheckCashingID INT PRIMARY KEY,
    LocationID INT NOT NULL,
    EmployeeID INT NOT NULL,
    CustomerID INT NOT NULL,
    CheckCashingDate DATETIME DEFAULT GETDATE(),
    CheckCashingAmount DECIMAL(10, 2) NOT NULL CHECK (CheckCashingAmount > 0),
    FOREIGN KEY (LocationID) REFERENCES Locations(LocationID),
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);
GO

-- Insert Data into Locations
INSERT INTO Locations (LocationID, LocationCode, Address, City, State) VALUES
(1, 'LOC001', '123 Main St', 'New York', 'NY'),
(2, 'LOC002', '456 Maple St', 'San Francisco', 'CA'),
(3, 'LOC003', '789 Elm St', 'Denver', 'CO'),
(4, 'LOC004', '234 Birch St', 'Miami', 'FL'),
(5, 'LOC005', '567 Oak Ave', 'Chicago', 'IL'),
(6, 'LOC006', '890 Pine Blvd', 'Phoenix', 'AZ'),
(7, 'LOC007', '321 Cedar Rd', 'Houston', 'TX'),
(8, 'LOC008', '654 Walnut Ln', 'Seattle', 'WA'),
(9, 'LOC009', '987 Aspen Dr', 'Atlanta', 'GA'),
(10, 'LOC010', '135 Maple Ct', 'Boston', 'MA');

-- Insert Data into AccountType
INSERT INTO AccountType (AccountTypeID, AccountType) VALUES
(1, 'Savings'),
(2, 'Checking'),
(3, 'Business');

-- Insert Data into Employees
INSERT INTO Employees (EmployeeID, EmployeeNumber, FirstName, LastName, Title, CanCreateNewAccount, HourlySalary, Address, City, State, ZipCode, EmailAddress) VALUES
(1, 'EMP001', 'John', 'Doe', 'Manager', 1, 45.00, '789 Pine St', 'Austin', 'TX', '73301', 'john.doe@example.com'),
(2, 'EMP002', 'Alice', 'Johnson', 'Teller', 1, 30.00, '456 Elm St', 'Charlotte', 'NC', '28202', 'alice.johnson@example.com'),
(3, 'EMP003', 'Robert', 'Williams', 'Supervisor', 0, 50.00, '789 Pine Rd', 'Miami', 'FL', '33101', 'robert.williams@example.com'),
(4, 'EMP004', 'Emma', 'Brown', 'Manager', 1, 45.00, '101 Oak Ave', 'Seattle', 'WA', '98101', 'emma.brown@example.com'),
(5, 'EMP005', 'Lucas', 'Garcia', 'Teller', 1, 28.50, '789 Maple Ct', 'Denver', 'CO', '80202', 'lucas.garcia@example.com'),
(6, 'EMP006', 'Sophia', 'Martinez', 'Manager', 0, 55.00, '123 Cedar Ln', 'Austin', 'TX', '73301', 'sophia.martinez@example.com'),
(7, 'EMP007', 'Mason', 'Lee', 'Supervisor', 0, 47.50, '456 Walnut St', 'Phoenix', 'AZ', '85001', 'mason.lee@example.com'),
(8, 'EMP008', 'Ella', 'Clark', 'Teller', 1, 26.75, '789 Birch Blvd', 'Boston', 'MA', '02108', 'ella.clark@example.com'),
(9, 'EMP009', 'Liam', 'Lewis', 'Manager', 1, 53.25, '234 Aspen Dr', 'Chicago', 'IL', '60601', 'liam.lewis@example.com'),
(10, 'EMP010', 'Amelia', 'Young', 'Teller', 1, 25.00, '567 Cypress St', 'Atlanta', 'GA', '30301', 'amelia.young@example.com'),
(11, 'EMP011', 'James', 'Harris', 'Supervisor', 0, 48.50, '890 Fir Ave', 'Philadelphia', 'PA', '19019', 'james.harris@example.com'),
(12, 'EMP012', 'Isabella', 'Walker', 'Teller', 1, 27.50, '321 Spruce Rd', 'Nashville', 'TN', '37201', 'isabella.walker@example.com'),
(13, 'EMP013', 'Ethan', 'Hill', 'Manager', 0, 57.75, '654 Palm Ct', 'Los Angeles', 'CA', '90001', 'ethan.hill@example.com'),
(14, 'EMP014', 'Mia', 'Allen', 'Supervisor', 1, 44.00, '987 Cherry Ln', 'Dallas', 'TX', '75201', 'mia.allen@example.com'),
(15, 'EMP015', 'Noah', 'Scott', 'Teller', 1, 29.00, '135 Willow St', 'San Diego', 'CA', '92101', 'noah.scott@example.com'),
(16, 'EMP016', 'Charlotte', 'Green', 'Teller', 0, 28.00, '456 Redwood Ave', 'San Antonio', 'TX', '78201', 'charlotte.green@example.com'),
(17, 'EMP017', 'Jack', 'Adams', 'Manager', 1, 52.00, '789 Ash Ct', 'Portland', 'OR', '97201', 'jack.adams@example.com'),
(18, 'EMP018', 'Harper', 'Baker', 'Supervisor', 0, 46.00, '101 Beech Dr', 'Kansas City', 'MO', '64101', 'harper.baker@example.com'),
(19, 'EMP019', 'Henry', 'Carter', 'Teller', 1, 30.50, '234 Sycamore Rd', 'Columbus', 'OH', '43201', 'henry.carter@example.com'),
(20, 'EMP020', 'Evelyn', 'Perez', 'Manager', 1, 50.00, '567 Magnolia Blvd', 'Indianapolis', 'IN', '46201', 'evelyn.perez@example.com'),
(21, 'EMP021', 'Alexander', 'Mitchell', 'Supervisor', 1, 49.25, '890 Juniper St', 'Las Vegas', 'NV', '89101', 'alexander.mitchell@example.com'),
(22, 'EMP022', 'Scarlett', 'Ramirez', 'Teller', 1, 27.25, '321 Alder Ave', 'Charlotte', 'NC', '28203', 'scarlett.ramirez@example.com'),
(23, 'EMP023', 'Benjamin', 'Morris', 'Manager', 0, 58.00, '654 Sequoia Blvd', 'New Orleans', 'LA', '70112', 'benjamin.morris@example.com'),
(24, 'EMP024', 'Ava', 'Rodriguez', 'Teller', 1, 26.00, '987 Hickory Ln', 'Salt Lake City', 'UT', '84101', 'ava.rodriguez@example.com'),
(25, 'EMP025', 'Daniel', 'Bell', 'Supervisor', 0, 45.50, '135 Poplar Ct', 'Washington', 'DC', '20001', 'daniel.bell@example.com');

-- Insert Data into Customers
INSERT INTO Customers (CustomerID, DateCreated, AccountNumber, AccountTypeID, Fname, Lname, Gender, Address, City, State, PhoneNumber, EmailAddress) VALUES
(1, '2025-01-15', 'ACC12345', 1, 'Jane', 'Smith', 'Female', '321 Oak St', 'Seattle', 'WA', '555-1234', 'jane.smith@example.com'),
(2, '2025-02-01', 'ACC12346', 2, 'Michael', 'Brown', 'Male', '987 Birch Ln', 'San Francisco', 'CA', '555-2345', 'michael.brown@example.com'),
(3, '2025-02-02', 'ACC12347', 1, 'Olivia', 'Davis', 'Female', '654 Oak St', 'Miami', 'FL', '555-3456', 'olivia.davis@example.com'),
(4, '2025-02-03', 'ACC12348', 3, 'William', 'Martinez', 'Male', '321 Cedar Rd', 'Denver', 'CO', '555-4567', 'william.martinez@example.com'),
(5, '2025-02-04', 'ACC12349', 2, 'Sophia', 'Anderson', 'Female', '123 Maple St', 'New York', 'NY', '555-5678', 'sophia.anderson@example.com'),
(6, '2025-02-05', 'ACC12350', 1, 'James', 'Taylor', 'Male', '890 Walnut Ave', 'Seattle', 'WA', '555-6789', 'james.taylor@example.com'),
(7, '2025-02-06', 'ACC12351', 3, 'Emily', 'Wilson', 'Female', '567 Aspen Dr', 'Austin', 'TX', '555-7890', 'emily.wilson@example.com'),
(8, '2025-02-07', 'ACC12352', 2, 'Alexander', 'Thomas', 'Male', '234 Fir Ct', 'Chicago', 'IL', '555-8901', 'alexander.thomas@example.com'),
(9, '2025-02-08', 'ACC12353', 1, 'Mia', 'Moore', 'Female', '789 Pine Rd', 'Atlanta', 'GA', '555-9012', 'mia.moore@example.com'),
(10, '2025-02-09', 'ACC12354', 3, 'Benjamin', 'Clark', 'Male', '456 Cherry Blvd', 'Houston', 'TX', '555-1234', 'benjamin.clark@example.com'),
(11, '2025-02-10', 'ACC12355', 2, 'Ava', 'Lopez', 'Female', '135 Spruce Dr', 'Phoenix', 'AZ', '555-2345', 'ava.lopez@example.com'),
(12, '2025-02-11', 'ACC12356', 1, 'Mason', 'Hill', 'Male', '654 Palm Ln', 'Nashville', 'TN', '555-3456', 'mason.hill@example.com'),
(13, '2025-02-12', 'ACC12357', 3, 'Isabella', 'Harris', 'Female', '987 Redwood St', 'Boston', 'MA', '555-4567', 'isabella.harris@example.com'),
(14, '2025-02-13', 'ACC12358', 2, 'Lucas', 'Scott', 'Male', '123 Ash Ave', 'Portland', 'OR', '555-5678', 'lucas.scott@example.com'),
(15, '2025-02-14', 'ACC12359', 1, 'Charlotte', 'Lewis', 'Female', '456 Beech Rd', 'San Diego', 'CA', '555-6789', 'charlotte.lewis@example.com'),
(16, '2025-02-15', 'ACC12360', 3, 'Ethan', 'Young', 'Male', '789 Sycamore Blvd', 'Indianapolis', 'IN', '555-7890', 'ethan.young@example.com'),
(17, '2025-02-16', 'ACC12361', 2, 'Amelia', 'King', 'Female', '234 Juniper Ct', 'Philadelphia', 'PA', '555-8901', 'amelia.king@example.com'),
(18, '2025-02-17', 'ACC12362', 1, 'Henry', 'Perez', 'Male', '567 Alder Ln', 'Kansas City', 'MO', '555-9012', 'henry.perez@example.com'),
(19, '2025-02-18', 'ACC12363', 3, 'Harper', 'Sanchez', 'Female', '890 Cedar St', 'Columbus', 'OH', '555-1234', 'harper.sanchez@example.com'),
(20, '2025-02-19', 'ACC12364', 2, 'Daniel', 'Morris', 'Male', '321 Magnolia Dr', 'Dallas', 'TX', '555-2345', 'daniel.morris@example.com'),
(21, '2025-02-20', 'ACC12365', 1, 'Lily', 'Mitchell', 'Female', '654 Hickory Ct', 'Charlotte', 'NC', '555-3456', 'lily.mitchell@example.com'),
(22, '2025-02-21', 'ACC12366', 3, 'Jack', 'Ramirez', 'Male', '987 Poplar Blvd', 'New Orleans', 'LA', '555-4567', 'jack.ramirez@example.com'),
(23, '2025-02-22', 'ACC12367', 2, 'Scarlett', 'Bell', 'Female', '135 Sequoia Ln', 'Las Vegas', 'NV', '555-5678', 'scarlett.bell@example.com'),
(24, '2025-02-23', 'ACC12368', 1, 'Oliver', 'Carter', 'Male', '789 Alder Dr', 'Salt Lake City', 'UT', '555-6789', 'oliver.carter@example.com'),
(25, '2025-02-24', 'ACC12369', 3, 'Emma', 'Rodriguez', 'Female', '123 Juniper Rd', 'Washington', 'DC', '555-7890', 'emma.rodriguez@example.com');

-- Insert Data into Deposits
INSERT INTO Deposits (DepositID, LocationID, EmployeeID, CustomerID, DepositDate, DepositAmount) VALUES
(1, 1, 1, 1, '2025-01-20', 500.00),
(2, 2, 2, 2, '2025-03-01', 750.00),
(3, 3, 3, 3, '2025-03-02', 500.00),
(4, 4, 4, 4, '2025-03-03', 600.00),
(5, 5, 5, 5, '2025-03-04', 800.00),
(6, 6, 6, 6, '2025-03-05', 450.00),
(7, 7, 7, 7, '2025-03-06', 700.00),
(8, 8, 8, 8, '2025-03-07', 550.00),
(9, 9, 9, 9, '2025-03-08', 350.00),
(10, 10, 10, 10, '2025-03-09', 400.00),
(11, 1, 11, 11, '2025-03-10', 250.00),
(12, 2, 12, 12, '2025-03-11', 950.00),
(13, 3, 13, 13, '2025-03-12', 300.00),
(14, 4, 14, 14, '2025-03-13', 675.00),
(15, 5, 15, 15, '2025-03-14', 800.00);

-- Insert Data into Withdrawals
INSERT INTO Withdrawals (WithdrawalID, LocationID, EmployeeID, CustomerID, WithdrawalDate, WithdrawalAmount, WithdrawalSuccessful) VALUES
(1, 1, 1, 1, '2025-01-21', 200.00, 1),
(2, 2, 2, 2, '2025-04-01', 300.00, 1),
(3, 3, 3, 3, '2025-04-02', 500.00, 1),
(4, 4, 4, 4, '2025-04-03', 450.00, 1),
(5, 5, 5, 5, '2025-04-04', 700.00, 1),
(6, 6, 6, 6, '2025-04-05', 350.00, 1),
(7, 7, 7, 7, '2025-04-06', 800.00, 1),
(8, 8, 8, 8, '2025-04-07', 400.00, 1),
(9, 9, 9, 9, '2025-04-08', 250.00, 1),
(10, 10, 10, 10, '2025-04-09', 600.00, 1),
(11, 1, 11, 11, '2025-04-10', 550.00, 1),
(12, 2, 12, 12, '2025-04-11', 750.00, 1),
(13, 3, 13, 13, '2025-04-12', 200.00, 1),
(14, 4, 14, 14, '2025-04-13', 425.00, 1),
(15, 5, 15, 15, '2025-04-14', 575.00, 1);

-- Insert Data into CheckCashing
INSERT INTO CheckCashing (CheckCashingID, LocationID, EmployeeID, CustomerID, CheckCashingDate, CheckCashingAmount) VALUES
(1, 1, 1, 1, '2025-01-22', 300.00),
(2, 2, 2, 2, '2025-05-01', 250.00),
(3, 3, 3, 3, '2025-05-02', 400.00),
(4, 4, 4, 4, '2025-05-03', 300.00),
(5, 5, 5, 5, '2025-05-04', 450.00),
(6, 6, 6, 6, '2025-05-05', 500.00),
(7, 7, 7, 7, '2025-05-06', 350.00),
(8, 8, 8, 8, '2025-05-07', 600.00),
(9, 9, 9, 9, '2025-05-08', 375.00),
(10, 10, 10, 10, '2025-05-09', 275.00),
(11, 1, 11, 11, '2025-05-10', 425.00),
(12, 2, 12, 12, '2025-05-11', 325.00),
(13, 3, 13, 13, '2025-05-12', 500.00),
(14, 4, 14, 14, '2025-05-13', 475.00),
(15, 5, 15, 15, '2025-05-14', 525.00);
GO
