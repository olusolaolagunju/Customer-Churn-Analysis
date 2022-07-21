SELECT *
FROM CustomerChurn..Churn$
--------what is the total number of customers had in the year of review
SELECT COUNT(CustomerID)
FROM CustomerChurn..Churn$

-----what is the number of churned customer
SELECT COUNT(CustomerID)
FROM CustomerChurn..Churn$
WHERE CustomerStatus ='Churned'

----what is the churn rate 
WITH CTE_ChurnRate as (
	SELECT COUNT(CustomerStatus) as TotalCustomer,
	(SELECT COUNT(CustomerStatus)  FROM CustomerChurn..Churn$ WHERE CustomerStatus = 'Churned') as TotalChurnedCustomer
FROM CustomerChurn..Churn$)
SELECT   CONVERT(Decimal(5,0),(TotalChurnedCustomer *1.00/ TotalCustomer) * 100) as CustomerchurnRate
FROM CTE_ChurnRate


--what is the total revenue for the year in review
SELECT ROUND(SUM(TotalRevenue),0) as TotalCustRevenue
FROM CustomerChurn..Churn$


---amount of revenue churned
SELECT ROUND(SUM(TotalRevenue),0) as TotalCustRevenue
FROM CustomerChurn..Churn$
WHERE CustomerStatus ='Churned'

-----what is the revenue churn rate 
WITH CTE_ChurnRevenue as (
	SELECT SUM(TotalRevenue) as TotalCustRevenue,(
	SELECT SUM(TotalRevenue) FROM CustomerChurn..Churn$ WHERE CustomerStatus ='Churned') as Revenuechurned
FROM CustomerChurn..Churn$)
SELECT CONVERT(Decimal(10,0),(Revenuechurned/TotalCustRevenue) *100) as RevenueChurnRate
FROM CTE_ChurnRevenue 

----what is the average lifetime of a customer based on the tenure month
SELECT  avg(TotalLongDistanceCharges)
FROM CustomerChurn..Churn$ 
WHERE CustomerStatus ='Churned'

--Calculate the customer churn rate per the average tenure month 
---cohort analysis for Tenure month

ALTER TABLE Churn$
Add TenureCohort varchar(100)

SELECT MAX(TenureMonths)
FROM Churn$

SELECT
CASE
WHEN TenureMonths < 7 THEN 'CR1'
WHEN TenureMonths < 14 THEN 'CR2'
WHEN TenureMonths < 21 THEN 'CR3'
WHEN TenureMonths < 28 THEN 'CR4'
WHEN TenureMonths < 35 THEN 'CR5'
WHEN TenureMonths < 42 THEN 'CR6'
WHEN TenureMonths < 49 THEN 'CR7'
WHEN TenureMonths < 56 THEN 'CR8'
WHEN TenureMonths < 63 THEN 'CR9'
ELSE 'CR10'
END TenureCohortS
FROM Churn$

UPDATE Churn$
SET TenureCohort = CASE
WHEN TenureMonths < 7 THEN 'CR1'
WHEN TenureMonths < 14 THEN 'CR2'
WHEN TenureMonths < 21 THEN 'CR3'
WHEN TenureMonths < 28 THEN 'CR4'
WHEN TenureMonths < 35 THEN 'CR5'
WHEN TenureMonths < 42 THEN 'CR6'
WHEN TenureMonths < 49 THEN 'CR7'
WHEN TenureMonths < 56 THEN 'CR8'
WHEN TenureMonths < 63 THEN 'CR9'
ELSE 'CR10'
END							

SELECT *
FROM CustomerChurn..Churn$


--Calculate the customer and revenue churn rate per the average tenure month 
-----customer churn rate per tenure month cohort
WITH CTE_TenurePerMonth as (
SELECT TenureCohort, ROUND(AVG(TenureMonths),0) as AverageMonthsPerCohort, COUNT(TenureMonths)as TotalChurnedCustomersPerCohort,
(SELECT COUNT(TenureMonths) FROM CustomerChurn..Churn$ WHERE CustomerStatus ='Churned')as TotalChurnedCustomer
FROM CustomerChurn..Churn$ 
WHERE CustomerStatus ='Churned'
GROUP BY TenureCohort)
SELECT *,ROUND( (TotalChurnedCustomersPerCohort*1.0 /TotalChurnedCustomer * 100),0) as ChurnRatePerCohortPerTenure
FROM CTE_TenurePerMonth
ORDER BY ChurnRatePerCohortPerTenure desc

 --revenue churn rate  per average tenure month cohort
