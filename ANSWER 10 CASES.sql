--1

SELECT SoftwareName, [Income] = 'Rp.' + CAST((SoftwarePrice*Quantity) AS VARCHAR)
FROM Software s
JOIN SalesDetailTransaction sdt
ON s.SoftwareId = sdt.SoftwareId
JOIN SoftwareType st
ON st.SoftwareTypeId = sdt.SoftwareTypeId
WHERE SoftwareTypeName IN ('Web Development', 'Browser')
AND SoftwareStock > 10

--2

SELECT DistributorCompany, [Total Software Bought] = SUM(Quantity)
FROM Distributor d
JOIN PurchaseHeaderTransaction pht
ON d.DistributorID = pht.DistributorID
JOIN PurchaseDetailTransaction pdt
ON pht.PurchaseID = pdt.PurchaseID
WHERE DistributorName LIKE 'A%'
AND DATEPART(DAY, PurchaseDate) > 10
GROUP BY DistributorCompany

--3

SELECT [Average Revenue per Day] = 'Rp.' + CAST(AVG(SoftwarePrice*Quantity) AS VARCHAR),
[Transaction Date] = SalesDate, [Male Staff Count] = CAST(COUNT(DISTINCT sht.StaffID) AS VARCHAR) + ' person'
FROM Software s
JOIN SalesDetailTransaction sdt
ON s.SoftwareId = sdt.SoftwareId
JOIN SalesHeaderTransaction sht
on sht.SalesID = sdt.SalesID
JOIN Staff st
ON st.StaffID = sht.StaffID
WHERE StaffGender = 'Male'
AND YEAR(SalesDate) = 2018
GROUP BY SalesDate

--4

SELECT [Gender] = LEFT(StaffGender, 1), [Total Transactions] = CAST(COUNT(sht.SalesID) AS VARCHAR) + ' transaction(s)',
[Total Sold] = CAST(SUM(Quantity) AS VARCHAR) + ' item(s)'
FROM Staff st JOIN SalesHeaderTransaction sht
ON st.StaffID = sht.StaffID
JOIN SalesDetailTransaction sdt
ON sht.SalesID = sdt.SalesID
JOIN Software s
ON sdt.SoftwareId = s.SoftwareId
WHERE StaffGender = 'Male'
AND SoftwarePrice*Quantity > 100000
GROUP BY StaffGender
UNION 
SELECT [Gender] = LEFT(StaffGender, 1), [Total Transactions] = CAST(COUNT(sht.SalesID) AS VARCHAR) + ' transaction(s)',
[Total Sold] = CAST(SUM(Quantity) AS VARCHAR) + ' item(s)'
FROM Staff st JOIN SalesHeaderTransaction sht
ON st.StaffID = sht.StaffID
JOIN SalesDetailTransaction sdt
ON sht.SalesID = sdt.SalesID
JOIN Software s
ON sdt.SoftwareId = s.SoftwareId
WHERE StaffGender = 'Female'
AND SoftwarePrice*Quantity > 200000
GROUP BY StaffGender

--5

SELECT pdt.SoftwareID, SoftwareName, SoftwarePrice =  'Rp. ' + CAST(SoftwarePrice AS VARCHAR)
FROM Software s, PurchaseHeaderTransaction pht, PurchaseDetailTransaction pdt,
(
	SELECT AVG(SoftwarePrice) AS [Avg]
	FROM Software s, PurchaseDetailTransaction pdt
	WHERE s.SoftwareId = pdt.SoftwareID

) AS a
WHERE s.SoftwareId = pdt.SoftwareID
AND pht.PurchaseID = pdt.PurchaseID
AND StaffID IN ('SF003', 'SF004', 'SF009')
AND SoftwarePrice > [Avg]
ORDER BY SoftwarePrice DESC

--6

