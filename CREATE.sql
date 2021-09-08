CREATE DATABASE softwAErHouse

--Staff
CREATE TABLE Staff(
 StaffID CHAR(5) PRIMARY KEY CHECK (StaffID LIKE 'SF[0-9][0-9][0-9]'),
 StaffName VARCHAR(25),
 StaffGender VARCHAR(8) CHECK (StaffGender LIKE 'Male' OR StaffGender LIKE 'Female'),
 StaffPhone VARCHAR(13) CHECK (LEN(StaffPhone)=13),
 StaffDOB DATE CHECK (DATEDIFF(YEAR, StaffDOB, CONVERT(DATE, GETDATE())) > 17), 
 StaffEmail VARCHAR(25),
 StaffAddress VARCHAR(25) CHECK (StaffAddress LIKE '[0-9][0-9][0-9] %')
)


--Software Type
CREATE TABLE SoftwareType(
 SoftwareTypeId CHAR(5) PRIMARY KEY CHECK(SoftwareTypeId LIKE 'TP[0-9][0-9][0-9]'),
 SoftwareTypeName VARCHAR (40) CHECK
 (SoftwareTypeName LIKE 'Multimedia Design' OR SoftwareTypeName LIKE 'Mobile Application' OR SoftwareTypeName LIKE 'Database Management'
  OR SoftwareTypeName LIKE 'Game Development' OR SoftwareTypeName LIKE 'Browser' OR SoftwareTypeName LIKE 'Text Editor' OR SoftwareTypeName LIKE 'Web Development'
  OR SoftwareTypeName LIKE 'Business Analytics' OR SoftwareTypeName LIKE 'Integrated Development Environment' OR SoftwareTypeName LIKE 'Others')
)


--Software
CREATE TABLE Software(
 SoftwareId CHAR(5) PRIMARY KEY CHECK(SoftwareId LIKE 'SW[0-9][0-9][0-9]'),
 SoftwareName VARCHAR(15),
 SoftwareVersion VARCHAR(5) CHECK(SoftwareVersion LIKE '[0-9].[0-9]'),
 SoftwareReleaseDate DATE,
 SoftwarePrice INT CHECK(SoftwarePrice BETWEEN 20000 AND 3000000),
 SoftwareStock INT 
)


--Customer 
CREATE TABLE Customer(
 CustomerID CHAR(5) PRIMARY KEY CHECK(CustomerID LIKE 'CS[0-9][0-9][0-9]'),
 CustomerName VARCHAR(25) CHECK (LEN(CustomerName) > 5),
 CustomerGender VARCHAR(8),
 CustomerAddress VARCHAR(25),
 CustomerPhone VARCHAR(15),
)


--Distributor
CREATE TABLE Distributor(
 DistributorID CHAR(5) PRIMARY KEY CHECK(DistributorID LIKE 'DT[0-9][0-9][0-9]'),
 DistributorName VARCHAR(25) CHECK (DistributorName LIKE '% %'),
 DistributorCompany VARCHAR(25)
)


--SalesHeaderTransaction
CREATE TABLE SalesHeaderTransaction(
 SalesID CHAR(5) PRIMARY KEY CHECK(SalesID LIKE 'SL[0-9][0-9][0-9]'),
 CustomerID CHAR(5) REFERENCES Customer(CustomerID),
 StaffID CHAR(5) REFERENCES Staff(StaffID),
 SalesDate DATE
)


--SalesDetailTransaction
CREATE TABLE SalesDetailTransaction(
 SalesID CHAR(5) REFERENCES SalesHeaderTransaction(SalesID),
 SoftwareId CHAR(5) REFERENCES Software(SoftwareID),
 SoftwareTypeId CHAR(5) REFERENCES SoftwareType(SoftwareTypeId),
 Quantity INT,
 PRIMARY KEY (SalesId, SoftwareId)
)


--PurchaseHeaderTransaction
CREATE TABLE PurchaseHeaderTransaction (
 PurchaseID CHAR(5) PRIMARY KEY CHECK (PurchaseID LIKE 'PR[0-9][0-9][0-9]'),
 DistributorID CHAR(5) REFERENCES Distributor(DistributorID),
 StaffID CHAR(5) REFERENCES Staff(StaffID), 
 PurchaseDate DATE 
)


--PurchaseDetailTransaction
CREATE TABLE PurchaseDetailTransaction(
 PurchaseID CHAR(5) REFERENCES PurchaseHeaderTransaction(PurchaseID),
 SoftwareID CHAR(5) REFERENCES Software(SoftwareID),
 Quantity INT, 
 PRIMARY KEY(PurchaseID, SoftwareID)
)