WITH CTE_RevenueChurnRatePerCohort as (
SELECT TenureCohort,  ROUND(AVG(TenureMonths),0) as AverageMonthsPerCohort, SUM(Totalrevenue) as TotalRevenueChurnedPerCohort,
(SELECT SUM(TotalRevenue) FROM CustomerChurn..Churn$ WHERE CustomerStatus ='Churned') as TotalChurnedRevenue
FROM CustomerChurn..Churn$
WHERE CustomerStatus ='Churned'
GROUP BY TenureCohort)
SELECT *, ROUND( (TotalRevenueChurnedPerCohort/TotalChurnedRevenue * 100),0) as RevenueChurnRatePerCohorrt
FROM CTE_RevenueChurnRatePerCohort
ORDER BY TotalRevenueChurnedPerCohort DESC




----what is the Customer and revenue churn rate for the customers in the contract cohorts


----CustomerChurn rate for contract

WITH CTE_ChurnedContract as (
SELECT Contract,  COUNT(Contract)as TotalChurnedCustomersPerContract, 
(SELECT COUNT(Contract) FROM CustomerChurn..Churn$ WHERE CustomerStatus ='Churned')as TotalChurnedCustomer
FROM CustomerChurn..Churn$
WHERE CustomerStatus ='Churned'
GROUP BY Contract)
SELECT *, ROUND( (TotalChurnedCustomersPerContract*1.0 /TotalChurnedCustomer * 100),0) as ChurnRatePerContract
FROM CTE_ChurnedContract
ORDER BY ChurnRatePerContract desc

--RevenueChurn for contract

WITH CTE_RevenueChurnRatePerContract as (
SELECT Contract, SUM(TotalRevenue) as TotalChurnedRevenuePerContract, 
(SELECT SUM(TotalRevenue) FROM CustomerChurn..Churn$ WHERE CustomerStatus ='Churned') as TotalChurnedRevenue
FROM CustomerChurn..Churn$
WHERE CustomerStatus ='Churned'
GROUP BY Contract)
SELECT *,  ROUND( (TotalChurnedRevenuePerContract/TotalChurnedRevenue * 100),0) RevenueChurendRatePerContract
FROM CTE_RevenueChurnRatePerContract
ORDER BY RevenueChurendRatePerContract DESC

----How does the extra charges and long distance charges incurred by customer affect the churn rate

---Total charges 
---Gouping the total charges into ten customer cohort

SELECT MAX(TotalCharges)
FROM CustomerChurn..Churn$

SELECT
CASE
WHEN TotalCharges < 868 THEN 'TC1'
WHEN TotalCharges < 1736 THEN 'TC2'
WHEN TotalCharges < 2604 THEN 'TC3'
WHEN TotalCharges < 3472 THEN 'TC4'
WHEN TotalCharges < 4340 THEN 'TC5'
WHEN TotalCharges < 5208 THEN 'TC6'
WHEN TotalCharges < 6076 THEN 'TC7'
WHEN TotalCharges < 6944 THEN 'TC8'
WHEN TotalCharges < 7812 THEN 'TC9'
ELSE 'TC10'
END TenureCohortS
FROM CustomerChurn..Churn$

ALTER TABLE  CustomerChurn..Churn$
ADD TotalChargesCohort varchar(100)

UPDATE CustomerChurn..Churn$
SET TotalChargesCohort = CASE
WHEN TotalCharges < 868 THEN 'TC1'
WHEN TotalCharges < 1736 THEN 'TC2'
WHEN TotalCharges < 2604 THEN 'TC3'
WHEN TotalCharges < 3472 THEN 'TC4'
WHEN TotalCharges < 4340 THEN 'TC5'
WHEN TotalCharges < 5208 THEN 'TC6'
WHEN TotalCharges < 6076 THEN 'TC7'
WHEN TotalCharges < 6944 THEN 'TC8'
WHEN TotalCharges < 7812 THEN 'TC9'
ELSE 'TC10'
END

