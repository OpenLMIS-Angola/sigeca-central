-- Drop the view if it exists
IF OBJECT_ID('dbo.months_of_stock', 'V') IS NOT NULL
    DROP VIEW dbo.months_of_stock;
GO



-- Create the view
CREATE VIEW [dbo].[months_of_stock]
AS
WITH LatestRequisition AS (
    SELECT
        rl.product_id,
        rl.product_version_number,
        r.facility_id,
        r.program_id,
        MAX(r.stock_count_date) AS latest_stock_count_date
    FROM
        public_requisition_line rl
    JOIN
        public_requisition r ON rl.requisition_id = r.reference_id
    GROUP BY
        rl.product_id,
        rl.product_version_number,
        r.facility_id,
        r.program_id
),
LatestRequisitionLine AS (
    SELECT
        rl.product_id,
        rl.product_version_number,
        rl.average_consumption,
        r.stock_count_date,
        r.facility_id,
        r.program_id
    FROM
        public_requisition_line rl
    JOIN
        public_requisition r ON rl.requisition_id = r.reference_id
    JOIN
        LatestRequisition lr ON rl.product_id = lr.product_id 
        AND rl.product_version_number = lr.product_version_number 
        AND r.facility_id = lr.facility_id 
        AND r.program_id = lr.program_id 
        AND r.stock_count_date = lr.latest_stock_count_date
)
SELECT
    gz2.name AS Province,
    gz.name AS Municipality,
    f.name AS Facility,
    prg.name AS Program,
    pp.code AS ProductCode,
    pp.name AS ProductName,
    COALESCE(psoh.stock_on_hand, 0) AS SOH,
    COALESCE(lr.average_consumption, 0) AS AMC,
    COALESCE(CAST(psoh.stock_on_hand AS FLOAT) / NULLIF(CAST(lr.average_consumption AS FLOAT), 0), 0) AS MOS
FROM 
    public_facility f
LEFT JOIN 
    public_geographic_zone gz ON f.geographic_zone_id = gz.reference_id
LEFT JOIN 
    public_geographic_level gl ON gz.level_id = gl.reference_id
LEFT JOIN 
    public_geographic_zone gz2 ON gz.parent_id = gz2.reference_id
LEFT JOIN 
    public_geographic_level gl2 ON gz2.level_id = gl2.reference_id
JOIN 
    public_stock_card sc ON f.reference_id = sc.facility_id
JOIN 
    public_stock_on_hand psoh ON sc.reference_id = psoh.stock_card_id
JOIN 
    latest_product_version pp ON sc.product_id = pp.reference_id
JOIN 
    public_program_product ppp ON pp.reference_id = ppp.product_id AND pp.version_number = ppp.product_version_number
JOIN 
    public_program prg ON ppp.program_id = prg.reference_id
LEFT JOIN 
    LatestRequisitionLine lr ON pp.reference_id = lr.product_id AND pp.version_number = lr.product_version_number AND lr.facility_id = f.reference_id AND lr.program_id = prg.reference_id
WHERE
    f.active = 1;

