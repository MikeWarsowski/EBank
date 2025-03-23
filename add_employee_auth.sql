-- First, ensure the Employees table exists with EmployeeID as primary key
IF NOT EXISTS (SELECT * FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[Employees]') AND type in (N'U'))
BEGIN
    CREATE TABLE Employees (
        EmployeeID INT IDENTITY(1,1) PRIMARY KEY,
        EmployeeNumber VARCHAR(50) NOT NULL UNIQUE,
        FirstName VARCHAR(100) NOT NULL,
        LastName VARCHAR(100) NOT NULL,
        Title VARCHAR(50) NOT NULL,
        CanCreateNewAccount BIT NOT NULL DEFAULT 0,
        HourlySalary DECIMAL(10,2) NOT NULL,
        Address VARCHAR(255) NOT NULL,
        City VARCHAR(100) NOT NULL,
        State VARCHAR(2) NOT NULL,
        ZipCode VARCHAR(20) NOT NULL,
        EmailAddress VARCHAR(100) NOT NULL UNIQUE,
        Password VARCHAR(255) NOT NULL DEFAULT 'default123'
    );
END

-- Add Password column to Employees table if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Employees]') AND name = 'Password')
BEGIN
    ALTER TABLE Employees
    ADD Password VARCHAR(255) NOT NULL DEFAULT 'default123';
END

-- Add EmployeeID column to Transactions table if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.columns WHERE object_id = OBJECT_ID(N'[dbo].[Transactions]') AND name = 'EmployeeID')
BEGIN
    ALTER TABLE Transactions
    ADD EmployeeID INT NULL;
END

-- Add foreign key constraint if it doesn't exist
IF NOT EXISTS (SELECT * FROM sys.foreign_keys WHERE object_id = OBJECT_ID(N'[dbo].[FK_Transactions_Employees]'))
BEGIN
    ALTER TABLE Transactions
    ADD CONSTRAINT FK_Transactions_Employees
    FOREIGN KEY (EmployeeID) REFERENCES Employees(EmployeeID);
END

-- Update existing transactions with a default employee (you'll need to modify this based on your data)
UPDATE Transactions
SET EmployeeID = (SELECT TOP 1 EmployeeID FROM Employees)
WHERE EmployeeID IS NULL;

-- Make EmployeeID NOT NULL after updating existing records
ALTER TABLE Transactions
ALTER COLUMN EmployeeID INT NOT NULL; 