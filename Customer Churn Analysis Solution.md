
# **Customer Churn Analysis and Cohort Segmentation**
**Introduction**

 Churn happens when a customer quits using a service or cancels their subscription and the rate is calculated as the percentage of customers that stopped using your company’s product or service during a certain period. It is an important metric to measure as it gives an account of the company’s customer retention capacity irrespective of gaining new customers through ad services. Consequently, it is less expensive to retain customers than to acquire new ones.

---

This project is a submission for the Maven Customer Churn Challenge. A descriptive and diagnostic approach was used to obtain insights and key performance indicators that influenced customer churn. 
The datasets consist of 2 tables containing data measures on all 7,043 customers from a Telecommunications company in California in Q2 2022. Each record represents one customer and contains details about their demographics, location, tenure, subscription services, status for the quarter (joined, stayed, or churned), and more. The Zip Code Population table contains complementary information on the estimated populations for the California zip codes in the Customer Churn table

---

**Business Problem**

The business seeks to identify high-value and churn-risk customers in other to keep the company stakeholders informed about the effect of customer churning on revenue and to further understand the percentage of newly joined and retained customers that are at a high risk of churning.
Specific objectives: The following insights were obtained 
1.	Data variables driving churning 
2.	The customer churning percentage for the quarter in review, 
3.	Effect of churning on revenue
4.	Why churning is happening

---
**Design**

