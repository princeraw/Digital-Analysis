
CREATE DATABASE ecommerce;

USE ecommerce;

Select * FROM orders;
Select * FROM order_items;
Select * FROM order_item_refunds;
Select * FROM website_pageviews;
Select * FROM website_sessions;
Select * FROM products;




-----------------------------------------------------Data Understanding---------------------------------------------------------------------------------------


--------------------------------------------------orders------------------------------------------------------------------------------

select * from orders;
-- checking for null
select * from orders where order_id is null 
union all
select * from orders where created_at is null
union all
select * from orders where website_session_id is null 
union all
select * from orders where user_id is null 
union all
select * from orders where items_purchased is null 
union all
select * from orders where price_usd is null 
union all
select * from orders where cogs_usd is null 


-- Checking for duplicate

    SELECT order_id, price_usd, cogs_usd,user_id,website_session_id,created_at
    FROM orders
    GROUP BY order_id, price_usd, cogs_usd,user_id,website_session_id,created_at
    HAVING COUNT(*) > 1


--------------------------------------------------website_session------------------------------------------------------------------------------


select * from website_sessions;

select * from website_sessions where website_session_id is null 
union all
select * from website_sessions where created_at is null
union all
select * from website_sessions where user_id is null 
union all
select * from website_sessions where is_repeat_session is null 
union all
select * from website_sessions where utm_source is null 
union all
select * from website_sessions where utm_campaign is null 
union all
select * from website_sessions where utm_content is null 
union all
select * from website_sessions where device_type is null
union all
select * from website_sessions where http_referer is null 

---------------------------------------------------------------------------------------------------------------------
--Handling NULL values
----------------------------------------------------------------------------------------------------------------------

UPDATE website_sessions
SET utm_source = 'direct' 
WHERE utm_source = 'Null';

UPDATE website_sessions
SET utm_campaign = 'none' 
WHERE utm_campaign = 'Null';

UPDATE website_sessions
SET utm_content = 'none' 
WHERE utm_content = 'Null';

UPDATE website_sessions
SET http_referer = 'direct' 
WHERE http_referer = 'Null';

---------------------------------------------website_pageview------------------------------------------------------------------------------
select * from website_pageviews;

select * from orders
select * from website_pageviews where website_pageview_id is null 
union all
select * from website_pageviews where created_at is null
union all
select * from website_pageviews where website_session_id is null 
union all
select * from website_pageviews where pageview_url is null 


----------------------------------------------Execitive Summary--------------------------------------------------------------


-----------------------------------------------------------------------------------------------------------------------
--Key Performance Indicator
-----------------------------------------------------------------------------------------------------------------------

-- Total Unique Customers

SELECT 
    COUNT(DISTINCT user_id) AS total_customers
FROM 
    website_sessions;

-- Total Customers who Ordered
SELECT 
    COUNT(DISTINCT user_id) AS customers_placed_order
FROM 
    orders;

--Calculating Net Revenue

SELECT
	SUM(oi.price_usd) AS total_revenue,
	SUM(oir.refund_amount_usd) AS total_refund,
	SUM(oi.price_usd)-SUM(oir.refund_amount_usd) AS net_revenue
FROM 
	order_items oi LEFT JOIN order_item_refunds oir
	ON oi.order_id = oir.order_id AND oi.order_item_id = oir.order_item_id;

--Calculating Average Order Value (AOV)

SELECT 
	SUM(price_usd) as total_revenue,
	COUNT(DISTINCT(order_id)) as total_orders,
    SUM(price_usd) / COUNT(DISTINCT(order_id)) AS AOV
FROM 
     order_items;

--Calculating Gross Profit Margin

SELECT 
    (SUM(price_usd) - SUM(cogs_usd)) * 100 / SUM(price_usd) AS Gross_Profit_Margin
FROM 
    order_items;

--Calculate Total Number of Orders,Number of Refunded Orders and Refund Rate

WITH order_refund_table AS (
	SELECT
		COUNT(DISTINCT oi.order_id) AS total_orders,
		COUNT(DISTINCT oir.order_id) AS total_refunded_orders
	FROM 
		order_items oi 
		LEFT JOIN 
		order_item_refunds oir
			ON oi.order_id = oir.order_id AND oi.order_item_id = oir.order_item_id
)
SELECT 
    total_orders,
	total_refunded_orders,
	total_refunded_orders*100.0/total_orders AS refund_rate
FROM 
	order_refund_table;



-----------------------------------------------------------------------------------------------------------------------
--REVENUE TREND OVER TIME
-----------------------------------------------------------------------------------------------------------------------

--Average Daily Revenue Trend
WITH DailyRevenue AS (
    SELECT 
        FORMAT(created_at, 'yyyy-MM') AS r_month,
        DATEPART(WEEKDAY, created_at) AS day_of_week,
        SUM(price_usd) AS daily_revenue
    FROM 
        order_items
    GROUP BY 
        FORMAT(created_at, 'yyyy-MM'),
        DATEPART(WEEKDAY, created_at) 
)
SELECT 
	day_of_week,
    AVG(daily_revenue) AS average_daily_revenue
