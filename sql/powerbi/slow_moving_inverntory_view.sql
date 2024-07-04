-- Drop the view if it exists
IF OBJECT_ID('dbo.slow_moving_inventory', 'V') IS NOT NULL
    DROP VIEW dbo.slow_moving_inventory;
GO

-- Create the view
CREATE VIEW dbo.slow_moving_inventory AS
WITH latest_requisition AS (
    SELECT  
        rl.reference_id AS requisition_line_id,
        rl.product_id,
        rl.requisition_id,
        rl.average_consumption,
        rl.beginning_balance,
        ROW_NUMBER() OVER (PARTITION BY rl.product_id ORDER BY r.stock_count_date DESC) AS rn
    FROM
        public_requisition_line rl
    JOIN
        public_requisition r ON rl.requisition_id = r.reference_id
    WHERE
        r.facility_id IS NOT NULL
)
SELECT
    distinct
    f.name AS Facility_Name,
    gz.name AS Municipality_Name,
    gz2.name AS Province_Name,
    p.name AS Product_Name,
    prg.name AS Program_Name,
    COALESCE(lr.average_consumption, 0) AS AMC,
    COALESCE(lr.beginning_balance, 0) AS Start_Inventory,
    COALESCE(soh.stock_on_hand, 0) AS End_Inventory,
    CASE
        WHEN (COALESCE(lr.beginning_balance, 0) + COALESCE(soh.stock_on_hand, 0)) = 0 THEN 0
        ELSE (COALESCE(lr.average_consumption, 0) / ((COALESCE(lr.beginning_balance, 0) + COALESCE(soh.stock_on_hand, 0)) / 2.0))
    END AS Inventory_Turnover_Rate
FROM
    latest_requisition lr
JOIN
    public_requisition r ON lr.requisition_id = r.reference_id
JOIN
    public_facility f ON r.facility_id = f.reference_id
JOIN
    public_geographic_zone gz ON f.geographic_zone_id = gz.reference_id
JOIN
    public_geographic_level gl ON gz.level_id = gl.reference_id
JOIN
    public_geographic_zone gz2 ON gz.parent_id = gz2.reference_id
JOIN
    public_geographic_level gl2 ON gz2.level_id = gl2.reference_id
JOIN
    public_stock_card sc ON lr.product_id = sc.product_id AND r.facility_id = sc.facility_id
JOIN
    public_stock_on_hand soh ON sc.reference_id = soh.stock_card_id
JOIN
    latest_product_version p ON lr.product_id = p.reference_id
JOIN
    public_program_product pp ON p.reference_id = pp.product_id AND pp.program_id = r.program_id AND pp.product_version_number = p.version_number
JOIN
    public_program prg ON pp.program_id = prg.reference_id
WHERE
    f.active = 1
    AND lr.rn = 1;
GO

