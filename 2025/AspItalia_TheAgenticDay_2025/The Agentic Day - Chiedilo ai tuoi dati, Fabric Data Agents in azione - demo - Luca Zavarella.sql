USE ZavaRetail
GO


-- =====================
--      EXAMPLE 01
-- =====================
--
-- REMEMBER: Add the 'orders', 'orders_items' and 'stores' tables in the Data Agent selection
--
-- Q. Retrieve the total gross amount and total net amount for all orders placed in March 2022 at the store "Zava Retail Seattle"

SELECT
	  SUM(items.total_amount + items.discount_amount) AS gross_amount
	, SUM(items.total_amount) AS net_amount

FROM [retail].[orders] AS ord

	INNER JOIN [retail].[order_items] AS items
	ON ord.order_id = items.order_id

	INNER JOIN [retail].[stores] AS store
	ON ord.store_id = store.store_id

WHERE
	store.store_name = 'Zava Retail Seattle'

	AND ord.order_date >= '2022-03-01'
	AND ord.order_date < '2022-04-01';



-- =====================
--      EXAMPLE 02
-- =====================
--
-- REMEMBER: Add the 'products' and 'categories' tables in the Data Agent selection
--
-- Q. I need to calculate net amount, total cost, and profit for products belonging to category PLUMBING in January 2025

SELECT
	SUM(items.total_amount) AS net_amount
	, SUM(prod.cost * items.quantity) AS cost
	, SUM(items.total_amount - prod.cost * items.quantity) AS profit
FROM [retail].[orders] AS ord

	INNER JOIN [retail].[order_items] AS items
	ON ord.order_id = items.order_id

	INNER JOIN [retail].[products] AS prod
	ON items.product_id = prod.product_id

	INNER JOIN [retail].[categories] AS cat
	ON prod.category_id = cat.category_id

WHERE
	cat.category_name = 'PLUMBING'

	AND ord.order_date >= '2025-01-01'
	AND ord.order_date < '2025-02-01';



-- =====================
--      EXAMPLE 03
-- =====================
-- REMEMBER: Add the product_types table in the Data Agent selection
--
-- Q. I need an SQL query that calculates overall profit for the category PLUMBING in January 2025. Within this category, I also want to compute:
--      - the profit generated only by products of type VALVES
--      - the percentage of VALVES profit over the total PLUMBING profit

SELECT
	SUM(items.total_amount - prod.cost * items.quantity) AS plumbing_profit
	, SUM(
			CASE
				WHEN types.type_name = 'VALVES'
				THEN items.total_amount - prod.cost * items.quantity
				ELSE 0
			END) AS valves_profit
	, SUM(
			CASE
				WHEN types.type_name = 'VALVES'
				THEN items.total_amount - prod.cost * items.quantity
				ELSE 0
			END) / SUM(items.total_amount - prod.cost * items.quantity) AS perc_valves_profit
FROM [retail].[orders] AS ord

	INNER JOIN [retail].[order_items] AS items
	ON ord.order_id = items.order_id

	INNER JOIN [retail].[products] AS prod
	ON items.product_id = prod.product_id

	INNER JOIN [retail].[categories] AS cat
	ON prod.category_id = cat.category_id

	INNER JOIN [retail].[product_types] AS types
	ON prod.type_id = types.type_id

WHERE
	
	cat.category_name = 'PLUMBING'

	AND ord.order_date >= '2025-01-01'
	AND ord.order_date < '2025-02-01'



-- =====================
--      EXAMPLE 04
-- =====================
--
-- Q. Provide month-by-month detail for the "Angle Stop Valve" product at the "Zava Retail Bellevue" store in 2024. Show running totals, gross margin and profit change. Flag the month of highest net sales.



