


-----------------------------------------------------------------------------------------------------------------------
----------------------------------------Investor Pitch Query------------------------------------------------------------
----------------------------------------------------------------------------------------------------------------------

--Q1. First, I’d like to show our volume growth. Can you pull overall session and order volume, 
--trended by quarter for the life of the business? Since the most recent quarter is incomplete, 
--you can decide how to handle it.

SELECT
    DATEPART(YEAR, ws.created_at) AS Year,
    DATEPART(QUARTER, ws.created_at) AS Quarter,
    COUNT(DISTINCT ws.website_session_id) AS Total_Sessions,
    COUNT(DISTINCT o.order_id) AS Total_Orders
FROM
    website_sessions ws
LEFT JOIN
    [orders] o ON ws.website_session_id = o.website_session_id
GROUP BY
    DATEPART(YEAR, ws.created_at),
    DATEPART(QUARTER, ws.created_at)
ORDER BY
    Year,
    Quarter;


--Q2. Next, let’s showcase all of our efficiency improvements. I would love to show quarterly
--figures since we launched, for session-to-order conversion rate, revenue per order, and revenue per session.


SELECT
    DATEPART(YEAR, ws.created_at) AS Year,
    DATEPART(QUARTER, ws.created_at) AS Quarter,
    COUNT(DISTINCT ws.website_session_id) AS total_sessions,
    COUNT(DISTINCT o.order_id) AS total_orders,
    SUM(oi.price_usd) AS total_revenue,
    FORMAT(COUNT(DISTINCT o.order_id)*1.0 / COUNT(DISTINCT ws.website_session_id),'0.000') AS 'CVR%',
    FORMAT(SUM(oi.price_usd) *1.0 / COUNT(DISTINCT o.order_id),'0.00') AS revenue_Per_Order,
    FORMAT(SUM(oi.price_usd)*1.0 / COUNT(DISTINCT ws.website_session_id),'0.00') AS revenue_Per_Session
FROM
    website_sessions ws
LEFT JOIN
    [orders] o ON ws.website_session_id = o.website_session_id
LEFT JOIN
	order_items oi ON o.order_id = oi.order_id
GROUP BY
    DATEPART(YEAR, ws.created_at),
    DATEPART(QUARTER, ws.created_at)
ORDER BY
    Year,
    Quarter;



-- Q3.I’d like to show how we’ve grown specific channels. Could you pull a quarterly view of orders from G search 
--nonbrand, B search nonbrand, brand search overall, organic search, and direct type-in?

WITH sessions_data as (
		SELECT 
			DATEPART(YEAR, ws.created_at) AS Year_,
			DATEPART(QUARTER, ws.created_at) AS Quarter_, 
			sum(case when utm_source = 'gsearch' and utm_campaign = 'nonbrand' then 1 else 0 end) gsearch_nonbrand_sessions,
			sum(case when utm_source = 'bsearch' and utm_campaign = 'nonbrand' then 1 else 0 end) bsearch_nonbrand_sessions,
			sum(case when utm_campaign = 'brand' then 1 else 0 end) brand_sessions,
			sum(case when (utm_campaign = 'none'  and utm_source = 'direct' and http_referer = 'direct') then 1 else 0 end) direct_Typein_sessions,
			sum(case when (utm_campaign = 'none'  and utm_source = 'direct' and http_referer != 'direct') then 1 else 0 end) organic_sessions
FROM 
	website_sessions ws
LEFT JOIN
    [orders] o ON ws.website_session_id = o.website_session_id
WHERE
    o.order_id IS NOT NULL
GROUP BY 
	DATEPART(YEAR, ws.created_at) ,
	DATEPART(QUARTER, ws.created_at)
)

SELECT Year_, 
	Quarter_,
	gsearch_nonbrand_sessions,
	bsearch_nonbrand_sessions,
	brand_sessions, 
	direct_Typein_sessions,
	organic_sessions
FROM
	sessions_data
ORDER BY 
	Year_, 
	Quarter_;





--Q4.  Next, let’s show the overall session-to-order conversion rate trends for those same channels, by quarter. 
--Please also make a note of any periods where we made major improvements or optimizations.


