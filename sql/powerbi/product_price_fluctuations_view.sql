-- Drop the view if it exists
IF OBJECT_ID('dbo.product_price_fluctuations', 'V') IS NOT NULL
    DROP VIEW dbo.product_price_fluctuations;
GO

CREATE VIEW product_price_fluctuations AS
WITH InitialPrice AS (
    SELECT
        pp.reference_id AS program_product_id,
        pp.price_per_pack AS initial_price
    FROM
        public_program_product pp
    JOIN
        latest_product_version lpv ON pp.product_id = lpv.reference_id AND pp.product_version_number = lpv.version_number
),
LatestPrice AS (
    SELECT
        pc.program_product_id,
        MAX(pc.occurred_date) AS last_occurred_date,
        (SELECT TOP 1 pc1.price
         FROM public_price_changes pc1
         WHERE pc1.program_product_id = pc.program_product_id
         ORDER BY pc1.occurred_date DESC) AS latest_price
    FROM
        public_price_changes pc
    GROUP BY
        pc.program_product_id
),
PriceHistory AS (
    SELECT
        pc.program_product_id,
        pc.occurred_date,
        pc.price
    FROM
        public_price_changes pc
    UNION ALL
    SELECT
        pp.reference_id AS program_product_id,
        CAST(GETDATE() AS DATE) AS occurred_date,
        ISNULL(lp.latest_price, pp.price_per_pack) AS price
    FROM
        public_program_product pp
    LEFT JOIN
        LatestPrice lp ON pp.reference_id = lp.program_product_id
    JOIN
        latest_product_version lpv ON pp.product_id = lpv.reference_id AND pp.product_version_number = lpv.version_number
)
SELECT
    pp.program_id,
    prg.name AS program_name,
    pp.product_id,
    p.name AS product_name,
    ph.occurred_date AS price_change_date,
    ip.initial_price AS standard_price,
    ph.price AS actual_price,
    CAST(ROUND(ph.price - ip.initial_price, 2) AS DECIMAL(19, 2)) AS price_variance_amount,
    CAST(ROUND(
        CASE 
            WHEN ip.initial_price = 0 THEN 0
            ELSE (ph.price - ip.initial_price) / ip.initial_price 
        END, 2) AS DECIMAL(19, 2)) AS price_variance_percentage,
    ph.price AS historical_price
FROM
    InitialPrice ip
JOIN
    public_program_product pp ON ip.program_product_id = pp.reference_id
JOIN
    latest_product_version p ON pp.product_id = p.reference_id AND pp.product_version_number = p.version_number
JOIN
    public_program prg ON pp.program_id = prg.reference_id
JOIN
    PriceHistory ph ON ip.program_product_id = ph.program_product_id;
GO

