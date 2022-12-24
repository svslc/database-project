--1. Display SoftwareName and Income (obtained by adding ‘Rp. ’ in front of the sum of software price multiplied by quantity) for every sales transaction which the software type is either ‘Web Development’ or ‘Browser’ and the software stock is more than 10.

SELECT SoftwareName, [Income] = 'Rp.' + CAST((SoftwarePrice*Quantity) AS VARCHAR)
FROM Software s
JOIN SalesDetailTransaction sdt
ON s.SoftwareId = sdt.SoftwareId
JOIN SoftwareType st
ON st.SoftwareTypeId = sdt.SoftwareTypeId
WHERE SoftwareTypeName IN ('Web Development', 'Browser')
AND SoftwareStock > 10


--2. Display distributor company and Total Software Bought (obtained from the sum of quantity bought) for every purchase transaction which handled by a distributor whose name starts with ‘A’ and occurred after the 10th date of every month.

SELECT DistributorCompany, [Total Software Bought] = SUM(Quantity)
FROM Distributor d
JOIN PurchaseHeaderTransaction pht
ON d.DistributorID = pht.DistributorID
JOIN PurchaseDetailTransaction pdt
ON pht.PurchaseID = pdt.PurchaseID
WHERE DistributorName LIKE 'A%'
AND DATEPART(DAY, PurchaseDate) > 10
GROUP BY DistributorCompany

-- 3. Display Average Revenue per Day (obtained by adding ‘Rp. ’in front of the average of software price multiplied by quantity), TransactionDate, 
-- and Male Staff Count (obtained from distinct count of staff and ended with ‘ person’) for every sales transaction which is handled by male staff and occurred in 2018.

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


-- 4. Display Gender (obtained from the first letter of Gender), Total Transactions (obtained from number of sales transaction ended with ‘ transaction(s)’) and Total Sold (obtained from sum of quantity ended with ‘ item(s)’) for every sales transactions that is handled by a male staff and the price multiplied with quantity is higher than 100000. 
-- And then combine it with Gender (obtained from the first letter of Gender), Total Transactions (total sales transaction ended with ‘ transaction(s)’) and Total Sold (obtained from sum of quantity ended with ‘ item(s)’) for every sales transactions that is handled by a female staff and the price multiplied with quantity is higher than 200000.

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


-- 5. Display SoftwareId, SoftwareName, SoftwarePrice (obtained by adding ‘Rp. ’in front of SoftwarePrice) for every purchase transaction which SoftwarePrice is higher than the average of SoftwarePrice 
-- from every purchase transaction and for every purchase transaction handled by a staff whose StaffId is either ‘SF003’, ‘SF004’, ‘SF009’. Show the data based on SoftwarePrice in descending order.

SELECT pdt.SoftwareID, SoftwareName, SoftwarePrice =  'Rp. ' + CAST(SoftwarePrice AS VARCHAR)
FROM Software s JOIN PurchaseDetailTransaction pdt
ON s.SoftwareId = pdt.SoftwareID
JOIN PurchaseHeaderTransaction pht
ON pht.PurchaseID = pdt.PurchaseID
WHERE 
SoftwarePrice > (SELECT AVG(SoftwarePrice) AS [Avg]
				FROM Software s, PurchaseDetailTransaction pdt
				WHERE s.SoftwareId = pdt.SoftwareID)
AND StaffID IN ('SF003', 'SF004', 'SF009')
ORDER BY SoftwarePrice DESC


-- 6. Display Staff First Name (obtained from the staff’s first name), StaffPhone, Transaction Date (obtained from the transaction date in dd mon yyyy format) for every sales transaction 
-- which quantity is lower than the average of quantity from all sales transaction and occurred before ‘1 January 2019’.

SELECT [Staff First Name] = LEFT(StaffName, CHARINDEX(' ', StaffName + ' ')-1), StaffPhone, 
[Transaction Date] = CONVERT(VARCHAR, SalesDate, 106)
FROM Staff s 
JOIN SalesHeaderTransaction sht
ON s.StaffID = sht.StaffID
JOIN SalesDetailTransaction sdt
ON sht.SalesID = sdt.SalesID
WHERE sdt.Quantity < (SELECT AVG(Quantity) FROM SalesDetailTransaction)
AND SalesDate < '1 January 2019'


-- 7. Display PurchaseTransactionId, Distributor Last Name (obtained by adding ‘Mx. ’ in front of distributor’s last name), DistributorCompany, TransactionDate (obtained from the transaction date in Mon dd, yyyy format), 
-- for every purchase transaction which Software Price is higher than the average price of every software but lower than the maximum price of every software and occurred between the year 2017 and 2018. 

SELECT pht.PurchaseID AS PurchaseTransactionId, [Distributor Last Name] = 'Mx. ' + SUBSTRING(DistributorName, CHARINDEX(' ', DistributorName)+1, LEN(DistributorName)), 
DistributorCompany, [TransactionDate] = CONVERT(VARCHAR, PurchaseDate, 107)
FROM PurchaseHeaderTransaction pht, Distributor d,
(
	SELECT PurchaseID, SoftwarePrice
	FROM Software s, PurchaseDetailTransaction pdt
	WHERE s.SoftwareId = pdt.SoftwareID
) AS a,
(
	SELECT AVG(SoftwarePrice) AS [Avg Software Price], MAX(SoftwarePrice) AS [Max Software Price]
	FROM Software
) AS b
WHERE pht.DistributorID = d.DistributorID
AND pht.PurchaseID = a.PurchaseID
AND a.SoftwarePrice > [Avg Software Price] 
AND a.SoftwarePrice < [Max Software Price]
AND YEAR(PurchaseDate) BETWEEN '2017' AND '2018' 


-- 8. Display DistributorName, TransactionDate, Total Transactions (obtained from the number of Transactions and ended with ‘ transaction(s)’) for every purchase transaction 
-- where the software’s version bought is higher than the average software’s version available and the distributor id is either ‘DT001’, ‘DT005’, ‘DT006’.

WITH Total_Purchase_Transaction AS
	(
	SELECT PurchaseID, CAST(SoftwareVersion AS FLOAT) AS [Software Version], cast(Quantity AS VARCHAR) + ' transaction(s)' AS [Total Transactions]
	FROM PurchaseDetailTransaction pdt, Software s 
	WHERE pdt.SoftwareID = s.SoftwareId
	)

SELECT DistributorName, [Transaction Date] = PurchaseDate, [Total Transactions]
FROM PurchaseHeaderTransaction pht 
JOIN Distributor d
ON pht.DistributorID = d.DistributorID
JOIN Total_Purchase_Transaction tp
ON tp.PurchaseID = pht.PurchaseID
WHERE tp.[Software Version] > (SELECT AVG(CAST(SoftwareVersion AS FLOAT)) FROM Software)
AND pht.DistributorID IN ('DT001', 'DT005', 'DT006')


--9. Create a View named ‘StaffSalesReport’ to display StaffName, StaffGender, Transaction Count (obtained from the number of transactions), Total Sales Income (obtained by adding ‘Rp. ’ in front of the sum software price multiplied by quantity) for every sales transaction 
-- which the Total Sales Income is higher than 100000 and the staff name consists of at least 3 words.

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


-- 10. Create view named ‘Recurring Members’ to display CustomerName, Total Transactions (obtained from total number of transactions), Total Spent (obtained by adding ‘Rp. ’ in front of total sum of software price multiplied by quantity), 
-- for every customer who has done more than 2 transactions and SoftwarePrice is higher than 50000.

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