FROM 
    DailyRevenue
GROUP BY 
	day_of_week
ORDER BY
	day_of_week;

--Average Weekly Revenue
WITH WeeklyRevenue AS (
    SELECT 
        DATEPART(YEAR, created_at) AS revenue_year,
        DATEPART(WEEK, created_at) AS revenue_week,
        SUM(price_usd) AS weekly_revenue
    FROM 
        order_items
    GROUP BY 
        DATEPART(YEAR, created_at),
        DATEPART(WEEK, created_at)
)
SELECT 
	revenue_week,
    AVG(weekly_revenue) AS average_weekly_revenue
FROM 
    WeeklyRevenue
GROUP BY
	revenue_week;

--Average Monthly Revenue
WITH MonthlyRevenue AS (
    SELECT 
        DATEPART(YEAR, created_at) AS r_year,
        DATEPART(MONTH, created_at) AS r_month,
        SUM(price_usd) AS monthly_revenue
    FROM 
        order_items
    GROUP BY 
        DATEPART(YEAR, created_at),
        DATEPART(MONTH, created_at)
)
SELECT 
	r_month,
    AVG(monthly_revenue) AS average_monthly_revenue
FROM 
    MonthlyRevenue
GROUP BY
	r_month
ORDER BY
	r_month;






-- WEEKLY REVENUE
SELECT 
    CONCAT( DATEPART(YEAR, created_at), '-', DATEPART(WEEK, created_at) ) AS week,
    SUM(price_usd) AS weekly_revenue
FROM 
    order_items
GROUP BY 
    CONCAT( DATEPART(YEAR, created_at), '-', DATEPART(WEEK, created_at) )
ORDER BY 
   week;


--MONTHLY REVENUE
SELECT 
	FORMAT(created_at, 'yyyy-MM') AS month,
	SUM(price_usd) AS monthly_revenue
FROM 
    order_items
GROUP BY 
    FORMAT(created_at, 'yyyy-MM')
ORDER BY 
    FORMAT(created_at, 'yyyy-MM');



-----------------------------------------------------------------------------------------------------------------------
--AOV TREND OVER TIME
-----------------------------------------------------------------------------------------------------------------------

--MONTHLY AOV
SELECT 
	FORMAT(created_at, 'yyyy-MM') AS month,
	SUM(price_usd)/SUM(DISTINCT(order_id)) AS monthly_AOV
FROM 
    order_items
GROUP BY 
    FORMAT(created_at, 'yyyy-MM')
ORDER BY 
    FORMAT(created_at, 'yyyy-MM');

-----------------------------------------------------------------------------------------------------------------------
--No of orders TREND OVER TIME
-----------------------------------------------------------------------------------------------------------------------

--MONTHLY Orders
SELECT 
	FORMAT(created_at, 'yyyy-MM') AS month,
	SUM(DISTINCT(order_id)) AS monthly_orders
FROM 
    order_items
GROUP BY 
    FORMAT(created_at, 'yyyy-MM')
ORDER BY 
    FORMAT(created_at, 'yyyy-MM');

----------------------------------------------------------------------------------------------------------------------
--TREND/ SEASONALITY ANALYSIS
----------------------------------------------------------------------------------------------------------------------

--Calculating Daily Session Volume

WITH daily_sessions AS (
    SELECT 
        FORMAT(created_at, 'yyyy-MM') AS month,
        DATEPART(weekday, created_at) AS day_of_week,
        COUNT(website_session_id) AS session_count
    FROM 
        website_sessions
    GROUP BY 
        FORMAT(created_at, 'yyyy-MM'), DATEPART(weekday, created_at)
)
SELECT 
    day_of_week,
    AVG(session_count) AS avg_session_count
FROM 
    daily_sessions
GROUP BY 
    day_of_week
ORDER BY 
    day_of_week;


--Calculating Monthly Session Volume
WITH monthly_sessions AS (
	SELECT 
		FORMAT(created_at, 'yyyy-MM') AS month,
		DATEPART(MONTH, created_at) AS order_month,
		COUNT(*) AS session_count
	FROM 
		website_sessions
	GROUP BY 
		FORMAT(created_at, 'yyyy-MM'), 
		DATEPART(MONTH, created_at) 
)
SELECT
	order_month,
	AVG(session_count) AS avg_session_count
FROM monthly_sessions
GROUP BY
	order_month
ORDER BY 
	order_month;


---------------------------------------------------------------------------------------------------------------------
--Calculating site traffic breakdown
----------------------------------------------------------------------------------------------------------------------
--via source type

SELECT 
	 ws.utm_source,
	COUNT(DISTINCT ws.website_session_id) AS session_count,
	COUNT(DISTINCT oi.order_id) AS total_orders,
	SUM(oi.price_usd) AS total_revenue,
	(SUM(oi.price_usd) / COUNT(DISTINCT o.user_id)) AS avg_revenue_per_user,
	ROUND(COUNT(DISTINCT ws.website_session_id) * 100.0 / (SELECT COUNT(DISTINCT website_session_id) FROM website_sessions), 2) AS "visit%",
	ROUND(SUM(oi.price_usd) * 100.0 / (SELECT SUM(price_usd)  FROM order_items), 2) AS "revenue%"