WITH sessions_data as (
		SELECT 
			DATEPART(YEAR, ws.created_at) AS Year_,
			DATEPART(QUARTER, ws.created_at) AS Quarter_, 
			sum(case when utm_source = 'gsearch' and utm_campaign = 'nonbrand' then 1 else 0 end) gsearch_nonbrand_sessions,
			sum(case when utm_source = 'bsearch' and utm_campaign = 'nonbrand' then 1 else 0 end) bsearch_nonbrand_sessions,
			sum(case when utm_campaign = 'brand' then 1 else 0 end) brand_sessions,
			sum(case when (utm_campaign = 'none'  and utm_source = 'direct' and http_referer = 'direct') then 1 else 0 end) direct_Typein_sessions,
			sum(case when (utm_campaign = 'none'  and utm_source = 'direct' and http_referer != 'direct') then 1 else 0 end) organic_sessions
FROM 
	website_sessions ws
LEFT JOIN
    [orders] o ON ws.website_session_id = o.website_session_id
GROUP BY 
	DATEPART(YEAR, ws.created_at) ,
	DATEPART(QUARTER, ws.created_at)
),
orders_data as (
		SELECT 
			DATEPART(YEAR, ws.created_at) AS Year_,
			DATEPART(QUARTER, ws.created_at) AS Quarter_, 
			sum(case when utm_source = 'gsearch' and utm_campaign = 'nonbrand' then 1 else 0 end) gsearch_nonbrand_orders,
			sum(case when utm_source = 'bsearch' and utm_campaign = 'nonbrand' then 1 else 0 end) bsearch_nonbrand_orders,
			sum(case when utm_campaign = 'brand' then 1 else 0 end) brand_orders,
			sum(case when (utm_campaign = 'none'  and utm_source = 'direct' and http_referer = 'direct') then 1 else 0 end) direct_Typein_orders,
			sum(case when (utm_campaign = 'none'  and utm_source = 'direct' and http_referer != 'direct') then 1 else 0 end) organic_orders
FROM 
	website_sessions ws
LEFT JOIN
    [orders] o ON ws.website_session_id = o.website_session_id
 WHERE
        o.order_id IS NOT NULL
GROUP BY 
	DATEPART(YEAR, ws.created_at) ,
	DATEPART(QUARTER, ws.created_at)
)
SELECT 
    sd.Year_,
    sd.Quarter_,
    sd.gsearch_nonbrand_sessions,
    sd.bsearch_nonbrand_sessions,
    sd.brand_sessions,
    sd.direct_Typein_sessions,
    sd.organic_sessions,
    od.gsearch_nonbrand_orders,
    od.bsearch_nonbrand_orders,
    od.brand_orders,
    od.direct_Typein_orders,
    od.organic_orders,
    CASE WHEN sd.gsearch_nonbrand_sessions > 0 
         THEN (od.gsearch_nonbrand_orders * 100.0 / sd.gsearch_nonbrand_sessions)
         ELSE 0 
    END AS gsearch_nonbrand_CVR,
    CASE WHEN sd.bsearch_nonbrand_sessions > 0 
         THEN (od.bsearch_nonbrand_orders * 100.0 / sd.bsearch_nonbrand_sessions)
         ELSE 0 
    END AS bsearch_nonbrand_CVR,
    CASE WHEN sd.brand_sessions > 0 
         THEN (od.brand_orders * 100.0 / sd.brand_sessions)
         ELSE 0 
    END AS brand_CVR,
    CASE WHEN sd.direct_Typein_sessions > 0 
         THEN (od.direct_Typein_orders * 100.0 / sd.direct_Typein_sessions)
         ELSE 0 
    END AS direct_Typein_CVR,
    CASE WHEN sd.organic_sessions > 0 
         THEN (od.organic_orders * 100.0 / sd.organic_sessions)
         ELSE 0 
    END AS organic_CVR
FROM 
    sessions_data sd
JOIN 
    orders_data od ON sd.Year_ = od.Year_ AND sd.Quarter_ = od.Quarter_
