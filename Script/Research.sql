DECLARE @ActivityMonitorStartMonth INT
DECLARE @ActivityMonitorStartDate NVARCHAR(MAX)
DECLARE @ActivityMonitorBeginDate DATETIME

SET @ActivityMonitorStartDate = '2013-01-30 19:50:26.037' --CAN SET A VALUE --FORMAT 'MM/DD/YYYY HH:MM:SS:mmm' EG:'03/28/1988 23:12:23:323'

SET @ActivityMonitorStartMonth = 45 --CONSIDER LAST FIVE MONTH ACTIVITIES

IF @ActivityMonitorStartDate <> ''
BEGIN	
	SET @ActivityMonitorBeginDate = CAST(@ActivityMonitorStartDate AS DATETIME)
END
ELSE
BEGIN
	SET @ActivityMonitorBeginDate = DATEADD(MONTH, -@ActivityMonitorStartMonth, GETDATE())
END

IF OBJECT_ID('tempdb..#Record') IS NOT NULL
BEGIN
	DROP TABLE #Record	
END

CREATE TABLE #Record
(
	OrderId INT,
	BuildDate DATETIME,
	CustomerId INT
)

INSERT INTO #Record
SELECT Ord.OrderID, Ord.BuildDate, Cus.CustomerID
FROM [Customer] AS Cus
CROSS APPLY
(
	SELECT TOP 1 BuildDate, OrderID 
	FROM [Order]
	WHERE CustomerId = Cus.CustomerID		
	ORDER BY BuildDate DESC
) AS Ord
WHERE Ord.BuildDate < @ActivityMonitorBeginDate

-- TRANSACTION BEGIN
BEGIN TRAN [CLEAN]

-- BEGIN TRY
BEGIN TRY
	
----------------------------------------------------------------------
-- DELETE ORDER RELATED TABLE
----------------------------------------------------------------------
	-- DELETE ORDER PRINT RECORDS
	DELETE FROM [OrderPrint] WHERE OrderPrintID IN 
	(SELECT O.PickListOrderPrintID FROM [Order] AS O
	JOIN #Record AS R ON O.OrderID = R.OrderID)

	DELETE FROM [OrderPrint] WHERE OrderPrintID IN 
	(SELECT O.MenuOrderPrintID FROM [Order] AS O
	JOIN #Record AS R ON O.OrderID = R.OrderID)

	-- DELETE ORDER DAY MEAL RECORDS
	DELETE FROM [OrderDayMeal] WHERE OrderDayID IN
	(SELECT OD.OrderDayID FROM [OrderDay] AS OD
	JOIN #Record AS R ON OD.OrderID = R.OrderID)

	-- DELETE ORDER DAY RECORDS
	DELETE FROM [OrderDay] WHERE OrderID IN
	(SELECT OrderID FROM #Record)
	
	-- DELETE AGENT NOTE BY ORDER	
	DELETE FROM [AgentNote] WHERE OrderID IN
	(SELECT OrderID FROM #Record)
	
	-- DELETE ORDER 
	DELETE FROM [Order] WHERE OrderID IN
	(SELECT OrderID FROM #Record)
	
------------------------------------------------------------------------
-- DELETE CUSTOMER RELATED TABLES
------------------------------------------------------------------------	
	-- DELETE CUSTOMER PAYMENT BY CUSTOMERID	
	DELETE FROM [CustomerPayment] WHERE CustomerID IN
	(SELECT DISTINCT CustomerId FROM #Record)	

	--DELETE ORDER BY CUSTOMER	
	DELETE FROM [Order] WHERE CustomerID IN
	(SELECT DISTINCT CustomerId FROM #Record)
	
	-- DELETE CUSTOEMR ADDRESS
	DELETE FROM [CustomerAddress] WHERE CustomerID IN
	(SELECT DISTINCT CustomerId FROM #Record)

	-- DELETE AGENT NOTE FOR CUSTOMERID
	DELETE FROM [AgentNote] WHERE CustomerID IN
	(SELECT DISTINCT CustomerId FROM #Record)
	
	--DELETE USERROLES 
	DELETE FROM [UsersInRoles] WHERE UserID IN
	(SELECT U.UserID FROM [User] AS U
	JOIN #Record AS R ON U.CustomerID = R.CustomerId)
	
	-- DELETE BUILD
	DELETE FROM [Build] WHERE UserID IN
	(SELECT U.UserID FROM [User] AS U
	JOIN #Record AS R ON U.CustomerID = R.CustomerId)

	-- DELETE AGENT NOTE FOR USER
	DELETE FROM [AgentNote] WHERE AgentID IN
	(SELECT U.UserID FROM [User] AS U
	JOIN #Record AS R ON U.CustomerID = R.CustomerId)	
	
	-- DELETE USER
	DELETE FROM [User] WHERE CustomerID IN
	(SELECT DISTINCT CustomerId FROM #Record)
	
	-- DELETE VACATION HOLD HISTORY 
	DELETE FROM [VacationHoldHistory] WHERE CustomerID IN
	(SELECT DISTINCT CustomerId FROM #Record)
	
	-- DELETE CUSTOMER MEAL
	DELETE FROM [CustomerMeal] WHERE CustomerID IN
	(SELECT DISTINCT CustomerId FROM #Record)
	
	-- DELETE CUSTOMER INGREDIENT EXCLUSION
	DELETE FROM [CustomerIngredientExclusion] WHERE CustomerID IN
	(SELECT DISTINCT CustomerId FROM #Record)
	
	-- COMMIT THE CHANGES IF NO ERROW HAPPENDS
	COMMIT TRAN [CLEAN]
END TRY
-- CATCH THE ERROR AND ROLLBACK ALL CHANGES
BEGIN CATCH 
	ROLLBACK TRAN [CLEAN]
END CATCH

--SELECT * FROM #Record