FROM
	website_sessions AS ws
	LEFT JOIN
	orders AS o ON ws.website_session_id = o.website_session_id
	LEFT JOIN 
	order_items oi ON o.order_id = oi.order_id
GROUP BY
    ws.utm_source
ORDER BY
    total_revenue DESC;


--via device type

SELECT 
	 ws.device_type,
	COUNT(DISTINCT ws.website_session_id) AS session_count,
	COUNT(DISTINCT oi.order_id) AS total_orders,
	SUM(oi.price_usd) AS total_revenue,
	(SUM(oi.price_usd) / COUNT(DISTINCT o.user_id)) AS avg_revenue_per_user,
	 ROUND(COUNT(DISTINCT ws.website_session_id) * 100.0 / (SELECT COUNT(DISTINCT website_session_id) FROM website_sessions), 2) AS "visit%",
	 ROUND(SUM(oi.price_usd) * 100.0 / (SELECT SUM(price_usd)  FROM order_items), 2) AS "revenue%"

FROM
	website_sessions AS ws
	LEFT JOIN
	orders AS o ON ws.website_session_id = o.website_session_id
	LEFT JOIN 
	order_items oi ON o.order_id = oi.order_id
GROUP BY
    ws.device_type
ORDER BY
    total_revenue DESC;



------------------------------------------------------------------------------------------------------------------------
--PRODUCT LEVEL ANALYSIS
------------------------------------------------------------------------------------------------------------------------

--Product performance Analysis

SELECT 
    p.product_id,
    p.product_name,
	COUNT( distinct oi.order_id) AS total_orders,
	COUNT(DISTINCT oir.order_id)*100/COUNT( distinct oi.order_id) AS refund_rate,
    SUM(oi.price_usd) AS total_revenue,
	ROUND(SUM(oi.price_usd) * 100.0 / (SELECT SUM(price_usd)  FROM order_items), 2) AS "revenue%"
FROM 
    products p
JOIN 
    order_items oi ON p.product_id = oi.product_id
	LEFT JOIN order_item_refunds oir
	ON oi.order_id = oir.order_id AND oi.order_item_id = oir.order_item_id
GROUP BY 
    p.product_id, p.product_name
ORDER BY 
    total_revenue DESC;

-- Cross-Sell Analysis(Find Commonly Purchased Together products)

WITH order_item_name AS (
	SELECT oi.product_id, p.product_name as product_name, oi.order_id
	FROM
	order_items oi LEFT JOIN products p ON oi.product_id = p.product_id
)

SELECT
    a.product_name AS prod_1,
    b.product_name AS prod_2,
    COUNT(*) AS purchase_count
FROM 
    order_item_name a
JOIN 
    order_item_name b ON a.order_id = b.order_id AND a.product_id < b.product_id
GROUP BY 
    a.product_name, b.product_name
ORDER BY 
    purchase_count DESC;

SELECT
    a.product_id AS prod_1,
    b.product_id AS prod_2,
    COUNT(*) AS purchase_count
FROM 
    order_items a
JOIN 
    order_items b ON a.order_id = b.order_id AND a.product_id < b.product_id
GROUP BY 
    a.product_id, b.product_id
ORDER BY 
    purchase_count DESC;



------------------------------------------------------------------------------------------------------------------------
--Website MAnager Dashboard
------------------------------------------------------------------------------------------------------------------------
SELECT 
	WP.pageview_url,
	WP.created_at,
	WP.website_pageview_id,
	WP.website_session_id,
	WS.device_type,
	WS.is_repeat_session,
	WS.user_id,
	WS.utm_campaign,
	WS.utm_content,
	WS.utm_source,
	WS.http_referer
INTO Session_and_Pageview
FROM website_pageviews WP
INNER JOIN website_sessions WS ON WP.website_session_id=WS.website_session_id

SELECT Count(*) FROM Session_and_Pageview

--total number of Visit

SELECT COUNT(website_session_id) AS [TotalVisit] FROM website_sessions



--Unique Visitors

SELECT  COUNT(DISTINCT user_id) AS [Unique Users] FROM website_sessions



--Page Views 

SELECT COUNT(website_pageview_id)  [Page Views] FROM website_pageviews;


-- Average session duration


WITH session_duration AS
 (
	SELECT
		website_session_id,
		MIN(created_at) AS session_start_time,
		MAX(created_at) AS session_end_time,
		DATEDIFF(MINUTE, MIN(created_at), MAX(created_at))AS session_duration_MINUTES
	FROM website_pageviews 
	GROUP BY website_session_id
)

SELECT
	AVG(session_duration_MINUTES) [Average Session Duration in Minutes]
FROM session_duration;


--Revenue for new sessions