ORDER BY 
    sd.Year_,
    sd.Quarter_;



--Q5. We’ve come a long way since the days of selling a single product. Let’s pull monthly trending for revenue 
--and margin by product, along with total sales and revenue. 
--Note anything you notice about seasonality.


SELECT 
    FORMAT(o.created_at, 'yyyy-MM') AS month,
    p.product_name,
    COUNT(DISTINCT oi.order_item_id) AS total_sales,
    SUM(oi.price_usd) AS total_revenue,
    SUM(oi.price_usd - oi.cogs_usd) AS total_margin
FROM 
    orders o
JOIN 
    order_items oi ON o.order_id = oi.order_id
JOIN 
    products p ON oi.product_id = p.product_id
GROUP BY 
    FORMAT(o.created_at, 'yyyy-MM'), p.product_name
ORDER BY 
    FORMAT(o.created_at, 'yyyy-MM'), p.product_name;


--Q6. Let’s dive deeper into the impact of introducing new products.
--Please pull monthly sessions to the /products page, and show how the % of those sessions clicking through another page
--has changed over time, along with a view of how conversion from /products to placing an order has improved. 


SELECT 
		YEAR(PROD_SEEN_AT) AS YEARS,
		MONTH(PROD_SEEN_AT) AS MONTHS,
		COUNT(DISTINCT P.website_session_id) AS SESSION_TO_PROD_PAGE,
		COUNT(DISTINCT W.website_session_id) AS CLICKED_TO_NEXT_PAGE,
		ROUND(CAST(COUNT(DISTINCT W.website_session_id) AS FLOAT)/COUNT(DISTINCT P.website_session_id),4) AS CLICK_THR_RATE,
		COUNT(DISTINCT O.order_id) AS ORDERS,
		ROUND(CAST(COUNT(DISTINCT O.order_id) AS FLOAT)/COUNT(DISTINCT P.website_session_id),4) AS PROD_TO_ORDER_RATE

FROM
(SELECT website_session_id, website_pageview_id, created_at AS PROD_SEEN_AT FROM website_pageviews
WHERE pageview_url='/products') as P
left join website_pageviews as W
ON W.website_session_id = P.website_session_id
AND W.website_pageview_id > P.website_pageview_id
LEFT JOIN ORDERS AS O
ON O.website_session_id = P.website_session_id
GROUP BY YEAR(PROD_SEEN_AT), MONTH(PROD_SEEN_AT)
ORDER BY YEARS,MONTHS;


-- Q7. We made our 4th product available as a primary product on December 05, 2014 
--(it was previously only a cross-sell item). Could you please pull sales data since then, 
--and show how well each product cross-sells from one another? 


SELECT 
    PRIMARY_PRODUCT_ID,
    COUNT(DISTINCT ORDER_ID) AS TOTAL_ORDERS,
    COUNT(DISTINCT CASE WHEN CROSS_SELL_PROD_ID = 1 THEN ORDER_ID ELSE NULL END) AS SOLD_P1,
    COUNT(DISTINCT CASE WHEN CROSS_SELL_PROD_ID = 2 THEN ORDER_ID ELSE NULL END) AS SOLD_P2,
    COUNT(DISTINCT CASE WHEN CROSS_SELL_PROD_ID = 3 THEN ORDER_ID ELSE NULL END) AS SOLD_P3,
    COUNT(DISTINCT CASE WHEN CROSS_SELL_PROD_ID = 4 THEN ORDER_ID ELSE NULL END) AS SOLD_P4,
    CAST(COUNT(DISTINCT CASE WHEN CROSS_SELL_PROD_ID = 1 THEN ORDER_ID ELSE NULL END) AS FLOAT) / COUNT(DISTINCT ORDER_ID) AS P1_CROSSSELL_RATE,
    CAST(COUNT(DISTINCT CASE WHEN CROSS_SELL_PROD_ID = 2 THEN ORDER_ID ELSE NULL END) AS FLOAT) / COUNT(DISTINCT ORDER_ID) AS P2_CROSSSELL_RATE,
    CAST(COUNT(DISTINCT CASE WHEN CROSS_SELL_PROD_ID = 3 THEN ORDER_ID ELSE NULL END) AS float) / COUNT(DISTINCT ORDER_ID) AS P3_CROSSSELL_RATE,
    CAST(COUNT(DISTINCT CASE WHEN CROSS_SELL_PROD_ID = 4 THEN ORDER_ID ELSE NULL END) AS FLOAT)  / COUNT(DISTINCT ORDER_ID) AS P4_CROSSSELL_RATE
