DROP TABLE IF EXISTS #Sales

SELECT f.*
		, ROW_NUMBER () OVER (PARTITION BY Year, Quarter ORDER BY SalesRevenue desc) as rn
INTO #Sales
FROM (
SELECT [Stock Item Key]
		,DATEPART(q,[Invoice Date Key]) as Quarter
		,DATEPART(yy,[Invoice Date Key]) as Year
		,SUM(Quantity*[Unit Price]) as SalesRevenue 
		,SUM(Quantity) as SalesQuantity
FROM [Fact].[Sale]
GROUP BY [Stock Item Key]
		,DATEPART(q,[Invoice Date Key])
		,DATEPART(yy,[Invoice Date Key])
) f

SELECT si.[Stock Item] as ProductName
		,SalesQuantity
		,SalesRevenue
		,Quarter
		,Year
FROM #sales s
JOIN Dimension.[Stock Item] si ON s.[Stock Item Key] = si.[Stock Item Key]
WHERE rn <= 10
ORDER BY Quarter, Year
