 use RFM ;

 select
 *
 from  tableRetail ;



/* Finding Number of Customers, Orders, and Average Paid Price per Country*/

SELECT  DISTINCT country                           AS country,
          COUNT(DISTINCT invoice)                    AS Number_Of_Orders,
          COUNT(DISTINCT customer_id)                AS Number_Of_Customers,
          ROUND(AVG(price * quantity), 2)            AS Avg_Payment
    FROM  tableretail
GROUP BY  country
ORDER BY  Number_Of_Orders desc,Number_Of_Customers desc;





SELECT 
    invoicedate AS date,
    COUNT(invoice) AS Number_Of_Orders
FROM tableretail
GROUP BY invoicedate
ORDER BY Number_Of_Orders DESC;


SELECT 
    invoicedate AS date,
    sum([Quantity])as Total_Quantities_Per_Date
FROM tableretail
GROUP BY invoicedate
ORDER BY Total_Quantities_Per_Date DESC;





SELECT 
    invoicedate AS date,
    sum(Price*Quantity)as Total_Quantities_Per_Date
FROM tableretail
GROUP BY invoicedate
ORDER BY Total_Quantities_Per_Date DESC;





SELECT 
    Customer_ID AS date,
	invoicedate AS date,
    sum(Price*Quantity)    AS Total_Price
FROM tableretail
GROUP BY Customer_ID,invoicedate 
ORDER BY Total_Quantities_Per_Date DESC;









WITH rfm_base AS (
    SELECT 
        customer_id,
        MAX(CAST(invoicedate AS DATE)) AS Last_order_Date,
        COUNT(invoice) AS order_count,
        SUM(price * quantity) AS total_price
    FROM tableretail
    GROUP BY customer_id
),
rfm AS (
    SELECT 
        customer_id,
        DATEDIFF(DAY, Last_order_Date, GETDATE()) AS recency,
        order_count,
        total_price
    FROM rfm_base
),
customer_segment_base AS (
    SELECT 
        customer_id,
        NTILE(5) OVER (ORDER BY recency desc) AS recency,
        NTILE(5) OVER (ORDER BY order_count ASC) AS frequency,
        NTILE(5) OVER (ORDER BY total_price ASC) AS monetary
    FROM rfm
)
SELECT 
    customer_id,
    recency,
    frequency,
    monetary,
    CASE 
        WHEN (recency + frequency + monetary) = 15             THEN 'Champions'
        WHEN (recency + frequency + monetary) >= 12            THEN 'Loyal Customers'
        WHEN (recency + frequency + monetary) BETWEEN 9 AND 11 THEN 'Potential Loyalists'
        WHEN (recency + frequency + monetary) BETWEEN 6 AND 8  THEN 'Customers Needing Attention'
        WHEN (recency + frequency + monetary) BETWEEN 4 AND 5  THEN 'Hibernating'
        WHEN (recency + frequency + monetary) <= 3             THEN 'Lost'
    END AS customer_segment
FROM customer_segment_base
ORDER BY recency DESC, frequency DESC, monetary DESC;





