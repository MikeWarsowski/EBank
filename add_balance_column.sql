-- Add Balance column to Customers table
ALTER TABLE Customers
ADD Balance DECIMAL(10,2) NOT NULL DEFAULT 0.00;

-- Create Transactions table
CREATE TABLE Transactions (
    TransactionID INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID INT NOT NULL,
    TransactionType VARCHAR(20) NOT NULL,
    Amount DECIMAL(10,2) NOT NULL,
    TransactionDate DATETIME NOT NULL DEFAULT GETDATE(),
    Description VARCHAR(255),
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
); 