WITH NEW_SESSION AS
(
	SELECT  DISTINCT
		WS.user_id AS Userid,
		WS.website_session_id AS SessionId,
		OI.order_item_id AS orderitem,
		OI.price_usd AS Price,
		DENSE_RANK() OVER(PARTITION BY WS.user_id order by WS.website_session_id) AS RANKS
	FROM website_sessions WS
	JOIN orders O ON WS.website_session_id=O.website_session_id
	JOIN order_items OI ON O.order_id=OI.order_id
)

SELECT
	ROUND(CAST(SUM(PRICE) AS FLOAT),2)as [Revenue for New session]
FROM NEW_SESSION 
WHERE RANKS = 1 ;



--REVENUE FOR REPEATED SESSIONS


WITH REPEATED_SESSION AS
(
	SELECT  DISTINCT
		WS.user_id AS Userid,
		WS.website_session_id AS SessionId,
		OI.order_item_id AS orderitem,
		OI.price_usd AS Price,
		DENSE_RANK() OVER(PARTITION BY WS.user_id order by WS.website_session_id) AS RANKS
	FROM website_sessions WS
	JOIN orders O ON WS.website_session_id=O.website_session_id
	JOIN order_items OI ON O.order_id=OI.order_id
)

SELECT
	ROUND(CAST(SUM(PRICE) AS FLOAT),2)as [Revenue for Repeate session]
FROM REPEATED_SESSION 
WHERE RANKS >1

--Bounce Rate


WITH SINGLE_PAGE_VIEW AS 
(
	SELECT 
		COUNT(counts) [Single page view] 
	FROM
	(
		SELECT 
			COUNT(website_session_id) AS counts
		FROM website_pageviews
		GROUP BY website_session_id
		HAVING COUNT(website_session_id)=1
	)RESULT
),Total_session AS
(
	SELECT
		COUNT(website_session_id) [Total_sessions]
	FROM website_pageviews
)

SELECT 
	ROUND((CAST(SINGLE_PAGE_VIEW.[Single page view] AS float)/CAST(Total_session.[Total_sessions] AS float))*100,0) as [Bounce Rate]
FROM SINGLE_PAGE_VIEW, Total_session


--Pages per session


SELECT
	AVG([Page Count]) [Avg Pages Viewed per session],
	MAX([Page Count]) [Max Pages viewed per session]
FROM
(
	SELECT
		website_session_id,
		COUNT(pageview_url) [Page Count]
	FROM website_pageviews
	GROUP BY website_session_id
)RESULT

--Time on page


WITH Each_page_time as
(
	SELECT
		pageview_url,
		(SUM(time_spent_SECONDS)/60.0) as [Time on page in Minutes],
		count(pageview_url) as counts
	FROM
	(
		SELECT 
			wp.website_session_id,
			wp.website_pageview_id,
			WP.pageview_url,
			wp.created_at AS page_start_time, 
			MIN(wp1.created_at) AS next_page_start_time,
			DATEDIFF(SECOND, wp.created_at, MIN(wp1.created_at)) AS time_spent_SECONDS
		FROM website_pageviews wp
		LEFT JOIN website_pageviews wp1 on wp.website_session_id=wp1.website_session_id
		AND wp.created_at< wp1.created_at
		GROUP BY 
			  wp.website_session_id,
			  wp.website_pageview_id,
			  wp.pageview_url,
			  wp.created_at
	)RESULT
	GROUP BY pageview_url
)
SELECT
	pageview_url,
	ROUND((CAST([Time on page in Minutes] AS FLOAT) /counts),1) [Time on Each Page in Min]
FROM Each_page_time;


--Convesion Rate



WITH BILLED_SESSIONS AS
(
	SELECT 
		COUNT(distinct(order_id)) Orders
		FROM orders
),TOTAL_SESSIONS AS
(
	SELECT 
		COUNT(DISTINCT(website_session_id)) [Total Sessions]
	FROM website_pageviews
)

SELECT
	ROUND((CAST(Orders AS float)/CAST([Total Sessions] AS float))*100,2) [Conversion Rate]
FROM BILLED_SESSIONS,TOTAL_SESSIONS;



--Top website page


SELECT  
	pageview_url,
	COUNT(pageview_url) AS COUNT
FROM website_pageviews
GROUP BY pageview_url 
ORDER BY COUNT DESC;





--New and Repeate website visitors



WITH TOTAL_SESSIONS AS
(
	SELECT  DISTINCT
		WS.user_id AS Userid,
		WS.website_session_id AS SessionId,
		DENSE_RANK() OVER(PARTITION BY WS.user_id order by WS.website_session_id) AS RANKS
	FROM website_sessions WS
	
),NEW_SESSION_COUNT AS
(
	SELECT
		count(SessionId)as [New Visitor]
	FROM TOTAL_SESSIONS 
	WHERE RANKS =1
),REPEATE_SESSION_COUNT AS
(
	SELECT
		count(SessionId)as [Repeate Visitor]
	FROM TOTAL_SESSIONS 
	WHERE RANKS >1
)

SELECT
	[New Visitor],
	[Repeate Visitor]
