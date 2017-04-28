DECLARE @ActivityMonitorStartMonth INT
DECLARE @ActivityMonitorStartDate NVARCHAR(MAX)
DECLARE @ActivityMonitorBeginDate DATETIME

--SET @ActivityMonitorStartDate = '03/28/2015 23:12:23:323' --CAN SET A VALUE --FORMAT 'MM/DD/YYYY HH:MM:SS:mmm' EG:'03/28/1988 23:12:23:323'

SET @ActivityMonitorStartMonth = 5 --CONSIDER LAST FIVE MONTH ACTIVITIES

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
	CreatedDate DATETIME,
	CustomerId VARCHAR(MAX)
)

INSERT INTO #Record
SELECT ord.Id, ord.DateCreated, Acc.DomainId
FROM [ICN].DBO.[Accounts] AS Acc
CROSS APPLY
(
	SELECT TOP 1 DateCreated, Id 
	FROM [ICN.Ordering].dbo.[Order]
	WHERE CustomerId = acc.DomainId		
	ORDER BY DateCreated DESC
) AS Ord
WHERE Ord.DateCreated < @ActivityMonitorBeginDate

SELECT * FROM #Record