-- =====================
--      EXAMPLE 05
-- =====================
-- 
-- Q. I need to work out the net amount, total cost and profit for pipe related products in January 2025
--
-- REMEMBER: Add the example and the instructions below
--
--    EXAMPLE TO ADD
--       I need to calculate net amount, total cost, and profit for pipe related products maintenance in January 2025
--
       SELECT
			 SUM(oi.quantity * oi.unit_price - oi.discount_amount) AS net_amount_after_discounts,
		     SUM(oi.quantity * p.cost) AS total_cost,
		     SUM((oi.quantity * oi.unit_price - oi.discount_amount) - (oi.quantity * p.cost)) AS profit
		 FROM retail.order_items oi
		 INNER JOIN retail.products p ON oi.product_id = p.product_id
		 INNER JOIN retail.product_types pt ON p.type_id = pt.type_id
		 INNER JOIN retail.orders o ON oi.order_id = o.order_id
		 WHERE
		     p.product_description LIKE '%pipe%'
		     AND o.order_date >= '2025-01-01'
		     AND o.order_date < '2025-02-01'
		 
--
--
--    INSTRUCTIONS TO ADD
--        # Business language
--        - When a users says "[something] related products" they are referring to products whom description contains "[something]"
--
--    TEST
--    I need to calculate net amount, total cost, and profit for products related to sinks in February 2025

SELECT
    --p.product_name,
    SUM(oi.quantity * oi.unit_price - oi.discount_amount) AS net_amount_after_discounts,
    SUM(oi.quantity * p.cost) AS total_cost,
    SUM((oi.quantity * oi.unit_price - oi.discount_amount) - (oi.quantity * p.cost)) AS profit
FROM retail.order_items oi
INNER JOIN retail.products p ON oi.product_id = p.product_id
INNER JOIN retail.product_types pt ON p.type_id = pt.type_id
INNER JOIN retail.orders o ON oi.order_id = o.order_id
WHERE
    p.product_description LIKE '%pipe%'
    AND o.order_date >= '2025-01-01'
    AND o.order_date < '2025-02-01'
--GROUP BY
--    p.product_name


-- 
-- In italiano!
-- Q. Devo calcolare l'importo netto, il costo totale e il profitto per i prodotti relativi ai lavandini nel mese di febbraio 2025
--
-- Non restituisce nulla!
-- Per funzionare, aggiungi questo alle Agent instructions:
-- # Generic instructions
-- - If the user uses a language other than English:
--   - You absolutely MUST translate keywords you use in the SQL query conditions and filters into English
--   - DO NOT use the user language in SQL queries



-- =====================
--      EXAMPLE 07
-- =====================
-- 
SELECT USER_NAME();
GO

-- Metto una "porta con badge" davanti a una tabella, così che ogni utente veda solo i dati che gli sono consentiti,
-- senza dover cambiare tutte le query una per una

-- La regola chiamata fn_SalesSecurity:
--     - 
CREATE OR ALTER FUNCTION dbo.fn_StoresSecurity(@StoreId AS INT)
    RETURNS TABLE
WITH SCHEMABINDING
AS
    RETURN
    SELECT 1 AS fn_StoresSecurity_Result
    -- Logic for filter predicate
    WHERE
        USER_NAME() = N'admin@lucazavarellaoutlook.onmicrosoft.com'
        OR (
            USER_NAME() = N'reader@lucazavarellaoutlook.onmicrosoft.com'
            AND @StoreId IN (1, 2, 6)  -- Seattle, Bellevue, Redmond
        );
GO


CREATE SECURITY POLICY UserFilter
ADD FILTER PREDICATE dbo.fn_StoresSecurity(store_id) 
ON [retail].[orders]
WITH (STATE = ON);
GO


SELECT
	  store.store_name
	, SUM(items.total_amount + items.discount_amount) AS gross_amount
	, SUM(items.total_amount) AS net_amount

FROM [retail].[orders] AS ord

	INNER JOIN [retail].[order_items] AS items
	ON ord.order_id = items.order_id

	INNER JOIN [retail].[stores] AS store
	ON ord.store_id = store.store_id

WHERE
	store.store_name IN ('Zava Retail Seattle', 'Zava Retail Tacoma')

	AND ord.order_date >= '2022-03-01'
	AND ord.order_date < '2022-04-01'
GROUP BY
	store.store_name;


-- Q. Retrieve the total gross amount and total net amount grouped by store for all orders placed in March 2022 at the "Zava Retail Seattle" and "Zava Retail Tacoma" stores



-- ===========================
--      CLEAR ENVIRONMENT
-- ===========================
-- 
DROP SECURITY POLICY UserFilter;
GO
DROP FUNCTION dbo.fn_StoresSecurity;
GO