FROM NEW_SESSION_COUNT, REPEATE_SESSION_COUNT;






--Entry page



WITH entry_page AS
(
	SELECT
		website_session_id,
		website_pageview_id,
		created_at,
		pageview_url
	FROM
	(
		SELECT
			website_session_id,
			website_pageview_id,
			created_at,
			pageview_url,
			DENSE_RANK() OVER(PARTITION BY website_session_id ORDER BY created_at) AS DENSE_RANKS
		FROM website_pageviews
	) RESULT
		WHERE DENSE_RANKS=1
)
SELECT
pageview_url,
COUNT(pageview_url) AS COUNT
FROM entry_page
GROUP BY pageview_url
ORDER BY COUNT DESC;





--conversion funnel


WITH funnel AS (
    SELECT 
        COUNT(DISTINCT website_session_id) AS visits
    FROM website_pageviews
),product_views AS (
    SELECT 
        COUNT(DISTINCT website_session_id) AS product
    FROM website_pageviews
    WHERE pageview_url ='/products'
), specific_product as(
	SELECT
		COUNT(DISTINCT website_session_id) AS specific_product
    FROM website_pageviews
    WHERE pageview_url IN ('/the-hudson-river-mini-bear','/the-birthday-sugar-panda','/the-original-mr-fuzzy','/the-forever-love-bear')
),add_to_cart AS (
    SELECT 
        COUNT(DISTINCT website_session_id) AS add_to_cart
    FROM website_pageviews
    WHERE pageview_url = '/cart'
), checkout AS (
    SELECT 
        COUNT(DISTINCT website_session_id) AS checkout_initiated
    FROM website_pageviews
    WHERE pageview_url IN ( '/billing','/billing-2')
), purchases AS (
    SELECT 
        COUNT(DISTINCT website_session_id) AS purchases
    FROM website_pageviews
    WHERE pageview_url = '/thank-you-for-your-order'
)
SELECT 
    f.visits,
    pv.product,
	sp.specific_product,
    ad.add_to_cart,
    co.checkout_initiated,
    p.purchases
FROM funnel f
JOIN product_views pv ON 1=1
JOIN specific_product sp ON 1=1
JOIN add_to_cart ad ON 1=1
JOIN checkout co ON 1=1
JOIN purchases p ON 1=1;


----------------------------------------------------------------------------------------------------------------------
--Marketing MAnager Dashboard
---------------------------------------------------------------------------------------------------------------------
-- KPI'S 

-- traffic conversion rate

select round((cast(total_order as float)/cast(total_session as float)) * 100,2) conversion_rate
from (
	  select
			(select count(distinct website_session_id) from website_sessions) total_session,
			(select count(order_id) from orders) total_order
			)counts

-- volume trends - total sessions, total users, repeat users

select count(distinct website_session_id) total_sessions from website_sessions
select count(distinct user_id) total_users from website_sessions
select count(distinct user_id) repeat_users from website_sessions where is_repeat_session = 1

-- repeat session rate

select round((cast(repeat_session as float)/cast(total_session as float)) * 100,2) repeat_session_rate 
from(
	 select 
		   (select count(website_session_id) from website_sessions 
			where is_repeat_session = 1) repeat_session,
		   (select count(distinct website_session_id) from website_sessions) total_session
	 )t_s



-- average session durtion

select round(avg(tbl2.session_duration),2) avg_session_duration_minutes from( 
select tbl1.website_session_id total_session, 
round(cast(datediff(second, start_time, end_time) as float)/60.0, 2) session_duration from(
select ws.website_session_id, min(cast(wp.created_at as time)) start_time, max(cast(wp.created_at as time)) end_time from website_sessions ws 
left join website_pageviews wp on ws.website_session_id = wp.website_session_id
group by ws.website_session_id) tbl1) tbl2



-- gsearch conversion rate

select round(cast(gsearch_orders as float) * 100.0/ cast(gsearch_sessions as float), 2) gsearch_conversion_rate from
(
 select
	    (select count(distinct order_id) from website_sessions ws join orders o 
		 on ws.website_session_id = o.website_session_id and o.user_id = ws.user_id
		 where utm_source = 'gsearch') gsearch_orders, 
		(select count(distinct website_session_id) from website_sessions
		 where utm_source = 'gsearch') gsearch_sessions
)tbl1



-- gsearch quaterly volume trends

select utm_source, datepart(year, created_at) year_ , datepart(quarter, created_at) qtr_ ,
count(distinct website_session_id) total_vistors from website_sessions
where utm_source = 'gsearch'
group by utm_source, datepart(year, created_at), datepart(quarter, created_at)
order by year_, qtr_


-- average time b/w the first and second session for repeated customers​

with cte1 as(
select user_id, min(case when rnk = 1 then created_at end) first_session, 
min(case when rnk = 2 then created_at end) second_session 
from(
	select user_id, created_at, row_number() over(partition by user_id order by website_session_id) rnk 
	from website_sessions
	) tbl1
	group by user_id)

