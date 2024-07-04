-- Drop the view if it exists
IF OBJECT_ID('dbo.expiring_stock_summary', 'V') IS NOT NULL
    DROP VIEW dbo.expiring_stock_summary;
GO

CREATE VIEW expiring_stock_summary AS
WITH soh_data AS (
    SELECT
        soh.id AS stock_on_hand_id,
        soh.stock_on_hand,
        soh.occurred_date AS stock_on_hand_date,
        f.id AS facility_id,
        f.name AS facility_name,
        gz.reference_id as municipality_id,
        gz2.reference_id as province_id,
        gz.name as municipality_name,
        gz2.name as province_name,
        p.id AS product_id,
        p.name AS product_name,
        pp.price_per_pack AS unit_cost,
        (soh.stock_on_hand * pp.price_per_pack) AS total_cost,
        lot.id AS lot_id,
        lot.code AS lot_code,
        lot.expiration_date,
        prg.id AS program_id,
        prg.name AS program_name
    FROM
        public_stock_on_hand soh
    JOIN
        public_stock_card sc ON soh.stock_card_id = sc.reference_id
    JOIN
        public_facility f ON sc.facility_id = f.reference_id
    JOIN
        latest_product_version p ON sc.product_id = p.reference_id
    JOIN
        public_program_product pp ON p.reference_id = pp.product_id AND pp.product_version_number = p.version_number
    JOIN
        public_lot lot ON sc.lot_id = lot.reference_id
    JOIN
        public_program prg ON pp.program_id = prg.reference_id
    JOIN
        public_geographic_zone gz ON gz.reference_id = f.geographic_zone_id
    JOIN
        public_geographic_level gl ON gz.level_id = gl.reference_id
    JOIN
        public_geographic_zone gz2 ON gz2.reference_id = gz.parent_id
    JOIN
        public_geographic_level gl2 ON gl2.reference_id = gz2.level_id
    WHERE 
        f.active = 1
),
expiring_data AS (
    SELECT DISTINCT
        soh.id AS stock_on_hand_id,
        CASE 
            WHEN lot.expiration_date <= DATEADD(month, 6, GETDATE()) THEN soh.stock_on_hand 
            ELSE 0 
        END AS expiring_quantity,
        CASE 
            WHEN lot.expiration_date <= DATEADD(month, 6, GETDATE()) THEN (soh.stock_on_hand * pp.price_per_pack)
            ELSE 0 
        END AS total_cost_expiring
    FROM
        public_stock_on_hand soh
    JOIN
        public_stock_card sc ON soh.stock_card_id = sc.reference_id
    JOIN
        public_lot lot ON sc.lot_id = lot.reference_id
    JOIN
        latest_product_version p ON sc.product_id = p.reference_id
    JOIN
        public_program_product pp ON p.reference_id = pp.product_id AND pp.product_version_number = p.version_number
    WHERE
        lot.expiration_date <= DATEADD(month, 6, GETDATE())
)
SELECT DISTINCT
    sd.stock_on_hand_id,
    sd.stock_on_hand,
    sd.stock_on_hand_date,
    sd.facility_id,
    sd.facility_name,
    sd.municipality_id,
    sd.province_id,
    sd.municipality_name,
    sd.province_name,
    sd.product_id,
    sd.product_name,
    sd.unit_cost,
    sd.total_cost,
    sd.lot_id,
    sd.lot_code,
    sd.expiration_date,
    sd.program_id,
    sd.program_name,
    COALESCE(ed.expiring_quantity, 0) AS expiring_quantity,
    COALESCE(ed.total_cost_expiring, 0) AS total_cost_expiring,
    CASE 
        WHEN sd.stock_on_hand = 0 THEN 0
        ELSE (COALESCE(ed.expiring_quantity, 0) * 1.0 / sd.stock_on_hand) * 100 
    END AS expiring_percentage
FROM
    soh_data sd
LEFT JOIN
    expiring_data ed ON sd.stock_on_hand_id = ed.stock_on_hand_id;
GO

