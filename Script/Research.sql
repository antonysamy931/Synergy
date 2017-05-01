DECLARE @ActivityMonitorStartMonth INT
DECLARE @ActivityMonitorStartDate NVARCHAR(MAX)
DECLARE @ActivityMonitorBeginDate DATETIME

--SET @ActivityMonitorStartDate = '03/28/2015 23:12:23:323' --CAN SET A VALUE --FORMAT 'MM/DD/YYYY HH:MM:SS:mmm' EG:'03/28/1988 23:12:23:323'

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

SELECT * FROM #Record