select round(avg(cast(datediff(day, first_session, second_session) as float)),2) avg_diff_days
from cte1;



-- list of analysis to send daily

-- traffic conversion rate

select round((cast(total_order as float)/cast(total_session as float)) * 100,2) conversion_rate
from (
	  select
			(select count(distinct website_session_id) from website_sessions) total_session,
			(select count(order_id) from orders) total_order
			)counts

-- traffic volume trends

select datepart(year, created_at) year_ , datepart(quarter, created_at) qtr_ ,
count(distinct website_session_id) total_vistors from website_sessions
group by datepart(year, created_at), datepart(quarter, created_at)
order by year_, qtr_


-- traffic source segment trending

select utm_source, device_type, count(distinct website_session_id) total_vistors from website_sessions
group by utm_source, device_type;


-- traffic source bid optimization(source wise conversion rate) 

with cte1 as(
select utm_source s1, count(distinct o.order_id) total_orders from website_sessions ws 
inner join orders o on ws.user_id = o.user_id and ws.website_session_id = o.website_session_id
group by utm_source),
cte2 as (
select utm_source s2, count(distinct website_session_id) total_sessions from website_sessions
group by utm_source)

select cte2.s2 source_, round((cast(total_orders as float) * 100.0/ cast(total_sessions as float)),2) conversion_rate 
from cte2 join cte1 on cte1.s1 = cte2.s2

--  analysing channel portfolios

select device_type, datepart(year, created_at) year_ , datepart(quarter, created_at) qtr_ ,
count(distinct website_session_id) total_vistors from website_sessions
group by device_type, datepart(year, created_at), datepart(quarter, created_at)
order by device_type, year_, qtr_

-- comparing channel characteristics

select device_type, utm_source, count(distinct website_session_id) total_vistors from website_sessions
group by device_type, utm_source
order by device_type, utm_source

-- analyzing repeat behaviour

select utm_source, device_type, count(distinct wb.user_id) repeat_users, count(wb.website_session_id) volume from website_sessions wb
where is_repeat_session = 1
group by utm_source, device_type


-- new vs repeat user channel/ campaign patterns

select utm_campaign, sum(case when is_repeat_session = 0 then 1 else 0 end) new_users, 
sum(case when is_repeat_session = 1 then 1 else 0 end) repeat_users from website_sessions wb 
join orders o on wb.user_id = o.user_id and wb.website_session_id = o.website_session_id
group by utm_campaign;




-----------------------------------------------------------------user analysis----------------------------------------------------------------------------

--Identifying Repeat Visitors
select count(user_id) from(
SELECT user_id, COUNT(DISTINCT website_session_id) AS session_count
FROM website_sessions
GROUP BY user_id) as x
where session_count > 1
--51270

--Analyzing Repeat Behavior
SELECT user_id, device_type, http_referer, COUNT(*) AS session_count
FROM website_sessions
WHERE is_repeat_session = 1
GROUP BY user_id, device_type, http_referer
ORDER BY session_count DESC

--Analyzing Purchase Behavior
--Repeat Channel
SELECT ws.utm_source, COUNT(DISTINCT o.user_id) AS repeat_customers
FROM orders o
JOIN website_sessions ws ON o.website_session_id = ws.website_session_id
WHERE ws.is_repeat_session = 1
GROUP BY ws.utm_source
ORDER BY repeat_customers DESC;

--Conversion Rates
-- New Visitor Conversion Rate
SELECT 
    (COUNT(CASE WHEN ws.is_repeat_session = 0 THEN o.order_id END) / COUNT(DISTINCT CASE WHEN ws.is_repeat_session = 0 THEN ws.website_session_id END)) * 100 AS new_visitor_conversion_rate,
    (COUNT(CASE WHEN ws.is_repeat_session = 1 THEN o.order_id END) / COUNT(DISTINCT CASE WHEN ws.is_repeat_session = 1 THEN ws.website_session_id END)) * 100 AS repeat_visitor_conversion_rate
FROM orders o
JOIN website_sessions ws ON o.website_session_id = ws.website_session_id;

--Segmentation by Purchase Frequency:
SELECT user_id, COUNT(order_id) AS total_orders, SUM(price_usd) AS total_spent
FROM orders
GROUP BY user_id
order by total_orders desc;


--Segmentation by Product Preferences
SELECT o.user_id, p.product_name, COUNT(o.order_id) AS purchase_count
FROM orders o
JOIN products p ON o.primary_product_id = p.product_id
GROUP BY o.user_id, p.product_name

--product preference by users
select product_name,count(user_id) as counts
FROM orders o
JOIN products p ON o.primary_product_id = p.product_id
group by product_name
order by counts desc;

--Cohort Analysis

SELECT user_id, 
       CONVERT(DATE, FORMAT(created_at, 'yyyy-MM-01')) AS cohort_month
FROM orders
GROUP BY user_id, 
         CONVERT(DATE, FORMAT(created_at, 'yyyy-MM-01'));


