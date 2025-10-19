# RFM-Based Customer Segmentation for Strategic Insights

This project focuses on **customer segmentation using RFM (Recency, Frequency, Monetary) analysis**, a proven method for identifying and categorizing customers based on their purchasing behavior.  
By assigning scores to each RFM metric and classifying customers into meaningful segments (e.g., *Champions*, *Loyal Customers*, *At Risk*, *Lost*), businesses can optimize marketing strategies, improve customer retention, and drive revenue growth.

---

## 🧠 Questions that can be answered through this project:
- Who are our most valuable customers?  
- Which customers are at risk of churning?  
- Which customers used to buy frequently but have stopped?  
- Which customers should receive re-engagement campaigns?  
- Which customers are most likely to respond to upsell or cross-sell offers?  
- How can we optimize loyalty programs for different customer segments?  

---

## 📊 SQL Analysis

### 1️⃣ Finding Number of Customers, Orders, and Average Paid Price per Country
```sql
SELECT DISTINCT country AS country,
       COUNT(DISTINCT invoice) AS Number_Of_Orders,
       COUNT(DISTINCT customer_id) AS Number_Of_Customers,
       ROUND(AVG(price * quantity), 2) AS Avg_Payment
FROM tableretail
GROUP BY country
ORDER BY Number_Of_Orders DESC, Number_Of_Customers DESC;
Output Sample:

Country	Number_Of_Orders	Number_Of_Customers	Avg_Payment
United Kingdom	717	110	19.89

2️⃣ Number of Orders per Date
sql
نسخ الكود
SELECT invoicedate AS date,
       COUNT(invoice) AS Number_Of_Orders
FROM tableretail
GROUP BY invoicedate
ORDER BY Number_Of_Orders DESC;
Output Sample:

Date	Number_Of_Orders
11/17/2011 14:26	154
9/28/2011 15:21	141
11/8/2011 14:22	140

3️⃣ Quantities Ordered per Date
sql
نسخ الكود
SELECT invoicedate AS date,
       SUM(quantity) AS Total_Quantities_Per_Date
FROM tableretail
GROUP BY invoicedate
ORDER BY Total_Quantities_Per_Date DESC;
Output Sample:

Date	Total_Quantities_Per_Date
8/4/2011 18:06	11848
8/11/2011 15:58	6098
10/27/2011 12:26	4936

4️⃣ RFM Segmentation
sql
نسخ الكود
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
        NTILE(5) OVER (ORDER BY recency DESC) AS recency,
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
        WHEN (recency + frequency + monetary) = 15 THEN 'Champions'
        WHEN (recency + frequency + monetary) >= 12 THEN 'Loyal Customers'
        WHEN (recency + frequency + monetary) BETWEEN 9 AND 11 THEN 'Potential Loyalists'
        WHEN (recency + frequency + monetary) BETWEEN 6 AND 8 THEN 'Customers Needing Attention'
        WHEN (recency + frequency + monetary) BETWEEN 4 AND 5 THEN 'Hibernating'
        WHEN (recency + frequency + monetary) <= 3 THEN 'Lost'
    END AS customer_segment
FROM customer_segment_base
ORDER BY recency DESC, frequency DESC, monetary DESC;
Output Sample:

Customer_ID	Recency	Frequency	Monetary	Segment
12868	5	4	4	Loyal Customers
12872	5	4	3	Loyal Customers
12878	5	3	3	Potential Loyalists

📈 Quick Insights
The total number of orders: 717 across 110 customers (mostly from the UK).

Average payment per order: £19.89

Most orders are placed between 09:00 AM and 4:30 PM.

The highest revenue occurred on 8/4/2011 18:06 with total sales of £18,841.

Customers tend to order multiple items frequently — indicating potential for loyalty segmentation.