------Effect of total charges on churnrate
WITH CTE_TotalChargesChurnRate as (
SELECT TotalChargesCohort, ROUND(AVG(TotalCharges),0) as AverageTotalChargesPerCohort, COUNT(TotalCharges) as ChurnedCustomersPerCohort,
(SELECT COUNT(TotalChargesCohort) FROM CustomerChurn..Churn$ WHERE CustomerStatus ='Churned')as TotalChurnedCustomer
FROM CustomerChurn..Churn$
WHERE CustomerStatus ='Churned'
GROUP BY TotalChargesCohort) 
SELECT *,  ROUND( (ChurnedCustomersPerCohort*1.0 /TotalChurnedCustomer * 100),0) as ChurnRatePerTotalCharges
FROM CTE_TotalChargesChurnRate
ORDER BY ChurnRatePerTotalCharges DESC

-----Effect of Total Long distance call on churn rate
--Craete Long distance call cohort 

SELECT MAX(TotalLongDistanceCharges)
FROM CustomerChurn..Churn$

SELECT
CASE
WHEN TotalLongDistanceCharges < 356 THEN 'DC1'
WHEN TotalLongDistanceCharges < 712 THEN 'DC2'
WHEN TotalLongDistanceCharges < 1068 THEN 'DC3'
WHEN TotalLongDistanceCharges < 1424 THEN 'DC4'
WHEN TotalLongDistanceCharges < 1780 THEN 'DC5'
WHEN TotalLongDistanceCharges < 2136 THEN 'DC6'
WHEN TotalLongDistanceCharges < 2492 THEN 'DC7'
WHEN TotalLongDistanceCharges < 2848 THEN 'DC8'
WHEN TotalLongDistanceCharges< 3204 THEN 'DC9'
ELSE 'DC10'
END TotalLongDistanceChargesCohorts
FROM CustomerChurn..Churn$

ALTER TABLE  CustomerChurn..Churn$
ADD TotalLongDistanceChargesCohorts varchar(100)

UPDATE CustomerChurn..Churn$
set TotalLongDistanceChargesCohorts = CASE
WHEN TotalLongDistanceCharges < 356 THEN 'DC1'
WHEN TotalLongDistanceCharges < 712 THEN 'DC2'
WHEN TotalLongDistanceCharges < 1068 THEN 'DC3'
WHEN TotalLongDistanceCharges < 1424 THEN 'DC4'
WHEN TotalLongDistanceCharges < 1780 THEN 'DC5'
WHEN TotalLongDistanceCharges < 2136 THEN 'DC6'
WHEN TotalLongDistanceCharges < 2492 THEN 'DC7'
WHEN TotalLongDistanceCharges < 2848 THEN 'DC8'
WHEN TotalLongDistanceCharges< 3204 THEN 'DC9'
ELSE 'DC10'
END

---Effect of Total Long distance call on churn rate
SELECT *
FROM CustomerChurn..Churn$

WITH CTE_TotalLongDistanceChurnRate as (
SELECT TotalLongDistanceChargesCohorts, ROUND(AVG(TotalLongDistanceCharges),0) as AverageTotalDistanceChargesPerCohort,
		COUNT(TotalLongDistanceCharges) as ChurnedCustomersPerCohort,
(SELECT COUNT(TotalLongDistanceCharges) FROM CustomerChurn..Churn$ WHERE CustomerStatus ='Churned')as TotalChurnedCustomer
FROM CustomerChurn..Churn$
WHERE CustomerStatus ='Churned'
GROUP BY TotalLongDistanceChargesCohorts)
SELECT *, ROUND( (ChurnedCustomersPerCohort*1.0 /TotalChurnedCustomer * 100),0) as ChurnRatePerTotalDistanceCharges
FROM CTE_TotalLongDistanceChurnRate
ORDER BY ChurnRatePerTotalDistanceCharges DESC



SELECT*
FROM CustomerChurn..Churn$

-----what is the count of chunring reasons on the contract basis

SELECT Contract, COUNT(ChurnCategory)
FROM CustomerChurn..Churn$ WHERE ChurnCategory ='Competitor'
GROUP BY Contract

SELECT Contract, COUNT(ChurnCategory)  
FROM CustomerChurn..Churn$ WHERE ChurnCategory ='Dissatisfaction'
GROUP BY Contract

SELECT Contract, COUNT(ChurnCategory)  
FROM CustomerChurn..Churn$ WHERE ChurnCategory ='Attitude'
GROUP BY Contract

SELECT Contract, COUNT(ChurnCategory)  
FROM CustomerChurn..Churn$ WHERE ChurnCategory ='Price'
GROUP BY Contract

SELECT Contract, COUNT(ChurnCategory)  
FROM CustomerChurn..Churn$ WHERE ChurnCategory ='other'
GROUP BY Contract