-- Calculate cohort month and order months
WITH Cohort AS (
    SELECT 
        user_id, 
        DATEADD(DAY, 1 - DAY(created_at), CAST(created_at AS DATE)) AS cohort_month
    FROM orders
),
OrderCounts AS (
    SELECT 
        user_id, 
        order_id, 
        DATEADD(DAY, 1 - DAY(created_at), CAST(created_at AS DATE)) AS order_month
    FROM orders
)

-- Perform the cohort analysis
SELECT 
    c.cohort_month, 
    COUNT(DISTINCT c.user_id) AS cohort_size,
    COUNT(CASE WHEN o.order_month = c.cohort_month THEN o.order_id END) AS first_month_orders,
    COUNT(CASE WHEN o.order_month = DATEADD(MONTH, 1, c.cohort_month) THEN o.order_id END) AS second_month_orders
FROM Cohort c
LEFT JOIN OrderCounts o ON c.user_id = o.user_id
GROUP BY c.cohort_month
ORDER BY c.cohort_month;


-----------------------------------------------------Product Analysis----------------------------------------------------------------------------

--Total Sales by Product
SELECT 
    p.product_name,
    COUNT(o.order_id) AS total_orders,
    SUM(o.items_purchased) AS total_units_sold,
    SUM(o.price_usd) AS total_revenue
FROM orders o
JOIN products p ON o.primary_product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_revenue DESC;

--Sales Trends Over Time

SELECT 
    p.product_name,
    DATEADD(DAY, 1 - DAY(o.created_at), CAST(o.created_at AS DATE)) AS sale_month,
    SUM(o.price_usd) AS monthly_revenue
FROM orders o
JOIN products p ON o.primary_product_id = p.product_id
GROUP BY p.product_name, DATEADD(DAY, 1 - DAY(o.created_at), CAST(o.created_at AS DATE))
ORDER BY p.product_name, sale_month;


--Sales by Device Type
SELECT 
    p.product_name,
    ws.device_type,
    SUM(o.price_usd) AS total_revenue
FROM orders o
JOIN products p ON o.primary_product_id = p.product_id
JOIN website_sessions ws ON o.website_session_id = ws.website_session_id
GROUP BY p.product_name, ws.device_type
ORDER BY p.product_name, total_revenue DESC;


--Sales Post-Launch
SELECT 
    p.product_name,
    p.created_at AS launch_date,
    DATEADD(DAY, 1 - DAY(o.created_at), CAST(o.created_at AS DATE)) AS sale_date,
    SUM(o.price_usd) AS monthly_revenue
FROM orders o
JOIN products p ON o.primary_product_id = p.product_id
WHERE o.created_at >= p.created_at
GROUP BY p.product_name, p.created_at, DATEADD(DAY, 1 - DAY(o.created_at), CAST(o.created_at AS DATE))
ORDER BY p.product_name, launch_date, sale_date;


--Sales Growth Post-Launch
WITH SalesGrowth AS (
    SELECT 
        p.product_name,
        p.created_at AS launch_date,
        DATEADD(MONTH, DATEDIFF(MONTH, 0, o.created_at), 0) AS period_start,
        SUM(o.price_usd) AS total_revenue
    FROM orders o
    JOIN products p ON o.primary_product_id = p.product_id
    WHERE o.created_at >= p.created_at
    GROUP BY p.product_name, p.created_at, DATEADD(MONTH, DATEDIFF(MONTH, 0, o.created_at), 0)
)
SELECT 
    product_name,
    launch_date,
    period_start,
    total_revenue,
    LAG(total_revenue, 1) OVER (PARTITION BY product_name ORDER BY period_start) AS previous_period_revenue,
    (total_revenue - LAG(total_revenue, 1) OVER (PARTITION BY product_name ORDER BY period_start)) / NULLIF(LAG(total_revenue, 1) OVER (PARTITION BY product_name ORDER BY period_start), 0) * 100 AS growth_percentage
FROM SalesGrowth
ORDER BY product_name, period_start;


--Pathing Analysis by Product
-- Capture all pageviews leading to a product page

WITH PathToProduct AS (
    SELECT
        ws.website_session_id,
        p.product_name,
        wp.pageview_url,
        ROW_NUMBER() OVER (PARTITION BY ws.website_session_id ORDER BY wp.created_at) AS page_sequence
    FROM website_pageviews wp
    JOIN website_sessions ws ON wp.website_session_id = ws.website_session_id
    JOIN orders o ON ws.website_session_id = o.website_session_id
    JOIN products p ON o.primary_product_id = p.product_id
    WHERE wp.pageview_url LIKE '%product%'  -- Assuming product pages have a specific URL pattern
)
SELECT
    website_session_id,
    product_name,
    STRING_AGG(pageview_url, ' -> ') WITHIN GROUP (ORDER BY page_sequence) AS page_path
FROM PathToProduct
GROUP BY website_session_id, product_name
ORDER BY product_name, website_session_id;



--Time Spent on Pages Before Purchase