The dataset consists of 37 measured variables that could influence churning. However, a regression coefficient and significance test were performed to filter the variables to only key performance indicators (KPI) that influence churning and that could be used to predict customers at churn risk.
Regression coefficient output: Only the outputs in this table significantly influenced churning and therefore were used in obtaining insights for other specific objectives listed above
![image](https://github.com/olusolaolagunju/Customer-Churn-Analysis/blob/main/image/Table.png)

**Customer segmentation**
: the customers were segmented into ten cohorts each for all the variables except for the Contract metric (customers are already in segments. That is month to month, one and two years cohorts). The first cohort contains the bottom 10% of customers in terms of the metric, the second cohort contains the next 10%, up to the final cohort which contains the top 10% of customers on the metric. The cohorts were done to calculate the percentage of customers in each cohort churned.

---
**Findings**

1. what is the total number of customers had in the year of review
```SQL
SELECT COUNT(CustomerID)
FROM CustomerChurn..Churn$

```

![image](https://github.com/olusolaolagunju/Customer-Churn-Analysis/blob/main/image/Total%20Customer.png)

2. what is the number of churned customer

```SQL 
SELECT COUNT(CustomerID)
FROM CustomerChurn..Churn$
WHERE CustomerStatus ='Churned'
```
![omage](https://github.com/olusolaolagunju/Customer-Churn-Analysis/blob/main/image/Churned%20customers.png)

**A total 1869 customers churned within the quarter review out of 7043 customers started with**

3.what is the customer churn rate 
```SQL
WITH CTE_ChurnRate as (
	SELECT COUNT(CustomerStatus) as TotalCustomer,
	(SELECT COUNT(CustomerStatus)  FROM CustomerChurn..Churn$ WHERE CustomerStatus = 'Churned') as TotalChurnedCustomer
FROM CustomerChurn..Churn$)
SELECT   CONVERT(Decimal(5,0),(TotalChurnedCustomer *1.00/ TotalCustomer) * 100) as CustomerchurnRate
FROM CTE_ChurnRate
```

![image](https://github.com/olusolaolagunju/Customer-Churn-Analysis/blob/main/image/Churnrate%205.png)

**The Customer churn rate was 27%**

---

In as much as we calculated the customer churn rate, it is also important to calculate the revenue churn rate to know the implication of customer churning.

4. what is the total revenue for the year in review
```SQL
SELECT ROUND(SUM(TotalRevenue),0) as TotalCustRevenue
FROM CustomerChurn..Churn$
```
![image](https://github.com/olusolaolagunju/Customer-Churn-Analysis/blob/main/image/Toatal%20Revenue.png)

5. What is the amount of revenue churned
```SQL
SELECT ROUND(SUM(TotalRevenue),0) as TotalCustRevenue
FROM CustomerChurn..Churn$
WHERE CustomerStatus ='Churned'
```
![image](https://github.com/olusolaolagunju/Customer-Churn-Analysis/blob/main/image/Revenue%20Churned.png)

**A total $3.6M was lost in revenue out of $21M**

6. what is the percentage of the revenue churned

    ```SQL
    WITH CTE_ChurnRevenue as (
	SELECT SUM(TotalRevenue) as TotalCustRevenue,(
	SELECT SUM(TotalRevenue) FROM CustomerChurn..Churn$ WHERE CustomerStatus ='Churned') as Revenuechurned
    FROM CustomerChurn..Churn$)
    SELECT CONVERT(Decimal(10,0),(Revenuechurned/TotalCustRevenue) *100) as RevenueChurnRate 
    FROM CTE_ChurnRevenue 
    ```
    ![image](https://github.com/olusolaolagunju/Customer-Churn-Analysis/blob/main/image/Revenue%20churn%20rate.png)

    **17% Revenue was lost to churning**

7. what is the average lifetime of a customer based on the tenure month
```SQL
SELECT  Round(avg(TenureMonths),0)
FROM CustomerChurn..Churn$ 
WHERE CustomerStatus ='Churned'
```

![image](https://github.com/olusolaolagunju/Customer-Churn-Analysis/blob/main/image/Customer%20average%20life.png)

**At an average, a customer spends 18 months before churning**

8. Calculate the customer churn rate per the average tenure month 
Customers in the Tenure month are not in groups, hence a need for a cohort analysis discussed in the design section
* adding a new column- TenureCohort to the churn table
```SQL
ALTER TABLE Churn$*
Add TenureCohort varchar(100)
```

* calculating the maximum value for the Tenure month for an easy segmentation 

```SQL
SELECT MAX(TenureMonths)
FROM Churn$
```
![image](https://github.com/olusolaolagunju/Customer-Churn-Analysis/blob/main/image/max.png) 

    The maximum tenure months used by any customer was 72 months, which was used as the cohort ten percent classification. as 10% of 72 is 7.2, the first cohort was round down to less than 7


* creating a **case** statement for the cohort 
```SQL
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
```

![image](https://github.com/olusolaolagunju/Customer-Churn-Analysis/blob/main/image/Tenure%20Cohort.png)


```SQL
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
```					

* Calculate the customer per the average tenure month 


```SQL
WITH CTE_TenurePerMonth as (
SELECT TenureCohort, ROUND(AVG(TenureMonths),0) as AverageMonthsPerCohort, COUNT(TenureMonths)as TotalChurnedCustomersPerCohort,
(SELECT COUNT(TenureMonths) FROM CustomerChurn..Churn$ WHERE CustomerStatus ='Churned')as TotalChurnedCustomer
FROM CustomerChurn..Churn$ 
WHERE CustomerStatus ='Churned'
GROUP BY TenureCohort)
SELECT *,ROUND( (TotalChurnedCustomersPerCohort*1.0 /TotalChurnedCustomer * 100),0) as ChurnRatePerCohortPerTenure
FROM CTE_TenurePerMonth
ORDER BY ChurnRatePerCohortPerTenure desc
```
![image](https://github.com/olusolaolagunju/Customer-Churn-Analysis/blob/main/image/Tenure%20Cohort%20churn%20rate.png)

  
Customers that stayed beyond the average tenure month (18 months) have a low churn rate (4-5%) but contributed the highest to the revenue churn rate (13-18%) 

![image](https://github.com/olusolaolagunju/Customer-Churn-Analysis/blob/main/image/Revenue_Tenure%20(2).png)

**Please check back for the complete report**
