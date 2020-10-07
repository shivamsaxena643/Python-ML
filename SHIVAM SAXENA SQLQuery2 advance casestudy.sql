--create database db_SQLCaseStudies

--use db_SQLCaseStudies

select * from DIM_CUSTOMER
select * from FACT_TRANSACTIONS
select * from DIM_DATE
select * from DIM_LOCATION
select * from DIM_MANUFACTURER
select * from DIM_MODEL


-- Q1. List all states in which we have customers who have bought cellphones from 2005 till today?

   Select T2.State, count(State) as Cust_cnt from [dbo].[FACT_TRANSACTIONS] T1
   Inner join [dbo].[DIM_LOCATION]T2 on T1.IDLocation = T2.IDLocation 
   Where YEAR(Date) > 2005 
   Group by T2.State


   -- Q2. Which state is US buying more Samsung Cellphones?

   Select Top 1 T2.State, Count(T4.Manufacturer_Name) as Cust_Cnt from FACT_TRANSACTIONS T1
   Inner join DIM_LOCATION T2 on T1.IDLocation = T2.IDLocation 
   Inner join DIM_MODEL T3 on T1.IDModel = T3.IDModel
   Inner join DIM_MANUFACTURER T4 on T3.IDManufacturer = T4.IDManufacturer 
   Where T4.Manufacturer_Name = 'Samsung' and T2.Country = 'US'
   Group by T2.State
   Order by 2 desc

-
   -- Q3. Show the number of transactions for each model per zipcode per state?

   Select  T3.IDModel, T2.ZipCode, T2.State, Count(T1.IDCustomer) as [No.of Trans] from FACT_TRANSACTIONS T1
   Left join DIM_LOCATION T2 on T1.IDLocation = T2.IDLocation 
   Left join DIM_MODEL T3 on T1.IDModel = T3.IDModel
   Group by T3.IDModel,T2.ZipCode, T2.State


-- Q4. Show the cheapest cellphone ?

   Select T1.IDModel, T1.Model_Name, T1.Unit_price, T2.Manufacturer_Name from DIM_MODEL T1
   Inner join DIM_MANUFACTURER T2 on T1.IDManufacturer = T2.IDManufacturer
   Where Unit_price = (Select Min(Unit_price) from DIM_MODEL)
    
-- Q5. Find out the average price for each model in top 5 manufacturers 
-- in terms of sales, quantity and order by average price


   Select T1.IDModel, Avg(TotalPrice) as Avg_price from  FACT_TRANSACTIONS T1
   Inner join DIM_MODEL T3 on T1.IDModel = T3.IDModel
   Inner join DIM_MANUFACTURER T4 on T3.IDManufacturer = T4.IDManufacturer
   Where T3.IDManufacturer in ( Select top 5 T3.IDManufacturer
   from FACT_TRANSACTIONS T1
   left join DIM_MODEL T3 on T1.IDModel = T3.IDModel
   Group by T3.IDManufacturer
   Order by Sum(TotalPrice) desc, Count(T1.Quantity) desc)
   Group by T1.IDModel
   Order by 2



    Select top 5 T3.IDManufacturer
    from FACT_TRANSACTIONS T1
    left join DIM_MODEL T3 on T1.IDModel = T3.IDModel
    Group by T3.IDManufacturer
    Order by Sum(TotalPrice) desc, Count(T1.Quantity) desc



-- Q6. List the name of the customers and avg amount spent in 2009, 
--        where the average amount is higher than 500


   Select T1.Customer_Name, Avg(TotalPrice) as Avg_spent from DIM_CUSTOMER T1
   left join FACT_TRANSACTIONS T2 on t1.IDCustomer = T2.IDCustomer
   Where YEAR(T2.Date) = 2009 
   Group by T1.Customer_Name
   Having Avg(TotalPrice) > 500