-- Calculate time spent on each page before purchasing a product
WITH PageVisitTimes AS (
    SELECT
        wp.website_session_id,
        wp.pageview_url,
        wp.created_at,
        LEAD(wp.created_at) OVER (PARTITION BY wp.website_session_id ORDER BY wp.created_at) AS next_pageview_time
    FROM website_pageviews wp
    JOIN website_sessions ws ON wp.website_session_id = ws.website_session_id
    JOIN orders o ON ws.website_session_id = o.website_session_id
    WHERE o.primary_product_id IS NOT NULL
)
-- Calculate time spent on each page
SELECT
    website_session_id,
    pageview_url,
    DATEDIFF(SECOND, created_at, ISNULL(next_pageview_time, GETDATE())) AS time_spent_seconds
FROM PageVisitTimes
ORDER BY website_session_id, created_at;

--Identify Frequently Bought Together Products
--Identifies pairs of products frequently purchased together, revealing cross-selling opportunities.
-- Identify frequently bought together products
WITH ProductPairs AS (
    SELECT
        o1.primary_product_id AS product_id_1,
        o2.primary_product_id AS product_id_2,
        COUNT(*) AS co_purchase_count
    FROM orders o1
    JOIN ordersss o2 ON o1.website_session_id = o2.website_session_id
    WHERE o1.primary_product_id < o2.primary_product_id
    GROUP BY o1.primary_product_id, o2.primary_product_id
)SELECT
    p1.product_name AS product_1,
    p2.product_name AS product_2,
    pp.co_purchase_count
FROM ProductPairs pp
JOIN products p1 ON pp.product_id_1 = p1.product_id
JOIN products p2 ON pp.product_id_2 = p2.product_id
ORDER BY pp.co_purchase_count DESC;

--Analyze Product Affinity
--Measures the likelihood of purchasing a related product given another product is purchased.
WITH ProductAffinities AS (
    SELECT
        o1.primary_product_id AS base_product_id,
        o2.primary_product_id AS related_product_id,
        COUNT(*) AS co_purchase_count
    FROM orders o1
    JOIN orders o2 ON o1.website_session_id = o2.website_session_id
    WHERE o1.primary_product_id <> o2.primary_product_id
    GROUP BY o1.primary_product_id, o2.primary_product_id
),
TotalProductCounts AS (
    SELECT
        primary_product_id,
        COUNT(*) AS total_count
    FROM orders
    GROUP BY primary_product_id
)

-- Calculate affinity ratio
SELECT
    p1.product_name AS base_product,
    p2.product_name AS related_product,
    pa.co_purchase_count,
    COALESCE(CONVERT(FLOAT, pa.co_purchase_count) / NULLIF(tp.total_count, 0), 0) AS affinity_ratio
FROM ProductAffinities pa
JOIN products p1 ON pa.base_product_id = p1.product_id
JOIN products p2 ON pa.related_product_id = p2.product_id
JOIN TotalProductCounts tp ON pa.base_product_id = tp.primary_product_id
ORDER BY affinity_ratio DESC;

--Product Sales Performance
-- Product sales performance
SELECT
    p.product_name,
    COUNT(o.order_id) AS total_orders,
    SUM(o.items_purchased) AS total_units_sold,
    SUM(o.price_usd) AS total_revenue
FROM orders o
JOIN products p ON o.primary_product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_revenue DESC;

--Product Contribution Margin
-- Product contribution margin
SELECT
    p.product_name,
    SUM(o.price_usd) - SUM(o.cogs_usd) AS contribution_margin
FROM orders o
JOIN products p ON o.primary_product_id = p.product_id
GROUP BY p.product_name
ORDER BY contribution_margin DESC;


-- Product diversity/Counts
SELECT
    COUNT(DISTINCT product_id) AS total_products
FROM products;


-- Calculate total refunds and refund amounts per product
WITH RefundsData AS (
    SELECT
        o.primary_product_id,
        COUNT(r.order_item_refund_id) AS total_refunds,
        SUM(r.refund_amount_usd) AS total_refund_amount
    FROM orders o
    JOIN order_item_refunds r ON o.order_id = r.order_id
    GROUP BY o.primary_product_id
),

-- Calculate total sales per product
SalesData AS (
    SELECT
        primary_product_id,
        COUNT(order_id) AS total_orders,
        SUM(price_usd) AS total_sales_amount
    FROM orders
    GROUP BY primary_product_id
)

-- Calculate refund rates
SELECT
    p.product_name,
    COALESCE(r.total_refunds, 0) AS total_refunds,
    COALESCE(r.total_refund_amount, 0) AS total_refund_amount,
    COALESCE(sd.total_orders, 0) AS total_orders,
    COALESCE(sd.total_sales_amount, 0) AS total_sales_amount,
    CASE 
        WHEN sd.total_sales_amount > 0 THEN 
            (COALESCE(r.total_refund_amount, 0) / sd.total_sales_amount) * 100
        ELSE 0
    END AS refund_rate_percentage
FROM SalesData sd
LEFT JOIN RefundsData r ON sd.primary_product_id = r.primary_product_id
JOIN products p ON sd.primary_product_id = p.product_id
ORDER BY refund_rate_percentage DESC;
