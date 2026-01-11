
-- CREAZIONE TABELLE PIU' ASSOCIZIONE CHIAVI PRIMARIE E SECONDARE

CREATE TABLE Category (
CategoryID INT PRIMARY KEY
,CategoryName VARCHAR(25)
);

CREATE TABLE Product (
ProductID INT PRIMARY KEY
,ProductName VARCHAR(25)
,CategoryID INT
,Prezzo DECIMAL(10,2)
,FOREIGN KEY (CategoryID) REFERENCES Category(CategoryID)
);

CREATE TABLE Region (
IDregion INT PRIMARY KEY
,NameRegion VARCHAR(25)
);

CREATE TABLE State (
StateID INT PRIMARY KEY
,StateName VARCHAR(25)
,IDsalesRegion INT
,FOREIGN KEY (IDsalesRegion) REFERENCES Region(IDregion)
);

CREATE TABLE Sales (
SalesID INT PRIMARY KEY
,Quantity INT
,Giorno DATE
,ProductID INT
,StateID INT
,FOREIGN KEY (ProductID) REFERENCES Product(ProductID),
,FOREIGN KEY (StateID) REFERENCES State(StateID)
);


-- popolamento campi

INSERT INTO Category VALUES
(1, 'Beverage')
,(2, 'Snacks')
,(3, 'Electronics')
,(4, 'Books');

INSERT INTO Product VALUES
(1, 'Coca Cola', 1, 1.50)
,(2, 'Patatine', 2, 2.00)
,(3, 'Smartphone', 3, 399.99)
,(4, 'Romanzo', 4, 12.90);

INSERT INTO Region VALUES
(1, 'Francia')
,(2, 'Italia')
,(3, 'Spagna')
,(4, 'Germania');

INSERT INTO State VALUES
(1, 'WestEuropa', 1)
,(2, 'WestEuropa', 2)
,(3, 'SouthEuropa', 3)
,(4, 'CentralEuropa', 4);

INSERT INTO Sales VALUES
(1, 6, '2024-01-10', 1, 1)
,(2, 10, '2024-01-11', 2, 2)
,(3, 5, '2024-01-12', 3, 3)
,(4, 8, '2024-01-13', 4, 4);

-- CONTROLLO CHIAVE PRIMARIA UNIVOCA

SELECT StateID, COUNT(*)
FROM State
GROUP BY StateID
HAVING COUNT(*) > 1;

SELECT ProductID, COUNT(*) 
FROM Product
GROUP BY ProductID
HAVING COUNT(*) > 1;

SELECT IDregion, COUNT(*) 
FROM Region
GROUP BY IDregion
HAVING COUNT(*) > 1;

SELECT StateID, COUNT(*)
FROM State
GROUP BY StateID
HAVING COUNT(*) > 1;

SELECT SalesID, COUNT(*) AS Cnt
FROM Sales
GROUP BY SalesID
HAVING COUNT(*) > 1;

/* 3)	Esporre l’elenco dei prodotti che hanno venduto, in totale, una quantità maggiore della media delle vendite realizzate nell’ultimo anno censito.
 (ogni valore della condizione deve risultare da una query e non deve essere inserito a mano). 
Nel result set devono comparire solo il codice prodotto e il totale venduto. */

SELECT 
s.ProductID
,SUM(s.Quantity) AS TotaleVenduto
FROM Sales s
WHERE YEAR(s.Giorno) = (
SELECT MAX(YEAR(Giorno))
FROM Sales
)
GROUP BY s.ProductID
HAVING SUM(s.Quantity) > (
SELECT AVG(Quantity)
FROM Sales
WHERE YEAR(Giorno) = (
SELECT MAX(YEAR(Giorno))
FROM Sales
)
);


-- 4)	Esporre l’elenco dei soli prodotti venduti e per ognuno di questi il fatturato totale per anno. 

SELECT 
p.ProductID,
YEAR(s.Giorno) AS Anno
,SUM(s.Quantity * p.Prezzo) AS FatturatoTotale
FROM Sales s
JOIN Product p ON s.ProductID = p.ProductID
GROUP BY p.ProductID
ORDER BY p.ProductID, Anno;
    
    
    -- 5)	Esporre il fatturato totale per stato per anno. Ordina il risultato per data e per fatturato decrescente.
    
SELECT 
State.StateName
,YEAR(Sales.Giorno) AS Anno
,SUM(Sales.Quantity * Product.Prezzo) AS FatturatoTotale
FROM Sales
JOIN Product ON Sales.ProductID = Product.ProductID
JOIN State ON Sales.StateID = State.StateID
GROUP BY State.StateName
,YEAR(Sales.Giorno)
ORDER BY Anno ASC
,FatturatoTotale DESC;


-- 6)	Rispondere alla seguente domanda: qual è la categoria di articoli maggiormente richiesta dal mercato?

SELECT 
Category.CategoryName
,SUM(Sales.Quantity) AS TotaleRichiesto
FROM Sales
JOIN Product 
ON Sales.ProductID = Product.ProductID
JOIN Category 
ON Product.CategoryID = Category.CategoryID
GROUP BY Category.CategoryName
ORDER BY TotaleRichiesto DESC;

-- 7)	Rispondere alla seguente domanda: quali sono i prodotti invenduti? Proponi due approcci risolutivi differenti.

SELECT 
Product.ProductID
,Product.ProductName
FROM Product
WHERE Product.ProductID NOT IN (
SELECT Sales.ProductID
FROM Sales
);

SELECT 
Product.ProductID
,Product.ProductName
FROM Product
LEFT JOIN Sales 
ON Product.ProductID = Sales.ProductID
WHERE Sales.ProductID IS NULL;



/* 8)	Creare una vista sui prodotti in modo tale da esporre una “versione denormalizzata” 
delle informazioni utili (codice prodotto, nome prodotto, nome categoria) */

CREATE VIEW VistaProdottiDenormalizzati AS
SELECT 
Product.ProductID
,Product.ProductName
,Category.CategoryName
FROM Product
JOIN Category 
ON Product.CategoryID = Category.CategoryID;

-- 9)	Creare una vista per le informazioni geografiche

CREATE VIEW VistaInformazioniGeografiche AS
SELECT 
State.StateID
,State.StateName
,Region.IDregion
,Region.NameRegion
FROM State
JOIN Region
ON State.IDsalesRegion = Region.IDregion;