FROM (
    SELECT 
        X.ORDER_ID, 
        X.PRIMARY_PRODUCT_ID, 
        I.product_id AS CROSS_SELL_PROD_ID 
    FROM 
        (SELECT ORDER_ID, PRIMARY_PRODUCT_ID, CREATED_AT AS ORDERED_AT 
         FROM orders 
         WHERE CREATED_AT > '2014-12-05') AS X
    LEFT JOIN 
        order_items AS I ON X.ORDER_ID = I.order_id AND I.is_primary_item = 0
) AS CROSS_SELL
GROUP BY PRIMARY_PRODUCT_ID;


--Q9. Gsearch seems to be the biggest driver of our business. 
--Could you pull monthly trends for gsearch sessions and orders so that we can showcase the growth there? 


select year(ws.created_at) year_, month(ws.created_at) month_, count(ws.website_session_id) total_sessions,
count(order_id) total_orders from website_sessions ws left join orders o
on ws.website_session_id = o.website_session_id and ws.user_id = o.user_id
where utm_source = 'gsearch'
group by year(ws.created_at), month(ws.created_at)
order by year_, month_;

-- Q10 Next, it would be great to see a similar monthly trend for Gsearch, but this time splitting out 
--nonbrand and brand campaigns separately. I am wondering if brand is picking up at all. 
--If so, this is a good story to tell


select year(ws.created_at) year_, month(ws.created_at) month_, utm_campaign, count(ws.website_session_id) total_sessions,
count(order_id) total_orders from website_sessions ws left join orders o
on ws.website_session_id = o.website_session_id and ws.user_id = o.user_id
where utm_source = 'gsearch'
group by year(ws.created_at), month(ws.created_at), utm_campaign
order by year_, month_, utm_campaign;


-- Q11 While we’re on Gsearch, could you dive into nonbrand, and pull monthly sessions and orders split by device type? 
--I want to flex our analytical muscles a little and show the board we really know our traffic sources

select year(ws.created_at) year_, month(ws.created_at) month_, device_type, count(ws.website_session_id) total_sessions,
count(order_id) total_orders from website_sessions ws left join orders o
on ws.website_session_id = o.website_session_id and ws.user_id = o.user_id
where utm_source = 'gsearch'
group by year(ws.created_at), month(ws.created_at), device_type
order by year_, month_, device_type;


-- Q12 I’m worried that one of our more pessimistic board members may be concerned about the large % of traffic from Gsearch. 
-- Can you pull monthly trends for Gsearch, alongside monthly trends for each of our other channels?


select year(ws.created_at) year_, month(ws.created_at) month_, utm_source, count(ws.website_session_id) total_sessions,
count(order_id) total_orders from website_sessions ws left join orders o
on ws.website_session_id = o.website_session_id and ws.user_id = o.user_id
group by year(ws.created_at), month(ws.created_at), utm_source
order by year_, month_, utm_source;

--Q13. I’d like to tell the story of our website performance improvements over the course of the first 8 months. 
--Could you pull session to order conversion rates, by month?

