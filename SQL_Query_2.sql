DROP TABLE IF EXISTS #Sales

SELECT [Stock Item Key]
		, lag(SalesQuantity) OVER (PARTITION BY [Stock Item Key],Quarter ORDER BY Quarter, Year) as PreviousSalesQuantity
		, lag(SalesRevenue) OVER (PARTITION BY [Stock Item Key],Quarter ORDER BY Quarter, Year) as PreviousSalesRevenue
		, lag(year) OVER (PARTITION BY [Stock Item Key],Quarter ORDER BY Quarter, Year) as PreviousYear
		, lag(Quarter) OVER (PARTITION BY [Stock Item Key],Quarter ORDER BY Quarter, Year) as PreviousQuarter
		, SalesRevenue
		, SalesQuantity
		, Quarter as CurrentQuarter
		, Year as CurrentYear
INTO #Sales
FROM (
SELECT [Stock Item Key]
		,DATEPART(q,[Invoice Date Key]) as Quarter
		,DATEPART(yy,[Invoice Date Key]) as Year
		,SUM(Quantity*[Unit Price]) as SalesRevenue 
		,1.00*SUM(Quantity) as SalesQuantity
FROM [Fact].[Sale]
GROUP BY [Stock Item Key]
		,DATEPART(q,[Invoice Date Key])
		,DATEPART(yy,[Invoice Date Key])
) f

SELECT [Stock Item] as ProductName
		, (PreviousSalesRevenue / SalesRevenue) * 100 as GrowthRevenueRate
		, (PreviousSalesQuantity/ SalesQuantity) * 100 as GrowthQuantityRate
		, CurrentQuarter
		, CurrentYear
		, PreviousQuarter
		, PreviousYear
FROM #Sales s
JOIN Dimension.[Stock Item] si ON s.[Stock Item Key] = si.[Stock Item Key]
WHERE PreviousQuarter IS NOT NULL