SELECT [Staff First Name] = LEFT(StaffName, CHARINDEX(' ', StaffName + ' ')-1), StaffPhone, 
[Transaction Date] = CONVERT(VARCHAR, SalesDate, 106)
FROM Staff s, SalesHeaderTransaction sht,
(
	SELECT SalesID, Quantity 
	FROM SalesDetailTransaction
) AS a, 
(
	SELECT AVG(Quantity) AS [Avg]
	FROM SalesDetailTransaction 
) AS b
WHERE s.StaffID = sht.StaffID
AND a.SalesID = sht.SalesID
AND a.Quantity < [Avg]
AND SalesDate < '1 January 2019'

--7

SELECT pht.PurchaseID AS PurchaseTransactionId, [Distributor Last Name] = 'Mx. ' + SUBSTRING(DistributorName, CHARINDEX(' ', DistributorName)+1, LEN(DistributorName)), 
DistributorCompany, [TransactionDate] = CONVERT(VARCHAR, PurchaseDate, 107)
FROM PurchaseHeaderTransaction pht, Distributor d,
(
	SELECT PurchaseID, SoftwarePrice
	FROM Software s, PurchaseDetailTransaction pdt
	WHERE s.SoftwareId = pdt.SoftwareID
) AS a,
(
	SELECT AVG(SoftwarePrice) AS [Avg], MAX(SoftwarePrice) AS [Max]
	FROM Software
) AS b
WHERE pht.DistributorID = d.DistributorID
AND pht.PurchaseID = a.PurchaseID
AND a.SoftwarePrice > [Avg] 
AND a.SoftwarePrice < [Max]
AND YEAR(PurchaseDate) IN ('2017', '2018')

--8

SELECT DistributorName, TransactionDate, [Total Transactions]
FROM 
(
	SELECT PurchaseID, DistributorName, PurchaseDate AS TransactionDate
	FROM PurchaseHeaderTransaction pht, Distributor d
	WHERE pht.DistributorID = d.DistributorID
	AND pht.DistributorID IN ('DT001', 'DT005', 'DT006')
) AS a, 
(
	SELECT PurchaseID, SoftwareVersion, cast(Quantity AS VARCHAR) + ' transaction(s)' AS [Total Transactions]
	FROM PurchaseDetailTransaction pdt, Software s 
	WHERE pdt.SoftwareID = s.SoftwareId
) AS b,
(
	SELECT AVG(CAST( SoftwareVersion AS FLOAT)) AS [Avg]
	FROM Software
) AS c
WHERE a.PurchaseID = b.PurchaseID
AND b.SoftwareVersion > [Avg]

--9

GO
CREATE VIEW StaffSalesReport AS
SELECT StaffName, StaffGender, [Transaction Count] = COUNT(sht.SalesID), 
[Total Sales Income] = 'Rp. ' +  CAST(SUM(SoftwarePrice*Quantity) AS VARCHAR)
FROM Staff st
JOIN SalesHeaderTransaction sht
ON st.StaffID = sht.StaffID
JOIN SalesDetailTransaction sdt
ON sht.SalesID = sdt.SalesID
JOIN Software s
ON s.SoftwareId = sdt.SoftwareId
WHERE StaffName LIKE '% % %'
GROUP BY StaffName, StaffGender
HAVING SUM(SoftwarePrice*Quantity) > 100000
GO

--10

GO
CREATE VIEW [Recurring Members] AS
SELECT CustomerName, [Total Transactions] = COUNT(sht.SalesID), [Total Spent] = 'Rp. ' +  CAST(SUM(SoftwarePrice*Quantity) AS VARCHAR)
FROM Customer c
JOIN SalesHeaderTransaction sht
ON c.CustomerID = sht.CustomerID
JOIN SalesDetailTransaction sdt
ON sht.SalesID = sdt.SalesID
JOIN Software s
ON s.SoftwareId = sdt.SoftwareId
WHERE SoftwarePrice > 50000
GROUP BY CustomerName
HAVING COUNT(sht.SalesID) > 2
GO