WITH MonthlySessions AS 
--finding the total sessions for first 8 months
(
    SELECT 
        YEAR(created_at) AS year,
        MONTH(created_at) AS month,
        COUNT(DISTINCT website_session_id) AS total_sessions
    FROM Session_and_Pageview
    WHERE created_at BETWEEN '2012-03-19 ' AND '2012-10-19'
    GROUP BY YEAR(created_at), MONTH(created_at)
),
--finding the total orders for first 8 months
MonthlyOrders AS 
(
    SELECT 
        YEAR(created_at) AS year,
        MONTH(created_at) AS month,
        COUNT(DISTINCT order_id) AS total_orders
    FROM orders
    WHERE created_at BETWEEN '2012-03-19 ' AND '2012-10-19 '
    GROUP BY YEAR(created_at), MONTH(created_at)
)
SELECT 
    MS.year,
    MS.month,
    MS.total_sessions,
    MO.total_orders,
    ROUND((CAST(MO.total_orders AS FLOAT) / MS.total_sessions) * 100,2) AS conversion_rate
FROM MonthlySessions MS
LEFT JOIN MonthlyOrders MO ON MS.year = MO.year AND MS.month = MO.month
ORDER BY MS.year, MO.month;

--Q14.  For the gsearch lander test, please estimate the revenue that test earned us (Hint: Look at the increase in CVR
--from the test (Jun 19 – Jul 28), and use nonbrand sessions and revenue since then to calculate incremental value) 


--Q15. For the landing page test you analyzed previously, it would be great to show a full conversion funnel from each 
--of the two pages to orders. You can use the same time period you analyzed last time (Jun 19 – Jul 28). 

WITH page_sessions AS (
  SELECT
    website_session_id,
    MAX(CASE WHEN pageview_url = '/home' THEN 1 ELSE 0 END) AS Homepage,
    MAX(CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END) AS lander,
    MAX(CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END) AS product_page,
    MAX(CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END) AS fuzzy_page,
    MAX(CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END) AS cart_page,
    MAX(CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END) AS shipping_page,
    MAX(CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END) AS billing_page,
    MAX(CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END) AS thankyou_page
  FROM Session_and_Pageview
  WHERE utm_source = 'gsearch'
    AND utm_campaign = 'nonbrand'
    AND created_at BETWEEN '2012-06-19' AND '2012-07-28'
  GROUP BY website_session_id
),

--  Group sessions by landing page and calculate conversion funnel metrics
conversion_funnel AS (
  SELECT
    CASE 
      WHEN Homepage = 1 THEN 'Homepage'
      WHEN lander = 1 THEN 'lander-1'
      ELSE 'check logic' 
    END AS segment,
    COUNT(DISTINCT website_session_id) AS sessions,
    COUNT(DISTINCT CASE WHEN product_page = 1 THEN website_session_id ELSE NULL END) AS products_click_rate,
    COUNT(DISTINCT CASE WHEN fuzzy_page = 1 THEN website_session_id ELSE NULL END) AS fuzzy_click_rate,
    COUNT(DISTINCT CASE WHEN cart_page = 1 THEN website_session_id ELSE NULL END) AS cart_click_rate,
    COUNT(DISTINCT CASE WHEN shipping_page = 1 THEN website_session_id ELSE NULL END) AS shipping_click_rate,
    COUNT(DISTINCT CASE WHEN billing_page = 1 THEN website_session_id ELSE NULL END) AS billing_click_rate,
    COUNT(DISTINCT CASE WHEN thankyou_page = 1 THEN website_session_id ELSE NULL END) AS thankyou_click_rate
  FROM page_sessions
  GROUP BY 
    CASE 
      WHEN Homepage = 1 THEN 'Homepage'
      WHEN lander = 1 THEN 'lander-1'
      ELSE 'check logic' 
    END
)

--Calculate click-through rates
SELECT
  segment,
  sessions,
  (products_click_rate *100/ sessions) AS product_click_rt,
  (fuzzy_click_rate *100/ products_click_rate) AS mrfuzzy_click_rt,
  (cart_click_rate *100/ fuzzy_click_rate) AS cart_click_rt,
  (shipping_click_rate *100 / cart_click_rate) AS shipping_click_rt,
  (billing_click_rate *100/ shipping_click_rate) AS billing_click_rt,
  (thankyou_click_rate *100/ billing_click_rate) AS thankyou_click_rt
FROM conversion_funnel;


--Q16. I’d love for you to quantify the impact of our billing test, as well. Please analyze the lift generated from 
--the test (Sep 10 – Nov 10), in terms of revenue per billing page session, and then pull the number of billing page sessions for the past month to understand monthly impact.

