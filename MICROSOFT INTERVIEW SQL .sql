USE [Microsoft  INT SOLn];
GO

---------------------------------------------------------1-------------------------------------------------------------------------

CREATE TABLE Orders_1 (
    Region VARCHAR(50),
    Order_Date DATE,
    Order_ID INT PRIMARY KEY,
    Amount DECIMAL(10, 2)
);


INSERT INTO Orders_1 (Region, Order_Date, Order_ID, Amount)
VALUES
    ('North', '2024-01-15', 1, 500),
    ('North', '2024-03-05', 5, 600),
    ('South', '2024-01-20', 2, 700),
    ('East', '2024-02-18', 4, 200);


--INT QUE 1:Compute the cumulative percentage of total sales (amount) for each region, 
--ordered by order_date. Display the cumulative percentage alongside other details.

                                                                         --Cum_per of TS fro region each order by O_date
																		 -- Cume_dist() WF
SELECT * ,
CONCAT(CUME_DIST() OVER(PARTITION BY region ORDER BY order_date ASC) * 100,'%') as [Rank]
FROM Orders_1;

 






---------------------------------------------------------2-------------------------------------------------------------------------

CREATE TABLE Orders_2 (
    Order_ID INT PRIMARY KEY,
    Customer_ID INT,
    Order_Date DATE,
    Amount INT
);


INSERT INTO Orders_2 (Order_ID, Customer_ID, Order_Date, Amount)
VALUES
    (1, 101, '2024-01-15', 500),
    (2, 102, '2024-01-20', 700),
    (3, 101, '2024-02-10', 300),
    (4, 103, '2024-02-18', 200),
    (5, 101, '2024-03-05', 600);
SELECT * FROM Orders_2;


--INT QUE 2: Find the first and last orders placed by each customer based on order_date.
--Include their order IDs, amounts, and the difference in days between the first and last orders
                                            
											                 --F and L order by each Cust 
															 --order by O_date
															 -- FV and LV WF ,PB CID OB O_DATE
SELECT DISTINCT
       Customer_ID,
	   FIRST_VALUE(Order_ID) OVER(PARTITION BY Customer_ID ORDER BY Order_date) as [First Order],
	   LAST_VALUE(Order_ID) OVER(PARTITION BY Customer_id ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Last Order],
	   DATEDIFF(DAY,(MIN(Order_date) OVER(PARTITION BY Customer_ID)),(MAX(Order_date) OVER(PARTITION BY Customer_ID)))
FROM Orders_2;


------------WITH SUBQUERY


SELECT DISTINCT 
               Customer_ID,
		       [First Order],
		       [Last Order],
		       Day_Difference
FROM (
		SELECT Order_id as Order_ID,
			   Customer_ID,
			   Amount,
			   Order_date,
			   FIRST_VALUE(Order_ID) OVER(PARTITION BY Customer_ID ORDER BY Order_date) as [First Order],
			   LAST_VALUE(Order_ID) OVER(PARTITION BY Customer_id ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Last Order],
			   DATEDIFF(DAY,(MIN(Order_date) OVER(PARTITION BY Customer_ID)),(MAX(Order_date) OVER(PARTITION BY Customer_ID))) as Day_Difference
		FROM Orders_2) AS I;


----WITH CTE

WITH order_CTE 
AS (
SELECT Order_id as Order_ID,
			   Customer_ID,
			   Amount,
			   Order_date,
			   FIRST_VALUE(Order_ID) OVER(PARTITION BY Customer_ID ORDER BY Order_date) as [First Order],
			   LAST_VALUE(Order_ID) OVER(PARTITION BY Customer_id ORDER BY order_date ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as [Last Order],
			   DATEDIFF(DAY,(MIN(Order_date) OVER(PARTITION BY Customer_ID)),(MAX(Order_date) OVER(PARTITION BY Customer_ID))) as Day_Difference
		FROM Orders_2 )
SELECT DISTINCT 
               Customer_ID,
		       [First Order],
		       [Last Order],
		       Day_Difference
FROM order_CTE;


----------------------------------NOT USING SUB QUERY AND CTE FOR EVERY QUESTIONS-------------



---------------------------------------------------------3-------------------------------------------------------------------------


CREATE TABLE Sales_Data (
    Region VARCHAR(50),
    Month VARCHAR(20),
    Year INT,
    Sales INT
);


INSERT INTO Sales_Data (Region, Month, Year, Sales)
VALUES 
('North', 'January', 2024, 15000),
('North', 'February', 2024, 18000),
('North', 'March', 2024, 20000),
('South', 'January', 2024, 14000),
('South', 'February', 2024, 16000);


--INT QUE 3: Calculate the 3-month rolling average of sales for each region. 
--If there aren't enough months for a 3-month window, the rolling average should still be computed based on the available data.

                                                                    --Rollinng avg of 3 month sale  by each region
																	--Avg WF ,PB Region ,frame size 3 month

SELECT Region,
	   [Month],
	   Sales,
	   AVG(Sales) OVER(PARTITION BY Region ORDER BY [MONTH] ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as Average_Sales
FROM Sales_Data;


---------------------------------------------------------4-------------------------------------------------------------------------

CREATE TABLE Orders_3(
    Order_ID INT PRIMARY KEY,
    Customer_ID VARCHAR(10),
    Order_Date DATE,
    Order_Amount DECIMAL(10, 2)
);


INSERT INTO Orders_3 (Order_ID, Customer_ID, Order_Date, Order_Amount)
VALUES 
    (1, 'C001', '2024-01-10', 300),
    (2, 'C002', '2024-01-12', 450),
    (3, 'C003', '2024-04-15', 600);

--INT QUE 4: Rank customers by their total spending, but only consider orders with an amount less than or equal to $500.

                                                                           --Rank on basis of spending,on;y bewo pr equal to 500
																		   --DENSE RANK WF,subquery ,Filter clause
SELECT [Rank],
       Customer_ID,
       Order_Amount
FROM (
SELECT *,
DENSE_RANK() OVER(ORDER BY order_amount DESC) as [Rank]
FROM Orders_3) as I
WHERE Order_Amount<=500;