-- Q7. List if there is any model that was in top 5 in terms of quantity, simultaneously
--    in 2008, 2009, 2010 ?

   Select * from 
   (Select Top 5  ROW_NUMBER() Over(order by Sum(Quantity) desc) as rownum, IDModel, Sum(Quantity) as Qty_sold
   from FACT_TRANSACTIONS
   Where YEAR(Date) = 2008 Group by IDModel 
   Union all
   Select Top 5 ROW_NUMBER() Over(order by Sum(Quantity) desc) as rownum, IDModel, Sum(Quantity) as Qty_sold 
   from FACT_TRANSACTIONS 
   Where YEAR(Date) = 2009 Group by IDModel 
   Union all
   Select Top 5 ROW_NUMBER() Over(order by Sum(Quantity) desc) as rownum, IDModel, Sum(Quantity) as Qty_sold 
   from FACT_TRANSACTIONS 
   Where YEAR(Date) = 2010 Group by IDModel) as tl1
   

-- Q8. Show the manufacturer with 2nd top sales in 2009 and the manufacturer with 2nd top sales in 2010


   Select IDManufacturer ,Manufacturer_Name, Total_sale
   from 
   (Select ROW_NUMBER()Over(order by Sum(TotalPrice) desc) as Rownum,  
   T3.IDManufacturer, T4.Manufacturer_Name, Sum(TotalPrice) as Total_sale
   from FACT_TRANSACTIONS T1
   left join DIM_MODEL T3 on T1.IDModel = T3.IDModel
   left join DIM_MANUFACTURER T4 on T3.IDManufacturer = T4.IDManufacturer
   Where YEAR(Date) = 2009 
   Group by T3.IDManufacturer, T4.Manufacturer_Name
   union all
   Select ROW_NUMBER()Over(order by Sum(TotalPrice) desc) as Rownum,
   T3.IDManufacturer, T4.Manufacturer_Name, Sum(TotalPrice)
   from FACT_TRANSACTIONS T1
   left join DIM_MODEL T3 on T1.IDModel = T3.IDModel
   left join DIM_MANUFACTURER T4 on T3.IDManufacturer = T4.IDManufacturer
   Where YEAR(Date) = 2010
   Group by T3.IDManufacturer, T4.Manufacturer_Name) TL
   Where Rownum = 2

-- Q9. show the manufacturers that sold phones in 2010 but didnt sold in 2009?


   Select T4.Manufacturer_Name from FACT_TRANSACTIONS T1
   Inner join DIM_MODEL T3 on T1.IDModel = T3.IDModel
   Inner join DIM_MANUFACTURER T4 on T3.IDManufacturer = T4.IDManufacturer
   Where YEAR(Date) = 2010 
   and T4.Manufacturer_Name not in (Select T4.Manufacturer_Name 
   From FACT_TRANSACTIONS T1
   Inner join DIM_MODEL T3 on T1.IDModel = T3.IDModel
   Inner join DIM_MANUFACTURER T4 on T3.IDManufacturer = T4.IDManufacturer
   Where YEAR(Date) = 2009
   Group by T4.Manufacturer_Name)
   Group by T4.Manufacturer_Name

-- Q10. Find top 100 customers and their avg spent, avg quantity by each year. 
-- .Also find % change in their in spend


    SELECT top 100 
    t1.IDCustomer, 
    YEAR(t1.DATE) [YEAR], Sum(t1.TotalPrice) over (partition by IDCustomer) as TotalSpend,
    AVG(t1.QUANTITY * 1.0) over (partition by t1.IDCustomer, YEAR(t1.DATE)) as AvgQuantity,
    AVG(t1.TotalPrice * 1.0) over (partition by t1.IDCustomer, YEAR(t1.DATE)) as AvgSpend
	FROM FACT_TRANSACTIONS t1 


   
    SELECT *,
    (Avgspend - lag(AvgSpend,1) over (partition by IDCustomer order by [YEAR])) * 100.0 / AvgSpend as Percent_change
    from tbl13 