-- total session and revenue for billing page before test
WITH before_test AS (
    SELECT
        COUNT(website_pageview_id) AS total_sessions,
        SUM(price_usd) AS total_revenue
    from website_pageviews wp
	JOIN orders o on o.website_session_id = wp.website_session_id
	WHERE pageview_url = ('/billing') 
	  AND wp.created_at < '2012-09-10' 
),
-- total session and revenue for billing page during test
during_test AS (
    SELECT
        COUNT(wp.website_session_id) AS total_sessions,
        SUM(price_usd) AS total_revenue
    FROM website_pageviews wp
	JOIN orders o on o.website_session_id = wp.website_session_id
	WHERE pageview_url  = ('/billing') 
	  AND wp.created_at BETWEEN '2012-09-10' AND '2012-11-10'
),
--total revenue of the billing page 
billing_revenue AS
(
	SELECT
		(before_test.total_revenue / before_test.total_sessions) AS revenue_per_session_before,
	    (during_test.total_revenue / during_test.total_sessions) AS revenue_per_session_during
	FROM
		before_test,
		during_test
),
--session count of billing page, one month before Sep-9
billing_month_before AS
(
	SELECT
		COUNT(WP.website_session_id) AS session_count_before_one_month
	FROM website_pageviews wp
	JOIN orders o ON o.website_session_id = wp.website_session_id
	WHERE pageview_url = ('/billing') 
	  AND wp.created_at  <= DATEADD(month, -1, '2012-09-10')

),
-- total session and revenue for billing-2 page before test
billing_2_before_test AS
(
    SELECT
        COUNT(website_pageview_id) AS total_sessions,
        SUM(price_usd) AS total_revenue
    FROM website_pageviews wp
	JOIN orders o on o.website_session_id = wp.website_session_id
	WHERE pageview_url = ('/billing-2') 
	  AND wp.created_at < '2012-09-10' 
),
-- total session and revenue for billing page during test
billing2_during_test AS 
(
    SELECT
        COUNT(wp.website_session_id) AS total_sessions,
        SUM(price_usd) AS total_revenue
    FROM website_pageviews wp
	JOIN orders o on o.website_session_id = wp.website_session_id
	WHERE pageview_url  =  ('/billing-2') 
	  AND wp.created_at BETWEEN '2012-09-10' AND '2012-11-10'
),
--total revenue of the billing-2 page 
billing2_revenue AS
(
	SELECT
		(billing_2_before_test.total_revenue / billing_2_before_test.total_sessions) AS revenue_per_session_before,
		(billing2_during_test.total_revenue / billing2_during_test.total_sessions) AS revenue_per_session_during
	FROM
		billing_2_before_test,
		   billing2_during_test
),
--session count of billing page, one month before Sep-9
billing2_month_before AS
(
	SELECT
		COUNT(WP.website_session_id) AS session_count_before_one_month
	FROM website_pageviews wp
	JOIN orders o ON o.website_session_id = wp.website_session_id
	WHERE pageview_url = ('/billing-2') 
	  AND wp.created_at  <= DATEADD(month, -1, '2012-09-10')
)

SELECT
	'billing' as page,
	before_test.total_sessions AS sessions_count_before,
	during_test.total_sessions AS session_count_during,
	revenue_per_session_before,
	revenue_per_session_during,
	revenue_per_session_during - revenue_per_session_before AS lift_in_revenue_per_session,
	session_count_before_one_month
FROM
    before_test,
    during_test,
	billing_revenue,
	billing_month_before

UNION ALL 

SELECT
	'billing_2' as page,
	billing_2_before_test.total_sessions AS sessions_count_before,
	billing2_during_test.total_sessions AS session_count_during,
	revenue_per_session_before,
    revenue_per_session_during,
	revenue_per_session_during - revenue_per_session_before AS lift_in_revenue_per_session,
	session_count_before_one_month

FROM
    billing_2_before_test,
    billing2_during_test,
	billing2_revenue,
	billing2_month_before