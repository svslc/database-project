
--Purchase Simulation

INSERT INTO PurchaseHeaderTransaction VALUES ('PR021', 'DT004', 'SF002', '2019-03-20')
INSERT INTO PurchaseHeaderTransaction VALUES ('PR022', 'DT001', 'SF014', '2019-02-08')
INSERT INTO PurchaseHeaderTransaction VALUES ('PR023', 'DT002', 'SF003', '2019-6-10') 

INSERT INTO PurchaseDetailTransaction VALUES ('PR021', 'SW007', 10) 
INSERT INTO PurchaseDetailTransaction VALUES ('PR022', 'SW010', 8)
INSERT INTO PurchaseDetailTransaction VALUES ('PR022', 'SW016', 4)
INSERT INTO PurchaseDetailTransaction VALUES ('PR023', 'SW005', 3)
INSERT INTO PurchaseDetailTransaction VALUES ('PR023', 'SW003', 7)

--Sales Simulation

INSERT INTO SalesHeaderTransaction VALUES ('SL021', 'CS007', 'SF003', '2019-05-28')
INSERT INTO SalesHeaderTransaction VALUES ('SL022', 'CS001', 'SF005', '2019-01-12')
INSERT INTO SalesHeaderTransaction VALUES ('SL023', 'CS005', 'SF002', '2019-11-08') 

INSERT INTO SalesDetailTransaction VALUES ('SL021', 'SW008', 'TP009', 7)
INSERT INTO SalesDetailTransaction VALUES ('SL021', 'SW002', 'TP001', 2)
INSERT INTO SalesDetailTransaction VALUES ('SL022', 'SW005', 'TP002', 4)
INSERT INTO SalesDetailTransaction VALUES ('SL022', 'SW006', 'TP010', 5)
INSERT INTO SalesDetailTransaction VALUES ('SL023', 'SW011', 'TP004', 9) 


